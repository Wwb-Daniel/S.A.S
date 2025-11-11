import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
  // Obtener el usuario actual
  Future<AuthUser> getCurrentUser();

  // Iniciar sesión con correo y contraseña
  Future<Either<Failure, AuthResponse>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  // Registrar una nueva empresa y su administrador
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
  });

  // Paso 1: Registro básico (solo Auth)
  Future<Either<Failure, void>> signUpBasic({
    required String email,
    required String password,
    required String fullName,
  });

  // Registrar un nuevo empleado (solo administradores)
  Future<Either<Failure, UserProfile>> signUpEmployee({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? position,
    String? department,
    String? phone,
  });

  // Cerrar sesión
  Future<Either<Failure, void>> signOut();

  // Enviar correo de restablecimiento de contraseña
  Future<Either<Failure, void>> resetPassword(String email);

  // Verificar si el correo está verificado
  Future<bool> isEmailVerified();

  // Enviar correo de verificación
  Future<Either<Failure, void>> sendEmailVerification();

  // Actualizar perfil de usuario
  Future<Either<Failure, void>> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  });

  // Actualizar contraseña
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Obtener perfil de usuario
  Future<Either<Failure, UserProfile>> getUserProfile();

  // Actualizar token FCM
  Future<Either<Failure, void>> updateFcmToken(String token);

  // Stream de cambios en el estado de autenticación
  Stream<AuthUser> get onAuthStateChanged;

  // Paso 2: Completar registro (crear empresa y perfil para usuario actual)
  Future<Either<Failure, void>> completeCompanyRegistration({
    required String companyName,
    required String companyRuc,
    String? companyAddress,
    String? phone,
    String? fullName,
    String? country,
    String? language,
  });
}
