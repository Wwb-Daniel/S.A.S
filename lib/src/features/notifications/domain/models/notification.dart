import 'package:flutter/foundation.dart';

@immutable
class NotificationModel {
  final String id;
  final String employeeId;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'error', 'success'
  final String? relatedTicketId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.employeeId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedTicketId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      relatedTicketId: map['related_ticket_id'] as String?,
      isRead: map['is_read'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at'] as String) : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? employeeId,
    String? title,
    String? message,
    String? type,
    String? relatedTicketId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedTicketId: relatedTicketId ?? this.relatedTicketId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}