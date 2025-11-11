import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/ticket_detail_provider.dart';
import '../../data/repositories/tickets_repository_impl.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const TicketDetailScreen({super.key, required this.id});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  bool _sendingComment = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketDetailProvider.notifier).load(widget.id);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketDetailProvider);
    final theme = Theme.of(context);
    final repo = TicketsRepositoryImpl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ticket'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.ticket == null
              ? Center(child: Text(state.error?.message ?? 'No se encontró el ticket'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado del ticket
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.ticket!.title,
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _statusChip(state.ticket!.status, theme),
                                const SizedBox(width: 8),
                                _priorityChip(state.ticket!.priority, theme),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Controles para cambiar estado y prioridad
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: state.ticket!.status,
                                    decoration: const InputDecoration(labelText: 'Estado'),
                                    items: const [
                                      DropdownMenuItem(value: 'abierto', child: Text('Abierto')),
                                      DropdownMenuItem(value: 'en_progreso', child: Text('En progreso')),
                                      DropdownMenuItem(value: 'en_revision', child: Text('En revisión')),
                                      DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                                      DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
                                    ],
                                    onChanged: (v) async {
                                      if (v == null) return;
                                      final ok = await ref.read(ticketDetailProvider.notifier).updateStatus(state.ticket!.id, v);
                                      if (!ok && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el estado')));
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: state.ticket!.priority,
                                    decoration: const InputDecoration(labelText: 'Prioridad'),
                                    items: const [
                                      DropdownMenuItem(value: 'baja', child: Text('Baja')),
                                      DropdownMenuItem(value: 'media', child: Text('Media')),
                                      DropdownMenuItem(value: 'alta', child: Text('Alta')),
                                      DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
                                    ],
                                    onChanged: (v) async {
                                      if (v == null) return;
                                      final ok = await ref.read(ticketDetailProvider.notifier).updatePriority(state.ticket!.id, v);
                                      if (!ok && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar la prioridad')));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(state.ticket!.description,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _infoChip(Icons.confirmation_number_outlined, 'ID: ${state.ticket!.id.substring(0, 8)}'),
                                if (state.ticket!.dueDate != null)
                                  _infoChip(
                                      Icons.event,
                                      'Vence: ${state.ticket!.dueDate!.day}/${state.ticket!.dueDate!.month}/${state.ticket!.dueDate!.year}'),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: state.ticket!.dueDate ?? now,
                                      firstDate: now,
                                      lastDate: now.add(const Duration(days: 365 * 2)),
                                    );
                                    if (picked != null) {
                                      final ok = await ref.read(ticketDetailProvider.notifier).updateDueDate(state.ticket!.id, picked);
                                      if (!ok && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar la fecha')));
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.event_available_outlined),
                                  label: Text(state.ticket!.dueDate == null ? 'Asignar fecha' : 'Cambiar fecha'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Adjuntos
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adjuntos', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _addAttachment(context, repo);
                                },
                                icon: const Icon(Icons.add_a_photo_outlined),
                                label: const Text('Agregar imagen'),
                              ),
                            ),
                            if (state.attachments.isEmpty) ...[
                              Text('Sin adjuntos', style: theme.textTheme.bodyMedium),
                            ] else ...[
                              // Grid de imágenes
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final a in state.attachments)
                                    if (_isImage(a.fileType, a.fileUrl))
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _openImageViewer(context, a.fileUrl),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: a.fileUrl,
                                                width: 110,
                                                height: 110,
                                                fit: BoxFit.cover,
                                                placeholder: (c, _) => Container(
                                                  width: 110,
                                                  height: 110,
                                                  color: Colors.white.withValues(alpha: 0.08),
                                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                ),
                                                errorWidget: (c, _, __) => Container(
                                                  width: 110,
                                                  height: 110,
                                                  color: Colors.white.withValues(alpha: 0.08),
                                                  child: const Icon(Icons.broken_image_outlined),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -6,
                                            right: -6,
                                            child: IconButton(
                                              tooltip: 'Eliminar',
                                              style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                              onPressed: () => _confirmDeleteAttachment(context, a.id),
                                              icon: const Icon(Icons.close, color: Colors.white, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Lista de no-imágenes
                              ...state.attachments.where((a) => !_isImage(a.fileType, a.fileUrl)).map((a) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.attach_file),
                                    title: Text(a.fileName),
                                    subtitle: Text(a.fileType),
                                    trailing: Wrap(
                                      spacing: 8,
                                      children: [
                                        IconButton(
                                          tooltip: 'Abrir',
                                          onPressed: () => _openUrl(context, a.fileUrl),
                                          icon: const Icon(Icons.open_in_new),
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          onPressed: () => _confirmDeleteAttachment(context, a.id),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comentarios
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comentarios', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (state.comments.isEmpty)
                              Text('Sin comentarios', style: theme.textTheme.bodyMedium)
                            else
                              ...state.comments.map((c) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.comment_outlined),
                                    title: Text(c.comment),
                                    subtitle: Text('${c.createdAt}'),
                                  )),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentCtrl,
                                    decoration: const InputDecoration(
                                      hintText: 'Escribe un comentario...',
                                      prefixIcon: Icon(Icons.mode_comment_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _sendingComment
                                      ? null
                                      : () async {
                                          final text = _commentCtrl.text.trim();
                                          if (text.isEmpty) return;
                                          setState(() => _sendingComment = true);
                                          final ok = await ref.read(ticketDetailProvider.notifier).addComment(state.ticket!.id, text);
                                          if (mounted) {
                                            setState(() => _sendingComment = false);
                                            if (ok) {
                                              _commentCtrl.clear();
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo comentar')));
                                            }
                                          }
                                        },
                                  icon: _sendingComment
                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.send),
                                  label: const Text('Enviar'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _statusChip(String s, ThemeData theme) {
    final color = () {
      switch (s) {
        case 'abierto':
          return Colors.orangeAccent;
        case 'en_progreso':
          return Colors.blueAccent;
        case 'en_revision':
          return Colors.purpleAccent;
        case 'resuelto':
          return Colors.greenAccent;
        case 'cerrado':
          return Colors.grey;
        default:
          return theme.colorScheme.primary;
      }
    }();
    return Chip(label: Text(s), backgroundColor: color.withValues(alpha: 0.15));
  }

  Widget _priorityChip(String p, ThemeData theme) {
    final color = () {
      switch (p) {
        case 'baja':
          return Colors.greenAccent;
        case 'media':
          return Colors.amberAccent;
        case 'alta':
          return Colors.deepOrangeAccent;
        case 'urgente':
          return Colors.redAccent;
        default:
          return theme.colorScheme.primary;
      }
    }();
    return Chip(label: Text(p), backgroundColor: color.withValues(alpha: 0.15));
  }

  void _openUrl(BuildContext context, String url) {
    launchUrlString(url, mode: LaunchMode.externalApplication);
  }

  void _openImageViewer(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (c, _, __) => const Icon(Icons.broken_image_outlined, color: Colors.white, size: 64),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Abrir en el navegador',
                        onPressed: () => _openUrl(context, url),
                        icon: const Icon(Icons.open_in_new, color: Colors.white),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isImage(String? fileType, String url) {
    final t = (fileType ?? '').toLowerCase();
    if (t.startsWith('image/')) return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  Future<void> _addAttachment(BuildContext context, TicketsRepositoryImpl repo) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final suggestedName = (() {
        try {
          final n = picked.name;
          if (n.isNotEmpty) return n;
        } catch (_) {}
        final p = picked.path;
        return p.contains('/') ? p.split('/').last : p;
      })();

      final bytes = await picked.readAsBytes();
      final res = await repo.uploadAttachmentBytes(
        ticketId: widget.id,
        bytes: bytes,
        fileName: suggestedName,
      );

      res.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir: ${failure.message}')),
        ),
        (_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adjunto agregado')),
          );
          await ref.read(ticketDetailProvider.notifier).load(widget.id);
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }

  Future<void> _confirmDeleteAttachment(BuildContext context, String attachmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar adjunto'),
        content: const Text('¿Estás seguro de eliminar este adjunto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await ref.read(ticketDetailProvider.notifier).deleteAttachment(attachmentId);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adjunto eliminado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo eliminar el adjunto')),
          );
        }
      }
    }
  }
}
