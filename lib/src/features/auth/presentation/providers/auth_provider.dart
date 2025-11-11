import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/auth_injector.dart';
import '../../domain/models/auth_models.dart';

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(AuthUser user) => AuthState(
        user: user,
        isAuthenticated: true,
      );
  factory AuthState.unauthenticated() => const AuthState(isAuthenticated: false);
  factory AuthState.error(String error) => AuthState(error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  
  AuthNotifier(this.ref) : super(AuthState.initial()) {
    // Escuchar cambios en la autenticación
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Obtener el usuario actual al iniciar
    _getCurrentUser();
    
    // Escuchar cambios en la autenticación
    final authRepo = ref.read(authRepositoryProvider);
    authRepo.onAuthStateChanged.listen((user) {
      if (user.isNotEmpty) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  Future<void> _getCurrentUser() async {
    state = AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user.isNotEmpty) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error('Error al obtener el usuario actual: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    state = AuthState.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmailAndPassword(email: email, password: password);

    result.fold(
      (failure) => state = AuthState.error(failure.toString()),
      (authResponse) {
        if (authResponse.hasError) {
          state = AuthState.error(authResponse.error!);
        } else {
          state = AuthState.authenticated(authResponse.user);
        }
      },
    );
  }

  Future<void> signUpCompany({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String companyName,
    required String companyRuc,
    String? companyAddress,
    String? country,
    String? language,
    String? companyLogoUrl,
  }) async {
    state = AuthState.loading();
    final result = await ref
        .read(authRepositoryProvider)
        .signUpCompany(
          email: email,
          password: password,
          fullName: fullName,
          phone: phone,
          companyName: companyName,
          companyRuc: companyRuc,
          companyAddress: companyAddress,
          country: country,
          language: language,
          companyLogoUrl: companyLogoUrl,
        );

    result.fold(
      (failure) => state = AuthState.error(failure.toString()),
      (authResponse) {
        if (authResponse.hasError) {
          state = AuthState.error(authResponse.error!);
        } else {
          state = AuthState.authenticated(authResponse.user);
        }
      },
    );
  }

  Future<void> signOut() async {
    state = AuthState.loading();
    final result = await ref.read(authRepositoryProvider).signOut();
    result.fold(
      (failure) => state = AuthState.error(failure.toString()),
      (_) => state = AuthState.unauthenticated(),
    );
  }

  Future<void> resetPassword(String email) async {
    state = AuthState.loading();
    final result = await ref.read(authRepositoryProvider).resetPassword(email);
    result.fold(
      (failure) => state = AuthState.error(failure.toString()),
      (_) => state = AuthState.unauthenticated(),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
