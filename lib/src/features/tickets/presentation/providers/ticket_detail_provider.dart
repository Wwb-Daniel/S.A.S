import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/tickets_repository_impl.dart';
import '../../domain/models/ticket.dart';
import '../../domain/models/ticket_comment.dart';
import '../../domain/models/ticket_attachment.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../../../../core/error/failures.dart';

@immutable
class TicketDetailState {
  final bool isLoading;
  final Ticket? ticket;
  final List<TicketComment> comments;
  final List<TicketAttachment> attachments;
  final Failure? error;

  const TicketDetailState({
    this.isLoading = false,
    this.ticket,
    this.comments = const [],
    this.attachments = const [],
    this.error,
  });

  TicketDetailState copyWith({
    bool? isLoading,
    Ticket? ticket,
    List<TicketComment>? comments,
    List<TicketAttachment>? attachments,
    Failure? error,
    bool clearError = false,
  }) {
    return TicketDetailState(
      isLoading: isLoading ?? this.isLoading,
      ticket: ticket ?? this.ticket,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TicketDetailNotifier extends StateNotifier<TicketDetailState> {
  final TicketsRepository _repo;
  RealtimeChannel? _channel;

  TicketDetailNotifier(this._repo) : super(const TicketDetailState());

  Future<void> load(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tRes = await _repo.getTicket(id);
      Ticket? t;
      await tRes.fold((f) async {
        state = state.copyWith(isLoading: false, error: f);
      }, (data) async {
        t = data;
        state = state.copyWith(ticket: data);
      });
      if (t == null) return;

      final cRes = await _repo.listComments(id);
      cRes.fold((f) => state = state.copyWith(error: f), (list) => state = state.copyWith(comments: list));

      final aRes = await _repo.listAttachments(id);
      aRes.fold((f) => state = state.copyWith(error: f), (list) => state = state.copyWith(attachments: list));

      state = state.copyWith(isLoading: false);

      _subscribeToComments(id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ServerFailure(e.toString()));
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> updateStatus(String id, String newStatus) async {
    try {
      final res = await _repo.updateTicketFields(id, status: newStatus);
      return res.fold(
        (f) {
          state = state.copyWith(error: f);
          return false;
        },
        (t) {
          state = state.copyWith(ticket: t);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: ServerFailure(e.toString()));
      return false;
    }
  }

  Future<bool> updatePriority(String id, String newPriority) async {
    try {
      final res = await _repo.updateTicketFields(id, priority: newPriority);
      return res.fold(
        (f) {
          state = state.copyWith(error: f);
          return false;
        },
        (t) {
          state = state.copyWith(ticket: t);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: ServerFailure(e.toString()));
      return false;
    }
  }

  Future<bool> addComment(String ticketId, String content, {bool isInternal = false}) async {
    try {
      final res = await _repo.createComment(ticketId: ticketId, content: content, isInternal: isInternal);
      return res.fold(
        (f) {
          state = state.copyWith(error: f);
          return false;
        },
        (_) {
          // Recargar comentarios
          return _repo.listComments(ticketId).then((r) {
            return r.fold(
              (f) {
                state = state.copyWith(error: f);
                return false;
              },
              (list) {
                state = state.copyWith(comments: list);
                return true;
              },
            );
          });
        },
      );
    } catch (e) {
      state = state.copyWith(error: ServerFailure(e.toString()));
      return false;
    }
  }

  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      final res = await _repo.deleteAttachment(attachmentId);
      final ok = res.fold((f) {
        state = state.copyWith(error: f);
        return false;
      }, (_) => true);
      if (!ok || state.ticket == null) return ok;
      final aRes = await _repo.listAttachments(state.ticket!.id);
      aRes.fold(
        (f) => state = state.copyWith(error: f),
        (list) => state = state.copyWith(attachments: list),
      );
      return ok;
    } catch (e) {
      state = state.copyWith(error: ServerFailure(e.toString()));
      return false;
    }
  }

  Future<bool> updateDueDate(String id, DateTime date) async {
    try {
      final res = await _repo.updateTicketFields(id, dueDate: date);
      return res.fold(
        (f) {
          state = state.copyWith(error: f);
          return false;
        },
        (t) {
          state = state.copyWith(ticket: t);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: ServerFailure(e.toString()));
      return false;
    }
  }

  void _subscribeToComments(String ticketId) {
    // Cancel existing
    _channel?.unsubscribe();
    final client = Supabase.instance.client;
    _channel = client
        .channel('comments_ticket_$ticketId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ticket_comments',
          callback: (payload) async {
            final newRecord = payload.newRecord;
            if (newRecord['ticket_id'] == ticketId) {
              final res = await _repo.listComments(ticketId);
              res.fold(
                (f) => state = state.copyWith(error: f),
                (list) => state = state.copyWith(comments: list),
              );
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final ticketDetailProvider = StateNotifierProvider<TicketDetailNotifier, TicketDetailState>((ref) {
  return TicketDetailNotifier(TicketsRepositoryImpl());
});
