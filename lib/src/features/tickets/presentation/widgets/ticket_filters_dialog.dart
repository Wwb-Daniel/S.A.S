import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ticket_filters.dart';
import '../../../auth/presentation/providers/users_provider.dart';

class TicketFiltersDialog extends ConsumerStatefulWidget {
  final TicketFilters? initialFilters;
  final Function(TicketFilters) onApply;

  const TicketFiltersDialog({
    super.key,
    this.initialFilters,
    required this.onApply,
  });

  @override
  ConsumerState<TicketFiltersDialog> createState() => _TicketFiltersDialogState();
}

class _TicketFiltersDialogState extends ConsumerState<TicketFiltersDialog> {
  late TicketFilters _currentFilters;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters ?? TicketFilters();
    _startDate = _currentFilters.startDate;
    _endDate = _currentFilters.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);

    return AlertDialog(
      title: const Text('Filtrar Tickets'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Estado
            DropdownButtonFormField<String>(
              value: _currentFilters.status,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos los estados')),
                const DropdownMenuItem(value: 'abierto', child: Text('Abierto')),
                const DropdownMenuItem(value: 'en_progreso', child: Text('En Progreso')),
                const DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                const DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                const DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(status: value);
                });
              },
            ),
            const SizedBox(height: 16),

            // Prioridad
            DropdownButtonFormField<String>(
              value: _currentFilters.priority,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas las prioridades')),
                const DropdownMenuItem(value: 'baja', child: Text('Baja')),
                const DropdownMenuItem(value: 'media', child: Text('Media')),
                const DropdownMenuItem(value: 'alta', child: Text('Alta')),
                const DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(priority: value);
                });
              },
            ),
            const SizedBox(height: 16),

            // Categoría (ID opcional)
            TextFormField(
              initialValue: _currentFilters.categoryId?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Categoría (ID numérico)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                setState(() {
                  _currentFilters = _currentFilters.copyWith(categoryId: parsed);
                });
              },
            ),
            const SizedBox(height: 16),

            // Asignado a
            if (usersState.isLoading)
              const CircularProgressIndicator()
            else if (usersState.error != null)
              const Text('Error al cargar usuarios')
            else
              DropdownButtonFormField<String>(
                value: _currentFilters.assignedTo,
                decoration: const InputDecoration(
                  labelText: 'Asignado a',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos los usuarios')),
                  const DropdownMenuItem(value: '', child: Text('Sin asignar')),
                  ...usersState.users.map((user) => DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.firstName} ${user.lastName}'),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(assignedTo: value);
                  });
                },
              ),
            const SizedBox(height: 16),

            // Creado por
            if (usersState.isLoading)
              const CircularProgressIndicator()
            else if (usersState.error != null)
              const Text('Error al cargar usuarios')
            else
              DropdownButtonFormField<String>(
                value: _currentFilters.createdBy,
                decoration: const InputDecoration(
                  labelText: 'Creado por',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos los usuarios')),
                  ...usersState.users.map((user) => DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.firstName} ${user.lastName}'),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(createdBy: value);
                  });
                },
              ),
            const SizedBox(height: 16),

            // Fechas
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha inicio',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startDate?.toLocal().toString().split(' ')[0] ?? 'Seleccionar'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha fin',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endDate?.toLocal().toString().split(' ')[0] ?? 'Seleccionar'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vencidos
            CheckboxListTile(
              title: const Text('Mostrar solo vencidos'),
              value: _currentFilters.isOverdue ?? false,
              onChanged: (value) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(isOverdue: value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _currentFilters = TicketFilters();
              _startDate = null;
              _endDate = null;
            });
          },
          child: const Text('Limpiar'),
        ),
        ElevatedButton(
          onPressed: () {
            final filtersWithDates = _currentFilters.copyWith(
              startDate: _startDate,
              endDate: _endDate,
            );
            widget.onApply(filtersWithDates);
            Navigator.of(context).pop();
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }
}