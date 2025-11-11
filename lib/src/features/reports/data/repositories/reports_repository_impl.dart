import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/models/ticket_statistics.dart';
import '../../domain/models/ticket_trends.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../../tickets/domain/models/ticket_filters.dart';
import '../services/export_service.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final SupabaseClient _client;
  final ExportService _exportService;

  ReportsRepositoryImpl({ExportService? exportService})
      : _client = Supabase.instance.client,
        _exportService = exportService ?? ExportService();

  @override
  Future<Either<Failure, TicketStatistics>> getTicketStatistics() async {
    try {
      // Calcular estadísticas directamente desde los tickets
      // (No usamos RPC porque la función puede no existir en Supabase)
      return await _calculateStatistics();
    } catch (e) {
      return Left(ServerFailure('Error al obtener estadísticas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TicketStatistics>> getFilteredStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
  }) async {
    try {
      // Construir query base
      var query = _client.from('tickets').select('*');

      // Aplicar filtros de fecha
      if (startDate != null) {
        query = query.gte('created_at', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toUtc().toIso8601String());
      }

      // Aplicar otros filtros
      if (filters != null) {
        if (filters.status != null && filters.status!.isNotEmpty) {
          query = query.eq('status', filters.status!);
        }
        if (filters.priority != null && filters.priority!.isNotEmpty) {
          query = query.eq('priority', filters.priority!);
        }
        if (filters.categoryId != null) {
          query = query.eq('category_id', filters.categoryId!);
        }
        if (filters.assignedTo != null && filters.assignedTo!.isNotEmpty) {
          query = query.eq('assigned_to', filters.assignedTo!);
        }
        if (filters.createdBy != null && filters.createdBy!.isNotEmpty) {
          query = query.eq('created_by', filters.createdBy!);
        }
        if (filters.isOverdue == true) {
          final now = DateTime.now().toUtc().toIso8601String();
          query = query.lt('due_date', now).neq('status', 'resuelto').neq('status', 'cerrado');
        }
      }

      final tickets = await query;
      return await _calculateStatisticsFromTickets(tickets);
    } catch (e) {
      return Left(ServerFailure('Error al obtener estadísticas filtradas: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TicketTrends>>> getTicketTrends({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    try {
      // Calcular tendencias directamente desde los tickets
      // (No usamos RPC porque la función puede no existir en Supabase)
      return await _calculateTrends(startDate, endDate, groupBy);
    } catch (e) {
      return Left(ServerFailure('Error al obtener tendencias: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportTicketReport({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
    String format = 'csv',
  }) async {
    try {
      // Obtener tickets filtrados
      // Nota: Simplificamos la query para evitar problemas con relaciones complejas
      var query = _client.from('tickets').select('*');

      // Aplicar filtros
      if (startDate != null) {
        query = query.gte('created_at', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toUtc().toIso8601String());
      }

      if (filters != null) {
        if (filters.status != null && filters.status!.isNotEmpty) {
          query = query.eq('status', filters.status!);
        }
        if (filters.priority != null && filters.priority!.isNotEmpty) {
          query = query.eq('priority', filters.priority!);
        }
        if (filters.categoryId != null) {
          query = query.eq('category_id', filters.categoryId!);
        }
        if (filters.assignedTo != null && filters.assignedTo!.isNotEmpty) {
          query = query.eq('assigned_to', filters.assignedTo!);
        }
        if (filters.createdBy != null && filters.createdBy!.isNotEmpty) {
          query = query.eq('created_by', filters.createdBy!);
        }
        if (filters.isOverdue == true) {
          final now = DateTime.now().toUtc().toIso8601String();
          query = query.lt('due_date', now).neq('status', 'resuelto').neq('status', 'cerrado');
        }
      }

      final tickets = await query;
      final ticketsList = tickets as List<dynamic>;
      final ticketsMapped = ticketsList.map((t) => Map<String, dynamic>.from(t as Map)).toList();

      // Obtener nombre de la compañía
      String? companyName;
      try {
        final companyId = await _client.rpc('get_current_user_company_id');
        if (companyId != null) {
          final company = await _client
              .from('companies')
              .select('name')
              .eq('id', companyId)
              .single();
          companyName = company['name'] as String?;
        }
      } catch (_) {
        // Ignorar error al obtener nombre de compañía
      }

      // Determinar formato de exportación y exportar
      if (format == 'csv') {
        final csvContent = _generateCSV(ticketsMapped);
        // Convertir a UTF-8 con BOM para compatibilidad con Excel
        final utf8Bytes = utf8.encode(csvContent);
        final bytesWithBom = Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8Bytes]);
        final filePath = await _exportService.saveFile(
          bytes: bytesWithBom,
          fileName: 'reporte_tickets_${DateTime.now().millisecondsSinceEpoch}.csv',
          mimeType: 'text/csv;charset=utf-8',
        );
        return Right(filePath);
      } else if (format == 'json') {
        final jsonContent = _generateJSON(ticketsMapped);
        final bytes = Uint8List.fromList(jsonContent.codeUnits);
        final filePath = await _exportService.saveFile(
          bytes: bytes,
          fileName: 'reporte_tickets_${DateTime.now().millisecondsSinceEpoch}.json',
          mimeType: 'application/json',
        );
        return Right(filePath);
      } else {
        // Para PDF, Word y Excel
        ExportFormat exportFormat;
        if (format == 'pdf') {
          exportFormat = ExportFormat.pdf;
        } else if (format == 'word' || format == 'docx') {
          exportFormat = ExportFormat.word;
        } else {
          exportFormat = ExportFormat.excel;
        }

        // Exportar usando el servicio
        final filePath = await _exportService.exportTickets(
          tickets: ticketsMapped,
          format: exportFormat,
          companyName: companyName,
        );

        return Right(filePath);
      }
    } catch (e) {
      return Left(ServerFailure('Error al exportar reporte: ${e.toString()}'));
    }
  }

  // Métodos auxiliares privados
  Future<Either<Failure, TicketStatistics>> _calculateStatistics() async {
    try {
      final tickets = await _client.from('tickets').select('*');
      return await _calculateStatisticsFromTickets(tickets);
    } catch (e) {
      return Left(ServerFailure('Error al calcular estadísticas: ${e.toString()}'));
    }
  }

  Future<Either<Failure, TicketStatistics>> _calculateStatisticsFromTickets(List<dynamic> tickets) async {
    try {
      final ticketList = tickets as List<Map<String, dynamic>>;
      
      // Contar por estado
      final statusCounts = <String, int>{};
      final priorityCounts = <String, int>{};
      final categoryCounts = <String, int>{};
      final userCounts = <String, int>{};
      
      int overdueCount = 0;
      double totalResolutionTime = 0;
      int resolvedCount = 0;
      
      final now = DateTime.now();
      final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final thisMonthStart = DateTime(now.year, now.month, 1);
      
      int createdThisWeek = 0;
      int createdThisMonth = 0;
      int resolvedThisWeek = 0;
      int resolvedThisMonth = 0;

      for (final ticket in ticketList) {
        // Contar por estado
        final status = ticket['status'] as String? ?? 'desconocido';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        
        // Contar por prioridad
        final priority = ticket['priority'] as String? ?? 'media';
        priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
        
        // Contar por categoría
        final categoryId = ticket['category_id'] as String? ?? 'sin_categoria';
        categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
        
        // Contar por usuario asignado
        final assignedTo = ticket['assigned_to'] as String? ?? 'sin_asignar';
        userCounts[assignedTo] = (userCounts[assignedTo] ?? 0) + 1;
        
        // Verificar si está vencido
        final dueDate = ticket['due_date'] != null 
            ? DateTime.parse(ticket['due_date'] as String) 
            : null;
        if (dueDate != null && 
            dueDate.isBefore(now) && 
            status != 'resuelto' && 
            status != 'cerrado') {
          overdueCount++;
        }
        
        // Calcular tiempo de resolución
        if (status == 'resuelto' || status == 'cerrado') {
          final createdAt = DateTime.parse(ticket['created_at'] as String);
          final closedAt = ticket['closed_at'] != null 
              ? DateTime.parse(ticket['closed_at'] as String) 
              : now;
          final resolutionTime = closedAt.difference(createdAt).inHours.toDouble();
          totalResolutionTime += resolutionTime;
          resolvedCount++;
          
          // Contar resueltos esta semana/mes
          if (closedAt.isAfter(thisWeekStart)) resolvedThisWeek++;
          if (closedAt.isAfter(thisMonthStart)) resolvedThisMonth++;
        }
        
        // Contar creados esta semana/mes
        final createdAt = DateTime.parse(ticket['created_at'] as String);
        if (createdAt.isAfter(thisWeekStart)) createdThisWeek++;
        if (createdAt.isAfter(thisMonthStart)) createdThisMonth++;
      }
      
      final avgResolutionTime = resolvedCount > 0 ? (totalResolutionTime / resolvedCount).toDouble() : 0.0;
      
      final statistics = TicketStatistics(
        totalTickets: ticketList.length,
        openTickets: statusCounts['abierto'] ?? 0,
        inProgressTickets: statusCounts['en_progreso'] ?? 0,
        resolvedTickets: statusCounts['resuelto'] ?? 0,
        closedTickets: statusCounts['cerrado'] ?? 0,
        overdueTickets: overdueCount,
        ticketsByStatus: statusCounts,
        ticketsByPriority: priorityCounts,
        ticketsByCategory: categoryCounts,
        ticketsByUser: userCounts,
        averageResolutionTime: avgResolutionTime,
        averageResponseTime: 0, // Podría calcularse con timestamps de respuesta
        ticketsCreatedThisWeek: createdThisWeek,
        ticketsCreatedThisMonth: createdThisMonth,
        ticketsResolvedThisWeek: resolvedThisWeek,
        ticketsResolvedThisMonth: resolvedThisMonth,
      );
      
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure('Error al calcular estadísticas: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<TicketTrends>>> _calculateTrends(
    DateTime? startDate,
    DateTime? endDate,
    String groupBy,
  ) async {
    try {
      final tickets = await _client.from('tickets').select('*');
      final ticketList = List<Map<String, dynamic>>.from(tickets.map((e) => Map<String, dynamic>.from(e as Map)));
      
      // Agrupar tickets por fecha
      final dateGroups = <DateTime, List<Map<String, dynamic>>>{};
      
      for (final ticket in ticketList) {
        final createdAt = DateTime.parse(ticket['created_at'] as String);
        
        // Filtrar por rango de fechas si se especifica
        if (startDate != null && createdAt.isBefore(startDate)) continue;
        if (endDate != null && createdAt.isAfter(endDate)) continue;
        
        // Agrupar por día, semana o mes
        DateTime groupDate;
        if (groupBy == 'day') {
          groupDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        } else if (groupBy == 'week') {
          final weekStart = createdAt.subtract(Duration(days: createdAt.weekday - 1));
          groupDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        } else { // month
          groupDate = DateTime(createdAt.year, createdAt.month, 1);
        }
        
        dateGroups.putIfAbsent(groupDate, () => []).add(ticket);
      }
      
      // Convertir a lista de tendencias
      final trends = <TicketTrends>[];
      for (final entry in dateGroups.entries) {
        final ticketsInGroup = entry.value;
        final createdCount = ticketsInGroup.length;
        final resolvedCount = ticketsInGroup.where((t) {
          final status = t['status'] as String?;
          return status == 'resuelto' || status == 'cerrado';
        }).length;
        final openCount = ticketsInGroup.where((t) {
          final status = t['status'] as String?;
          return status == 'abierto' || status == 'en_progreso';
        }).length;
        
        trends.add(TicketTrends(
          date: entry.key,
          createdCount: createdCount,
          resolvedCount: resolvedCount,
          closedCount: resolvedCount, // aproximación: incluir cerrados en resueltos
          openCount: openCount,
        ));
      }
      
      // Ordenar por fecha
      trends.sort((a, b) => a.date.compareTo(b.date));
      
      return Right(trends);
    } catch (e) {
      return Left(ServerFailure('Error al calcular tendencias: ${e.toString()}'));
    }
  }

  String _generateCSV(List<dynamic> tickets) {
    final buffer = StringBuffer();
    
    // Encabezados (sin caracteres especiales problemáticos para mejor compatibilidad)
    buffer.writeln('ID,Titulo,Descripcion,Estado,Prioridad,Categoria ID,Asignado a ID,Creado por ID,Fecha de creacion,Fecha de vencimiento,Fecha de cierre');
    
    // Datos
    for (final ticket in tickets) {
      final ticketMap = ticket as Map<String, dynamic>;
      
      // Función auxiliar para escapar valores CSV
      String escapeCsvValue(dynamic value) {
        if (value == null) return '';
        final str = value.toString();
        // Si contiene comas, comillas o saltos de línea, encerrar en comillas y escapar comillas
        if (str.contains(',') || str.contains('"') || str.contains('\n') || str.contains('\r')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }
      
      final row = [
        escapeCsvValue(ticketMap['id']),
        escapeCsvValue(ticketMap['title']),
        escapeCsvValue(ticketMap['description']),
        escapeCsvValue(ticketMap['status']),
        escapeCsvValue(ticketMap['priority']),
        escapeCsvValue(ticketMap['category_id']),
        escapeCsvValue(ticketMap['assigned_to'] ?? 'Sin asignar'),
        escapeCsvValue(ticketMap['created_by']),
        escapeCsvValue(ticketMap['created_at']),
        escapeCsvValue(ticketMap['due_date']),
        escapeCsvValue(ticketMap['closed_at']),
      ];
      buffer.writeln(row.join(','));
    }
    
    return buffer.toString();
  }

  String _generateJSON(List<dynamic> tickets) {
    // Convertir a lista de mapas y luego a JSON
    final List<Map<String, dynamic>> ticketsList = tickets
        .map((t) => Map<String, dynamic>.from(t as Map<String, dynamic>))
        .toList();
    
    // Convertir a JSON con formato legible
    final buffer = StringBuffer();
    buffer.writeln('[');
    for (int i = 0; i < ticketsList.length; i++) {
      final ticket = ticketsList[i];
      buffer.writeln('  {');
      final entries = ticket.entries.toList();
      for (int j = 0; j < entries.length; j++) {
        final entry = entries[j];
        final key = entry.key;
        final value = entry.value;
        final isLast = j == entries.length - 1;
        
        buffer.write('    "$key": ');
        if (value == null) {
          buffer.write('null');
        } else if (value is String) {
          buffer.write('"${value.replaceAll('"', '\\"')}"');
        } else if (value is num || value is bool) {
          buffer.write(value.toString());
        } else {
          buffer.write('"${value.toString().replaceAll('"', '\\"')}"');
        }
        if (!isLast) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('  }');
      if (i < ticketsList.length - 1) buffer.write(',');
      buffer.writeln();
    }
    buffer.writeln(']');
    
    return buffer.toString();
  }
}

// Extensión para calcular el día del año
extension DateTimeExtension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}