import 'package:equatable/equatable.dart';

class TicketTrends extends Equatable {
  final DateTime date;
  final int createdCount;
  final int resolvedCount;
  final int closedCount;
  final int openCount;

  const TicketTrends({
    required this.date,
    required this.createdCount,
    required this.resolvedCount,
    required this.closedCount,
    required this.openCount,
  });

  factory TicketTrends.fromMap(Map<String, dynamic> map) {
    return TicketTrends(
      date: DateTime.parse(map['date'] as String),
      createdCount: map['created_count'] as int? ?? 0,
      resolvedCount: map['resolved_count'] as int? ?? 0,
      closedCount: map['closed_count'] as int? ?? 0,
      openCount: map['open_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'created_count': createdCount,
      'resolved_count': resolvedCount,
      'closed_count': closedCount,
      'open_count': openCount,
    };
  }

  TicketTrends copyWith({
    DateTime? date,
    int? createdCount,
    int? resolvedCount,
    int? closedCount,
    int? openCount,
  }) {
    return TicketTrends(
      date: date ?? this.date,
      createdCount: createdCount ?? this.createdCount,
      resolvedCount: resolvedCount ?? this.resolvedCount,
      closedCount: closedCount ?? this.closedCount,
      openCount: openCount ?? this.openCount,
    );
  }

  @override
  List<Object?> get props => [
        date,
        createdCount,
        resolvedCount,
        closedCount,
        openCount,
      ];

  @override
  String toString() {
    return 'TicketTrends(date: $date, createdCount: $createdCount, '
           'resolvedCount: $resolvedCount, closedCount: $closedCount, '
           'openCount: $openCount)';
  }
}