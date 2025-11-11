import 'package:dartz/dartz.dart';
import 'package:mi_app_multiplataforma/src/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final SupabaseClient _client;
  
  NotificationsRepositoryImpl({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<NotificationModel>>> getUnreadNotifications(String employeeId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('employee_id', employeeId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromMap(json as Map<String, dynamic>))
          .toList();

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('Error al obtener notificaciones no leídas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getAllNotifications(String employeeId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('employee_id', employeeId)
          .order('created_at', ascending: false);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromMap(json as Map<String, dynamic>))
          .toList();

      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure('Error al obtener notificaciones: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al marcar notificación como leída: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String employeeId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('employee_id', employeeId)
          .eq('is_read', false);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al marcar todas las notificaciones como leídas: $e'));
    }
  }

  @override
  Stream<List<NotificationModel>> subscribeToNotifications(String employeeId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('employee_id', employeeId)
        .map((data) => data
            .map((json) => NotificationModel.fromMap(json as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String employeeId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('employee_id', employeeId)
          .eq('is_read', false);

      final count = (response as List).length;
      return Right(count);
    } catch (e) {
      return Left(ServerFailure('Error al obtener conteo de notificaciones no leídas: $e'));
    }
  }
}