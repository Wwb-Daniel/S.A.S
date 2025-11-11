import 'package:flutter/material.dart';
import '../../../reports/domain/models/ticket_statistics.dart';

class StatisticsCards extends StatelessWidget {
  final TicketStatistics statistics;

  const StatisticsCards({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Generales',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _StatisticsCard(
              title: 'Total de Tickets',
              value: statistics.totalTickets.toString(),
              icon: Icons.confirmation_number,
              color: theme.colorScheme.primary,
            ),
            _StatisticsCard(
              title: 'Tickets Abiertos',
              value: statistics.openTickets.toString(),
              icon: Icons.inbox,
              color: Colors.orange,
            ),
            _StatisticsCard(
              title: 'Tickets Resueltos',
              value: statistics.resolvedTickets.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _StatisticsCard(
              title: 'Tickets Vencidos',
              value: statistics.overdueTickets.toString(),
              icon: Icons.warning,
              color: Colors.red,
            ),
            _StatisticsCard(
              title: 'Tasa de Resolución',
              value: '${statistics.resolutionRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: Colors.blue,
            ),
            _StatisticsCard(
              title: 'Tasa de Vencimiento',
              value: '${statistics.overdueRate.toStringAsFixed(1)}%',
              icon: Icons.schedule,
              color: Colors.purple,
            ),
            _StatisticsCard(
              title: 'Tiempo Promedio de Resolución',
              value: _formatDuration(statistics.averageResolutionTime),
              icon: Icons.timer,
              color: Colors.teal,
            ),
            _StatisticsCard(
              title: 'Tiempo Promedio de Respuesta',
              value: _formatDuration(statistics.averageResponseTime),
              icon: Icons.speed,
              color: Colors.indigo,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(double? hours) {
    if (hours == null) return 'N/A';
    final totalMinutes = (hours * 60).round();
    final days = totalMinutes ~/ (60 * 24);
    final remAfterDays = totalMinutes % (60 * 24);
    final h = remAfterDays ~/ 60;
    final m = remAfterDays % 60;
    if (days > 0) return '${days}d ${h}h';
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}