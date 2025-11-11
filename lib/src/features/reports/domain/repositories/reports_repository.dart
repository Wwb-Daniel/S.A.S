import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../models/ticket_statistics.dart';
import '../models/ticket_trends.dart';
import '../../../tickets/domain/models/ticket_filters.dart';

abstract class ReportsRepository {
  /// Obtiene estadísticas generales de tickets
  Future<Either<Failure, TicketStatistics>> getTicketStatistics();

  /// Obtiene estadísticas filtradas por rango de fechas y otros filtros
  Future<Either<Failure, TicketStatistics>> getFilteredStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
  });

  /// Obtiene datos para gráficos de tendencias
  Future<Either<Failure, List<TicketTrends>>> getTicketTrends({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day', // day, week, month
  });

  /// Exporta reportes en múltiples formatos
  Future<Either<Failure, String>> exportTicketReport({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
    String format = 'csv', // csv, json, pdf, word, excel
  });
}