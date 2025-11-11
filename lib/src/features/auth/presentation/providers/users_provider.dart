import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user.dart' as app;
import '../../../../core/error/failures.dart';

@immutable
class UsersState {
  final bool isLoading;
  final List<app.User> users;
  final Failure? error;

  const UsersState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });

  UsersState copyWith({
    bool? isLoading,
    List<app.User>? users,
    Failure? error,
    bool clearError = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final SupabaseClient _client;

  UsersNotifier(this._client) : super(const UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final response = await _client.from('users').select('''
        id,
        email,
        first_name,
        last_name,
        phone,
        role,
        created_at,
        updated_at
      ''');

      final users = (response as List)
          .map((e) => app.User.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();

      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ServerFailure('Error al cargar usuarios: ${e.toString()}'),
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(Supabase.instance.client);
});