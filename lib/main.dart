import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:shared_preferences/shared_preferences.dart';

import 'src/core/config/supabase_config.dart';
import 'src/core/localization/app_localizations.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/domain/models/auth_models.dart' as auth_models;
import 'src/features/auth/presentation/screens/login_screen.dart';
import 'src/features/auth/presentation/screens/register_screen.dart';
import 'src/features/auth/presentation/screens/verify_email_screen.dart';
import 'src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'src/features/profile/presentation/screens/profile_screen.dart';
import 'src/features/tickets/presentation/screens/tickets_list_screen.dart';
import 'src/features/tickets/presentation/screens/ticket_create_screen.dart';
import 'src/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'src/features/notifications/presentation/screens/notifications_screen.dart';
import 'src/features/reports/presentation/screens/reports_screen.dart';

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final auth_models.AuthUser? user;
  final String? error;

  const AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    auth_models.AuthUser? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(auth_models.AuthUser user) => 
      AuthState(isAuthenticated: true, user: user, isLoading: false);
  factory AuthState.unauthenticated() => 
      const AuthState(isAuthenticated: false, isLoading: false);
  factory AuthState.error(String error) => 
      AuthState(error: error, isLoading: false);
}

// Proveedor de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._supabase) : super(AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    // Verificar sesión al iniciar
    await _checkAuthState();
    
    // Escuchar cambios en la autenticación
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      await _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    try {
      final session = _supabase.auth.currentSession;
      
      if (session != null) {
        final user = session.user;
        state = AuthState.authenticated(
          auth_models.AuthUser(
            id: user.id,
            email: user.email ?? '',
            isEmailVerified: user.emailConfirmedAt != null,
          ),
        );
        return;
      }
      
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Error al verificar la sesión: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = AuthState.loading();
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('No se pudo iniciar sesión');
      }
      
      await _checkAuthState();
    } catch (e) {
      state = AuthState.error('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Error al cerrar sesión: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Proveedor global
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(Supabase.instance.client);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    debug: true,
    // authFlowType: AuthFlowType.pkce, // Comentado temporalmente
  );
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

// Provider para gestionar el idioma
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es', '')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'es';
    state = Locale(languageCode, '');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}

final router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/register';

    // Si la autenticación aún está cargando, no redirigir
    if (authState.isLoading) {
      return null;
    }

    // Si el usuario no está autenticado y no está en login/register, redirigir a login
    if (!authState.isAuthenticated && !isLoggingIn && !isRegistering) {
      return '/login';
    }

    // Si el usuario está autenticado y está en login/register, redirigir al dashboard
    if (authState.isAuthenticated && (isLoggingIn || isRegistering)) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/tickets',
      builder: (context, state) => const TicketsListScreen(),
    ),
    GoRoute(
      path: '/tickets/new',
      builder: (context, state) => const TicketCreateScreen(),
    ),
    GoRoute(
      path: '/tickets/:id',
      builder: (context, state) => TicketDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      redirect: (context, state) => '/',
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    // Mostrar pantalla de carga mientras se verifica la autenticación
    if (authState.isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    return MaterialApp.router(
      title: 'Sistema de Tickets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D47A1), // Azul oscuro
                Color(0xFF1976D2), // Azul intermedio
                Color(0xFF42A5F5), // Azul claro
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}
