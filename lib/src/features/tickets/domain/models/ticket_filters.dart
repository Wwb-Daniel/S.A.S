import 'package:flutter/foundation.dart';

@immutable
class TicketFilters {
  final String? status;
  final String? priority;
  final int? categoryId;
  final String? assignedTo;
  final String? createdBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isOverdue;
  final String? searchQuery;

  const TicketFilters({
    this.status,
    this.priority,
    this.categoryId,
    this.assignedTo,
    this.createdBy,
    this.startDate,
    this.endDate,
    this.isOverdue,
    this.searchQuery,
  });

  TicketFilters copyWith({
    String? status,
    String? priority,
    int? categoryId,
    String? assignedTo,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOverdue,
    String? searchQuery,
  }) {
    return TicketFilters(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOverdue: isOverdue ?? this.isOverdue,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isEmpty {
    return status == null &&
           priority == null &&
           categoryId == null &&
           assignedTo == null &&
           createdBy == null &&
           startDate == null &&
           endDate == null &&
           isOverdue == null &&
           (searchQuery == null || searchQuery!.isEmpty);
  }

  bool get hasActiveFilters => !isEmpty;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    if (categoryId != null) params['category_id'] = categoryId;
    if (assignedTo != null) params['assigned_to'] = assignedTo;
    if (createdBy != null) params['created_by'] = createdBy;
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    if (isOverdue != null) params['is_overdue'] = isOverdue;
    if (searchQuery != null && searchQuery!.isNotEmpty) params['search'] = searchQuery;
    
    return params;
  }

  @override
  String toString() {
    return 'TicketFilters(status: $status, priority: $priority, categoryId: $categoryId, '
           'assignedTo: $assignedTo, createdBy: $createdBy, startDate: $startDate, '
           'endDate: $endDate, isOverdue: $isOverdue, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TicketFilters &&
           other.status == status &&
           other.priority == priority &&
           other.categoryId == categoryId &&
           other.assignedTo == assignedTo &&
           other.createdBy == createdBy &&
           other.startDate == startDate &&
           other.endDate == endDate &&
           other.isOverdue == isOverdue &&
           other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    return status.hashCode ^
           priority.hashCode ^
           categoryId.hashCode ^
           assignedTo.hashCode ^
           createdBy.hashCode ^
           startDate.hashCode ^
           endDate.hashCode ^
           isOverdue.hashCode ^
           searchQuery.hashCode;
  }
}