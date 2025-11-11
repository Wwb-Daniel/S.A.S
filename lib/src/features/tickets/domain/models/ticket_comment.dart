import 'package:flutter/foundation.dart';

@immutable
class TicketComment {
  final String id;
  final String ticketId;
  final String employeeId;
  final String comment;
  final bool isInternal;
  final DateTime createdAt;

  const TicketComment({
    required this.id,
    required this.ticketId,
    required this.employeeId,
    required this.comment,
    required this.isInternal,
    required this.createdAt,
  });

  factory TicketComment.fromMap(Map<String, dynamic> map) {
    return TicketComment(
      id: map['id'] as String,
      ticketId: map['ticket_id'] as String,
      employeeId: map['employee_id'] as String,
      comment: map['comment'] as String,
      isInternal: (map['is_internal'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
