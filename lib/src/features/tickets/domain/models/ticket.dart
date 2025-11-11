import 'package:flutter/foundation.dart';

@immutable
class Ticket {
  final String id;
  final String title;
  final String description;
  final String status; // 'abierto', 'en_progreso', 'en_revision', 'resuelto', 'cerrado'
  final String priority; // 'baja', 'media', 'alta', 'urgente'
  final int? categoryId;
  final String companyId;
  final String createdBy;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final String? closedBy;
  final String? resolution;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.categoryId,
    required this.companyId,
    required this.createdBy,
    required this.assignedTo,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.closedAt,
    required this.closedBy,
    required this.resolution,
  });

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      status: map['status'] as String,
      priority: map['priority'] as String,
      categoryId: map['category_id'] as int?,
      companyId: map['company_id'] as String,
      createdBy: map['created_by'] as String,
      assignedTo: map['assigned_to'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      closedAt: map['closed_at'] != null ? DateTime.parse(map['closed_at'] as String) : null,
      closedBy: map['closed_by'] as String?,
      resolution: map['resolution'] as String?,
    );
  }
}
