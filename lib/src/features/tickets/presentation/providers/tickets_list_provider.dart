import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../tickets/data/repositories/tickets_repository_impl.dart';
import '../../../tickets/domain/models/ticket.dart';
import '../../../tickets/domain/models/ticket_filters.dart';
import '../../../tickets/domain/repositories/tickets_repository.dart';
import '../../../../core/error/failures.dart';

@immutable
class TicketsListState {
  final bool isLoading;
  final List<Ticket> tickets;
  final TicketFilters? filters;
  final Failure? error;

  const TicketsListState({
    this.isLoading = false,
    this.tickets = const [],
    this.filters,
    this.error,
  });

  TicketsListState copyWith({
    bool? isLoading,
    List<Ticket>? tickets,
    TicketFilters? filters,
    Failure? error,
    bool clearError = false,
  }) {
    return TicketsListState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      filters: filters ?? this.filters,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TicketsListNotifier extends StateNotifier<TicketsListState> {
  final TicketsRepository _repo;

  TicketsListNotifier(this._repo) : super(const TicketsListState());

  Future<void> load({TicketFilters? filters}) async {
    state = state.copyWith(isLoading: true, clearError: true, filters: filters);
    final result = await _repo.listTickets(filters: filters);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (data) => state = state.copyWith(isLoading: false, tickets: data),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final ticketsListProvider = StateNotifierProvider<TicketsListNotifier, TicketsListState>((ref) {
  return TicketsListNotifier(TicketsRepositoryImpl());
});
