import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/error/failures.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/config/supabase_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _supabase = SupabaseConfig.client;
  final supabase.GoTrueClient _auth = SupabaseConfig.auth;

  @override
  Future<AuthUser> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return AuthUser.empty;

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      phone: user.phone,
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  @override
  Future<Either<Failure, void>> completeCompanyRegistration({
    required String companyName,
    required String companyRuc,
    String? companyAddress,
    String? phone,
    String? fullName,
    String? country,
    String? language,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      final companyResponse = await _supabase
          .from('companies')
          .insert({
            'name': companyName,
            'ruc': companyRuc,
            'email': user.email,
            if (phone != null) 'phone': phone,
            if (companyAddress != null) 'address': companyAddress,
            if (country != null) 'country': country,
            if (language != null) 'language': language,
          })
          .select()
          .single();

      final profileData = {
        'id': user.id,
        'email': user.email,
        'full_name': fullName ?? user.userMetadata?['full_name'],
        'company_id': companyResponse['id'],
        'role': 'company_admin',
        'position': 'Administrador',
        if (phone != null) 'phone': phone,
        'status': 'active',
      };

      await _supabase.from('employees').upsert(profileData);

      return const Right(null);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al completar el registro: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signUpBasic({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error en el registro básico: $e'));
    }
  }

  @override
  Stream<AuthUser> get onAuthStateChanged {
    return _auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return AuthUser.empty;

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        phone: user.phone,
        isEmailVerified: user.emailConfirmedAt != null,
      );
    });
  }

  @override
  Future<Either<Failure, AuthResponse>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Left(ServerFailure('No se pudo iniciar sesión. Intente nuevamente.'));
      }

      // Obtener el perfil del usuario desde la tabla employees
      final profile = await _getUserProfile(user.id);
      if (profile == null) {
        await _auth.signOut();
        return const Left(ServerFailure('Perfil de usuario no encontrado.'));
      }

      return Right(
        AuthResponse(
          user: AuthUser(
            id: user.id,
            email: user.email ?? '',
            phone: user.phone,
            fullName: profile.fullName,
            companyId: profile.companyId,
            role: profile.role,
            isEmailVerified: user.emailConfirmedAt != null,
          ),
          sessionId: response.session?.accessToken,
        ),
      );
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al iniciar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signUpCompany({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String companyName,
    String? companyRuc,
    String? companyAddress,
    String? country,
    String? language,
    String? companyLogoUrl,
  }) async {
    try {
      // Crear la empresa
      final companyResponse = await _supabase
          .from('companies')
          .insert({
            'name': companyName,
            if (companyRuc != null && companyRuc.isNotEmpty) 'ruc': companyRuc,
            'email': email,
            'phone': phone,
            if (companyAddress != null) 'address': companyAddress,
            if (country != null) 'country': country,
            if (language != null) 'language': language,
            if (companyLogoUrl != null && companyLogoUrl.isNotEmpty) 'logo_url': companyLogoUrl,
          })
          .select()
          .single();

      // Registrar el usuario en Supabase Auth
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'company_admin', // Rol de administrador de empresa
        },
      );

      final user = response.user;
      if (user == null) {
        return const Left(ServerFailure('No se pudo crear el usuario. Intente nuevamente.'));
      }

      // Crear el perfil del empleado (administrador de la empresa)
      await _supabase.from('employees').insert({
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'company_id': companyResponse['id'],
        'role': 'company_admin', // Rol de administrador de empresa
        'position': 'Administrador',
        'phone': phone,
        'status': 'active',
      });

      return Right(
        AuthResponse(
          user: AuthUser(
            id: user.id,
            email: user.email ?? '',
            phone: phone,
            fullName: fullName,
            companyId: companyResponse['id'],
            role: 'company_admin',
            isEmailVerified: false,
          ),
          sessionId: response.session?.accessToken,
        ),
      );
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al registrar la empresa: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signUpEmployee({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? position,
    String? department,
    String? phone,
  }) async {
    try {
      // Obtener el perfil del usuario actual (debe ser administrador)
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('No autenticado'));
      }

      // Verificar si el usuario actual es administrador
      final currentProfile = await _getUserProfile(currentUser.id);
      if (currentProfile == null || currentProfile.role != 'company_admin') {
        return const Left(ServerFailure('No autorizado'));
      }

      // Registrar el nuevo usuario en Supabase Auth
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        return const Left(ServerFailure('No se pudo crear el empleado. Intente nuevamente.'));
      }

      // Crear el perfil del empleado
      final profileData = {
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'company_id': currentProfile.companyId,
        'role': role,
        'position': position,
        'department': department,
        'phone': phone,
        'status': 'active',
      };

      final profileResponse = await _supabase
          .from('employees')
          .insert(profileData)
          .select()
          .single();

      return Right(UserProfile.fromJson(profileResponse));
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al registrar el empleado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error al cerrar sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al restablecer la contraseña: $e'));
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      await _auth.resend(
        type: supabase.OtpType.signup,
        email: user.email!,
      );

      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al enviar el correo de verificación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (position != null) updates['position'] = position;
      if (department != null) updates['department'] = department;
      if (phone != null) updates['phone'] = phone;

      if (updates.isNotEmpty) {
        await _supabase
            .from('employees')
            .update(updates)
            .eq('id', user.id);
      }

      return const Right(null);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al actualizar el perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      // Actualizar la contraseña
      await _auth.updateUser(
        supabase.UserAttributes(
          password: newPassword,
        ),
      );

      return const Right(null);
    } on supabase.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al actualizar la contraseña: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      final profile = await _getUserProfile(user.id);
      if (profile == null) {
        return const Left(ServerFailure('Perfil no encontrado'));
      }

      return Right(profile);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al obtener el perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('Usuario no autenticado'));
      }

      await _supabase
          .from('employees')
          .update({'fcm_token': token})
          .eq('id', user.id);

      return const Right(null);
    } on supabase.PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al actualizar el token: $e'));
    }
  }

  // Método auxiliar para obtener el perfil del usuario
  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
