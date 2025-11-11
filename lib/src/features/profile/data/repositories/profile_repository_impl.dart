import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/auth/domain/models/auth_models.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile);
    } on UnauthenticatedException {
      return const Left(AuthenticationFailure('No autenticado'));
    } on ServerException catch (e) {
      return Left(ServerFailure('Error del servidor: ${e.message}'));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure('Error de autenticación: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }

  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  }) async {
    try {
      final updatedProfile = await remoteDataSource.updateProfile(
        fullName: fullName,
        phone: phone,
        position: position,
        department: department,
      );
      return Right(updatedProfile);
    } on UnauthenticatedException {
      return const Left(AuthenticationFailure('No autenticado'));
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al actualizar el perfil: ${e.message}'));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure('Error de autenticación: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al actualizar: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validar longitud mínima de contraseña
      if (newPassword.length < 6) {
        return const Left(ValidationFailure('La nueva contraseña debe tener al menos 6 caracteres'));
      }
      
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return const Right(unit);
    } on UnauthenticatedException {
      return const Left(AuthenticationFailure('Sesión expirada. Por favor, inicia sesión nuevamente.'));
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al actualizar la contraseña: ${e.message}'));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure('Error de autenticación: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, String>> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Validar el tipo de archivo
      final validMimeTypes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/svg+xml'
      ];
      
      // Obtener información del archivo
      final filePath = imageFile.path;
      print('Validando archivo:');
      print('  - Ruta: $filePath');
      
      // Para web, necesitamos manejar el caso especial de blob URLs
      if (filePath.startsWith('blob:')) {
        // En web, confiamos en que el selector de archivos ya validó el tipo
        print('  - Archivo web detectado (blob), saltando validación de extensión');
      } else {
        // Para plataformas móviles, validar la extensión
        final filePathLower = filePath.toLowerCase();
        final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
        final fileExt = filePath.contains('.') ? filePath.split('.').last.toLowerCase() : '';
        
        print('  - Extensión detectada: $fileExt');
        print('  - Extensiones válidas: $validExtensions');
        
        final isValid = validExtensions.any((ext) => filePathLower.endsWith('.$ext'));
        print('  - ¿Extensión válida? $isValid');
        
        if (!isValid) {
          print('  - Error: Formato de archivo no soportado');
          return Left(ServerFailure('Formato de archivo no soportado. Usa JPG, PNG, GIF o SVG'));
        }
      }
      
      // Validar tamaño del archivo (máx 5MB)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        return const Left(ServerFailure('La imagen es demasiado grande. El tamaño máximo es 5MB'));
      }
      
      final imageUrl = await remoteDataSource.uploadProfileImage(imageFile, userId);
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al subir la imagen: ${e.message}'));
    } on UnauthenticatedException {
      return const Left(AuthenticationFailure('Sesión expirada. Por favor, inicia sesión nuevamente.'));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure('Error de autenticación: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImageBytes(Uint8List bytes, String fileName, String userId) async {
    try {
      // Validación de tamaño (máx 5MB)
      if (bytes.length > 5 * 1024 * 1024) {
        return const Left(ServerFailure('La imagen es demasiado grande. El tamaño máximo es 5MB'));
      }

      final imageUrl = await remoteDataSource.uploadProfileImageBytes(bytes, fileName, userId);
      return Right(imageUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure('Error al subir la imagen: ${e.message}'));
    } on UnauthenticatedException {
      return const Left(AuthenticationFailure('Sesión expirada. Por favor, inicia sesión nuevamente.'));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure('Error de autenticación: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }
}
