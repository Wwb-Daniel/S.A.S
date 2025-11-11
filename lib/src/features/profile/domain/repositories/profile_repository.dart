import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:mi_app_multiplataforma/src/core/error/failures.dart';
import 'package:mi_app_multiplataforma/src/features/auth/domain/models/auth_models.dart';

abstract class ProfileRepository {
  /// Obtiene el perfil del usuario actual
  Future<Either<Failure, UserProfile>> getProfile();
  
  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  });
  
  /// Actualiza la contraseña del usuario
  Future<Either<Failure, Unit>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Sube una imagen de perfil y actualiza la URL en el perfil del usuario
  /// [imageFile] es el archivo de imagen a subir
  /// [userId] es el ID del usuario
  /// Retorna la URL de la imagen subida en caso de éxito
  Future<Either<Failure, String>> uploadProfileImage(File imageFile, String userId);

  /// Versión para Web: subir imagen desde bytes y actualizar la URL del perfil
  /// [bytes] contenido del archivo
  /// [fileName] nombre de archivo sugerido (con extensión)
  Future<Either<Failure, String>> uploadProfileImageBytes(Uint8List bytes, String fileName, String userId);
}
