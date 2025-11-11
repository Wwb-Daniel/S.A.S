import 'package:dartz/dartz.dart';
import 'package:mi_app_multiplataforma/src/core/error/failures.dart';
import '../models/notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationModel>>> getUnreadNotifications(String employeeId);
  Future<Either<Failure, List<NotificationModel>>> getAllNotifications(String employeeId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String employeeId);
  Stream<List<NotificationModel>> subscribeToNotifications(String employeeId);
  Future<Either<Failure, int>> getUnreadCount(String employeeId);
}