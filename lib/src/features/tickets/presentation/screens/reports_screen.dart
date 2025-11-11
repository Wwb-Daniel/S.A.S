import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../reports/presentation/providers/reports_provider.dart';
import '../../../reports/presentation/widgets/export_format_dialog.dart';
import '../widgets/statistics_cards.dart';
import '../widgets/trends_chart.dart';
import '../widgets/status_chart.dart';
import '../widgets/priority_chart.dart';
import '../widgets/ticket_filters_dialog.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportsProvider.notifier).loadStatistics();
    });
  }

  Future<void> _showFiltersDialog() async {
    final state = ref.read(reportsProvider);
    final currentFilters = state.filters;
    final notifier = ref.read(reportsProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) => TicketFiltersDialog(
        initialFilters: currentFilters,
        onApply: (filters) {
          notifier.loadFilteredStatistics(
            startDate: filters.startDate,
            endDate: filters.endDate,
            filters: filters,
          );
        },
      ),
    );
  }

  Future<void> _exportReport() async {
    final notifier = ref.read(reportsProvider.notifier);
    final state = ref.read(reportsProvider);
    
    // Mostrar diálogo para seleccionar formato
    final format = await ExportFormatDialog.show(context);
    if (format == null) return;

    // Convertir ExportFormat a string
    String formatString;
    switch (format) {
      case ExportFormat.pdf:
        formatString = 'pdf';
        break;
      case ExportFormat.word:
        formatString = 'word';
        break;
      case ExportFormat.excel:
        formatString = 'excel';
        break;
      case ExportFormat.csv:
        formatString = 'csv';
        break;
      case ExportFormat.json:
        formatString = 'json';
        break;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generando reporte...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await notifier.exportReport(
        startDate: state.startDate,
        endDate: state.endDate,
        filters: state.filters,
        format: formatString,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte exportado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar reporte: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Exportar Reporte',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsProvider.notifier).loadStatistics(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.error}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(reportsProvider.notifier).loadStatistics(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(reportsProvider.notifier).loadStatistics(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.filters != null || state.startDate != null || state.endDate != null) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Filtros Aplicados',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  if (state.startDate != null)
                                    Text(
                                      'Desde: ${state.startDate!.toLocal().toString().split(' ')[0]}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.endDate != null)
                                    Text(
                                      'Hasta: ${state.endDate!.toLocal().toString().split(' ')[0]}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.status != null)
                                    Text(
                                      'Estado: ${state.filters!.status}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.priority != null)
                                    Text(
                                      'Prioridad: ${state.filters!.priority}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.categoryId != null)
                                    Text(
                                      'Categoría: ${state.filters!.categoryId}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.assignedTo != null)
                                    Text(
                                      'Asignado a: ${state.filters!.assignedTo}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.createdBy != null)
                                    Text(
                                      'Creado por: ${state.filters!.createdBy}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (state.filters?.isOverdue != null)
                                    Text(
                                      'Solo vencidos: ${state.filters!.isOverdue! ? 'Sí' : 'No'}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => ref.read(reportsProvider.notifier).clearFilters(),
                                    child: const Text('Limpiar Filtros'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.statistics != null) ...[
                          StatisticsCards(statistics: state.statistics!),
                          const SizedBox(height: 24),
                          if (state.trends != null && state.trends!.isNotEmpty) ...[
                            Text(
                              'Tendencias',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            TrendsChart(trends: state.trends!),
                            const SizedBox(height: 24),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estado de Tickets',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    StatusChart(
                                      statusCounts: state.statistics!.ticketsByStatus,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prioridad de Tickets',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    PriorityChart(
                                      priorityCounts: state.statistics!.ticketsByPriority,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}