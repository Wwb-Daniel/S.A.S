import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/glass_container.dart';
import '../providers/tickets_list_provider.dart';
import '../../domain/models/ticket_filters.dart';
import '../widgets/ticket_filters_dialog.dart';

class TicketsListScreen extends ConsumerStatefulWidget {
  const TicketsListScreen({super.key});

  @override
  ConsumerState<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends ConsumerState<TicketsListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketsListProvider.notifier).load(filters: TicketFilters());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFiltersDialog() {
    final state = ref.watch(ticketsListProvider);
    final notifier = ref.read(ticketsListProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => TicketFiltersDialog(
        initialFilters: state.filters,
        onApply: (filters) {
          // Mantener la búsqueda actual si existe
          final filtersWithSearch = filters.copyWith(
            searchQuery: _searchCtrl.text.trim().isNotEmpty 
                ? _searchCtrl.text.trim() 
                : filters.searchQuery,
          );
          notifier.load(filters: filtersWithSearch);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketsListProvider);
    final notifier = ref.read(ticketsListProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            onPressed: () => _showFiltersDialog(),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () => notifier.load(filters: state.filters),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/tickets/new');
        },
        label: const Text('Nuevo'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Búsqueda simple + indicador de filtros activos
            GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  // Búsqueda
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.filters?.hasActiveFilters == true
                            ? IconButton(
                                icon: const Icon(Icons.filter_alt, color: Colors.blue),
                                onPressed: () => _showFiltersDialog(),
                              )
                            : null,
                      ),
                      onSubmitted: (_) {
                        final newFilters = (state.filters ?? TicketFilters()).copyWith(
                          searchQuery: _searchCtrl.text.trim(),
                        );
                        notifier.load(filters: newFilters);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFiltersDialog(),
                    style: IconButton.styleFrom(
                      backgroundColor: state.filters?.hasActiveFilters == true 
                          ? Colors.blue.withOpacity(0.2)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.tickets.isEmpty
                      ? Center(
                          child: Text(
                            'No hay tickets',
                            style: theme.textTheme.bodyLarge,
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.tickets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final t = state.tickets[index];
                            return InkWell(
                              onTap: () => context.push('/tickets/${t.id}'),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(14),
                                borderRadius: BorderRadius.circular(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _statusColor(t.status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            t.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _priorityChip(t.priority, theme),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
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
        return Colors.white70;
    }
  }

  Widget _priorityChip(String p, ThemeData theme) {
    Color c;
    switch (p) {
      case 'baja':
        c = Colors.greenAccent.withValues(alpha: 0.8);
        break;
      case 'media':
        c = Colors.amberAccent.withValues(alpha: 0.9);
        break;
      case 'alta':
        c = Colors.deepOrangeAccent.withValues(alpha: 0.9);
        break;
      case 'urgente':
        c = Colors.redAccent.withValues(alpha: 0.9);
        break;
      default:
        c = theme.colorScheme.primary.withValues(alpha: 0.8);
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(p.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
    );
  }
}
