import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../../../core/error/failures.dart';

@immutable
class NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final Failure? error;

  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    Failure? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repository;
  String? _currentEmployeeId;
  StreamSubscription<List<NotificationModel>>? _subscription;

  NotificationsNotifier(this._repository) : super(const NotificationsState());

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications(String employeeId) async {
    // Cancelar suscripción anterior si existe
    await _subscription?.cancel();
    _subscription = null;

    _currentEmployeeId = employeeId;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Cargar notificaciones y conteo de no leídas en paralelo
      final notificationsResult = await _repository.getAllNotifications(employeeId);
      
      await notificationsResult.fold(
        (failure) async {
          state = state.copyWith(isLoading: false, error: failure);
        },
        (notifications) async {
          // Cargar conteo de no leídas
          final countResult = await _repository.getUnreadCount(employeeId);
          countResult.fold(
            (failure) {
              // Si falla el conteo, usar las notificaciones cargadas y calcular el conteo localmente
              final unreadCount = notifications.where((n) => !n.isRead).length;
              state = state.copyWith(
                notifications: notifications,
                unreadCount: unreadCount,
                isLoading: false,
                clearError: true,
              );
            },
            (unreadCount) {
              state = state.copyWith(
                notifications: notifications,
                unreadCount: unreadCount,
                isLoading: false,
                clearError: true,
              );
            },
          );
        },
      );

      // Suscribirse a cambios en tiempo real solo si la carga fue exitosa
      if (!state.isLoading && state.error == null) {
        _subscribeToNotifications(employeeId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: ServerFailure(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure);
      },
      (_) {
        // Actualizar el estado local
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
          clearError: true,
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    if (_currentEmployeeId == null) return;

    final result = await _repository.markAllAsRead(_currentEmployeeId!);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure);
      },
      (_) {
        // Actualizar todas las notificaciones como leídas
        final updatedNotifications = state.notifications.map((notification) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
          clearError: true,
        );
      },
    );
  }

  void _subscribeToNotifications(String employeeId) {
    // Cancelar suscripción anterior si existe
    _subscription?.cancel();
    
    _subscription = _repository.subscribeToNotifications(employeeId).listen(
      (notifications) {
        // Calcular conteo de no leídas localmente para evitar llamadas adicionales
        final unreadCount = notifications.where((n) => !n.isRead).length;
        
        // Solo actualizar si el estado no está cargando para evitar bucles
        if (!state.isLoading) {
          state = state.copyWith(
            notifications: notifications,
            unreadCount: unreadCount,
            clearError: true,
          );
        }
      },
      onError: (error) {
        // Solo actualizar error si no está cargando
        if (!state.isLoading) {
          state = state.copyWith(error: ServerFailure(error.toString()));
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(NotificationsRepositoryImpl());
});