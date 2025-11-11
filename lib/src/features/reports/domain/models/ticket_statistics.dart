import 'package:flutter/foundation.dart';

@immutable
class TicketStatistics {
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int resolvedTickets;
  final int closedTickets;
  final int overdueTickets;
  final Map<String, int> ticketsByStatus;
  final Map<String, int> ticketsByPriority;
  final Map<String, int> ticketsByCategory;
  final Map<String, int> ticketsByUser;
  final double averageResolutionTime;
  final double averageResponseTime;
  final int ticketsCreatedThisWeek;
  final int ticketsCreatedThisMonth;
  final int ticketsResolvedThisWeek;
  final int ticketsResolvedThisMonth;

  const TicketStatistics({
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
    required this.closedTickets,
    required this.overdueTickets,
    required this.ticketsByStatus,
    required this.ticketsByPriority,
    required this.ticketsByCategory,
    required this.ticketsByUser,
    required this.averageResolutionTime,
    required this.averageResponseTime,
    required this.ticketsCreatedThisWeek,
    required this.ticketsCreatedThisMonth,
    required this.ticketsResolvedThisWeek,
    required this.ticketsResolvedThisMonth,
  });

  factory TicketStatistics.fromMap(Map<String, dynamic> map) {
    return TicketStatistics(
      totalTickets: map['total_tickets'] as int,
      openTickets: map['open_tickets'] as int,
      inProgressTickets: map['in_progress_tickets'] as int,
      resolvedTickets: map['resolved_tickets'] as int,
      closedTickets: map['closed_tickets'] as int,
      overdueTickets: map['overdue_tickets'] as int,
      ticketsByStatus: Map<String, int>.from(map['tickets_by_status'] as Map),
      ticketsByPriority: Map<String, int>.from(map['tickets_by_priority'] as Map),
      ticketsByCategory: Map<String, int>.from(map['tickets_by_category'] as Map),
      ticketsByUser: Map<String, int>.from(map['tickets_by_user'] as Map),
      averageResolutionTime: (map['average_resolution_time'] as num).toDouble(),
      averageResponseTime: (map['average_response_time'] as num).toDouble(),
      ticketsCreatedThisWeek: map['tickets_created_this_week'] as int,
      ticketsCreatedThisMonth: map['tickets_created_this_month'] as int,
      ticketsResolvedThisWeek: map['tickets_resolved_this_week'] as int,
      ticketsResolvedThisMonth: map['tickets_resolved_this_month'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_tickets': totalTickets,
      'open_tickets': openTickets,
      'in_progress_tickets': inProgressTickets,
      'resolved_tickets': resolvedTickets,
      'closed_tickets': closedTickets,
      'overdue_tickets': overdueTickets,
      'tickets_by_status': ticketsByStatus,
      'tickets_by_priority': ticketsByPriority,
      'tickets_by_category': ticketsByCategory,
      'tickets_by_user': ticketsByUser,
      'average_resolution_time': averageResolutionTime,
      'average_response_time': averageResponseTime,
      'tickets_created_this_week': ticketsCreatedThisWeek,
      'tickets_created_this_month': ticketsCreatedThisMonth,
      'tickets_resolved_this_week': ticketsResolvedThisWeek,
      'tickets_resolved_this_month': ticketsResolvedThisMonth,
    };
  }

  TicketStatistics copyWith({
    int? totalTickets,
    int? openTickets,
    int? inProgressTickets,
    int? resolvedTickets,
    int? closedTickets,
    int? overdueTickets,
    Map<String, int>? ticketsByStatus,
    Map<String, int>? ticketsByPriority,
    Map<String, int>? ticketsByCategory,
    Map<String, int>? ticketsByUser,
    double? averageResolutionTime,
    double? averageResponseTime,
    int? ticketsCreatedThisWeek,
    int? ticketsCreatedThisMonth,
    int? ticketsResolvedThisWeek,
    int? ticketsResolvedThisMonth,
  }) {
    return TicketStatistics(
      totalTickets: totalTickets ?? this.totalTickets,
      openTickets: openTickets ?? this.openTickets,
      inProgressTickets: inProgressTickets ?? this.inProgressTickets,
      resolvedTickets: resolvedTickets ?? this.resolvedTickets,
      closedTickets: closedTickets ?? this.closedTickets,
      overdueTickets: overdueTickets ?? this.overdueTickets,
      ticketsByStatus: ticketsByStatus ?? this.ticketsByStatus,
      ticketsByPriority: ticketsByPriority ?? this.ticketsByPriority,
      ticketsByCategory: ticketsByCategory ?? this.ticketsByCategory,
      ticketsByUser: ticketsByUser ?? this.ticketsByUser,
      averageResolutionTime: averageResolutionTime ?? this.averageResolutionTime,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
      ticketsCreatedThisWeek: ticketsCreatedThisWeek ?? this.ticketsCreatedThisWeek,
      ticketsCreatedThisMonth: ticketsCreatedThisMonth ?? this.ticketsCreatedThisMonth,
      ticketsResolvedThisWeek: ticketsResolvedThisWeek ?? this.ticketsResolvedThisWeek,
      ticketsResolvedThisMonth: ticketsResolvedThisMonth ?? this.ticketsResolvedThisMonth,
    );
  }

  double get resolutionRate {
    if (totalTickets == 0) return 0.0;
    return (resolvedTickets + closedTickets) / totalTickets * 100;
  }

  double get overdueRate {
    if (totalTickets == 0) return 0.0;
    return overdueTickets / totalTickets * 100;
  }

  Map<String, dynamic> get statusPercentages {
    if (totalTickets == 0) return {};
    return {
      'abierto': (openTickets / totalTickets * 100).roundToDouble(),
      'en_progreso': (inProgressTickets / totalTickets * 100).roundToDouble(),
      'resuelto': (resolvedTickets / totalTickets * 100).roundToDouble(),
      'cerrado': (closedTickets / totalTickets * 100).roundToDouble(),
    };
  }
}