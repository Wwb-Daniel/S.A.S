import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/tickets_repository_impl.dart';
import '../../domain/repositories/tickets_repository.dart';

class TicketCreateScreen extends ConsumerStatefulWidget {
  const TicketCreateScreen({super.key});

  @override
  ConsumerState<TicketCreateScreen> createState() => _TicketCreateScreenState();
}

class _TicketCreateScreenState extends ConsumerState<TicketCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'media';
  int? _categoryId;
  DateTime? _dueDate;
  bool _saving = false;
  final List<Uint8List> _images = [];
  final List<String> _imageNames = [];

  late final TicketsRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = TicketsRepositoryImpl();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedList = await picker.pickMultiImage();
    if (pickedList.isEmpty) return;
    final newBytes = <Uint8List>[];
    final newNames = <String>[];
    for (final x in pickedList) {
      final bytes = await x.readAsBytes();
      newBytes.add(bytes);
      try {
        newNames.add(x.name.isNotEmpty ? x.name : x.path.split('/').last);
      } catch (_) {
        newNames.add(x.path.split('/').last);
      }
    }
    setState(() {
      _images.addAll(newBytes);
      _imageNames.addAll(newNames);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final res = await _repo.createTicket(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _priority,
      categoryId: _categoryId,
      dueDate: _dueDate,
    );

    await res.fold(
      (failure) async {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (ticket) async {
        // Subir todas las imágenes seleccionadas (si hay)
        for (int i = 0; i < _images.length; i++) {
          final up = await _repo.uploadAttachmentBytes(
            ticketId: ticket.id,
            bytes: _images[i],
            fileName: _imageNames[i],
          );
          up.fold(
            (f) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Adjunto ${i + 1}/${_images.length} falló: ${f.message}')),
            ),
            (_) {},
          );
        }

        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket creado')),
        );
        context.go('/tickets/${ticket.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa un título';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 12),
              // Adjuntar imágenes (opcional)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Adjuntar imágenes'),
                  ),
                  const SizedBox(height: 8),
                  if (_images.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _images.length; i++)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _images[i],
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _saving
                                        ? null
                                        : () => setState(() {
                                              _images.removeAt(i);
                                              _imageNames.removeAt(i);
                                            }),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white70, width: 1),
                                      ),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      items: const [
                        DropdownMenuItem(value: 'baja', child: Text('Baja')),
                        DropdownMenuItem(value: 'media', child: Text('Media')),
                        DropdownMenuItem(value: 'alta', child: Text('Alta')),
                        DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                      ],
                      onChanged: (v) => setState(() => _priority = v ?? 'media'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Categoría (opcional)',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _categoryId = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(_dueDate == null
                          ? 'Fecha límite'
                          : 'Fecha: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Guardando...' : 'Crear ticket'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
