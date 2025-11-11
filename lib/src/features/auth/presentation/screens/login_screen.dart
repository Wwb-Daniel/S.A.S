import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../providers/auth_provider.dart';
import '../widgets/liquid_gradient_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  static const _preferredLogo = 'assets/images/web_logo.webp';
  static const _fallbackLogo = 'flutter_01.png';

  Future<String?> _resolveLogo() async {
    try {
      await rootBundle.load(_preferredLogo);
      return _preferredLogo;
    } catch (_) {
      try {
        await rootBundle.load(_fallbackLogo);
        return _fallbackLogo;
      } catch (_) {
        return null;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      await ref.read(authProvider.notifier).signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (mounted) {
          context.go('/');
        }
      } else if (next.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LiquidGradientBackground(),
          // Capa para uniformar contraste
          Container(color: Colors.black.withOpacity(0.10)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre de la empresa (sin logo)
                    Column(
                      children: [
                        Text(
                          'P&B Construcciones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white.withOpacity(0.22)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.04),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(28.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.lock_outline, size: 40, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Iniciar Sesión',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ingrese sus datos para iniciar sesión',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (authState.error != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        authState.error!,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    enabled: !authState.isLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese su correo electrónico';
                                      }
if (!RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(value)) {
                                        return 'Por favor ingrese un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                      ),
                                    ),
                                    obscureText: _obscure,
                                    enabled: !authState.isLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingrese su contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: authState.isLoading
                                          ? null
                                          : () {
                                              // TODO: navegación a recuperación de contraseña
                                            },
                                      child: const Text('Olvidé mi contraseña'),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FilledButton(
                                    onPressed: authState.isLoading ? null : _signIn,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Text('Siguiente'),
                                  ),
                                  const SizedBox(height: 16),
                                  // Social
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'O iniciar sesión con:',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.white.withOpacity(0.9),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 10,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: authState.isLoading ? null : () {},
                                            icon: const Icon(Icons.g_mobiledata_outlined),
                                            label: const Text('Google'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: authState.isLoading ? null : () {},
                                            icon: const Icon(Icons.window_outlined),
                                            label: const Text('Microsoft'),
                                          ),
                                          OutlinedButton.icon(
                                            onPressed: authState.isLoading ? null : () {},
                                            icon: const Icon(Icons.shield_outlined),
                                            label: const Text('SAML'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      TextButton(
                                        onPressed: authState.isLoading ? null : () => context.push('/register'),
                                        child: const Text('¿No tienes una cuenta? Regístrate'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Footer
                    Column(
                      children: [
                        Text(
                          'v1.0.0',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: soporte técnico
                          },
                          icon: const Icon(Icons.support_agent_outlined),
                          label: const Text('Soporte Técnico'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Al iniciar sesión, aceptas Términos y Condiciones y Políticas de Privacidad',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
