import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/notifications_screen.dart';
import '../providers/notifications_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotificationsIcon extends ConsumerWidget {
  const NotificationsIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final user = ref.watch(authProvider).user;

    // Cargar notificaciones si no están cargadas y hay usuario
    if (user != null && notificationsState.notifications.isEmpty && !notificationsState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationsProvider.notifier).loadNotifications(user.id);
      });
    }

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            context.push('/notifications');
          },
        ),
        if (notificationsState.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  notificationsState.unreadCount > 99 
                      ? '99+' 
                      : notificationsState.unreadCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}