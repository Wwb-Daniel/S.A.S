import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/ticket_statistics.dart';
import '../../domain/models/ticket_trends.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../../../core/error/failures.dart';
import '../../../tickets/domain/models/ticket_filters.dart';

@immutable
class ReportsState {
  final bool isLoading;
  final TicketStatistics? statistics;
  final List<TicketTrends>? trends;
  final String? exportData;
  final DateTime? startDate;
  final DateTime? endDate;
  final TicketFilters? filters;
  final Failure? error;

  const ReportsState({
    this.isLoading = false,
    this.statistics,
    this.trends,
    this.exportData,
    this.startDate,
    this.endDate,
    this.filters,
    this.error,
  });

  ReportsState copyWith({
    bool? isLoading,
    TicketStatistics? statistics,
    List<TicketTrends>? trends,
    String? exportData,
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
    Failure? error,
    bool clearError = false,
  }) {
    return ReportsState(
      isLoading: isLoading ?? this.isLoading,
      statistics: statistics ?? this.statistics,
      trends: trends ?? this.trends,
      exportData: exportData ?? this.exportData,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filters: filters ?? this.filters,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReportsNotifier extends StateNotifier<ReportsState> {
  final ReportsRepository _repository;

  ReportsNotifier(this._repository) : super(const ReportsState());

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.getTicketStatistics();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (statistics) => state = state.copyWith(isLoading: false, statistics: statistics),
    );
  }

  Future<void> loadFilteredStatistics({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
  }) async {
    state = state.copyWith(
      isLoading: true, 
      clearError: true,
      startDate: startDate,
      endDate: endDate,
      filters: filters,
    );
    
    final result = await _repository.getFilteredStatistics(
      startDate: startDate,
      endDate: endDate,
      filters: filters,
    );
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (statistics) => state = state.copyWith(isLoading: false, statistics: statistics),
    );
  }

  Future<void> loadTrends({
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.getTicketTrends(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      groupBy: groupBy,
    );
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (trends) => state = state.copyWith(isLoading: false, trends: trends),
    );
  }

  Future<void> exportReport({
    DateTime? startDate,
    DateTime? endDate,
    TicketFilters? filters,
    String format = 'csv',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.exportTicketReport(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      filters: filters ?? state.filters,
      format: format,
    );
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (filePath) => state = state.copyWith(isLoading: false, exportData: filePath),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
  
  void clearExportData() => state = state.copyWith(exportData: null);
  
  void clearFilters() {
    state = state.copyWith(
      filters: null,
      startDate: null,
      endDate: null,
      clearError: true,
    );
    loadStatistics();
  }
}

final reportsProvider = StateNotifierProvider<ReportsNotifier, ReportsState>((ref) {
  return ReportsNotifier(ReportsRepositoryImpl());
});