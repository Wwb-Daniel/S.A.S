import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/error/exceptions.dart';
import '../../../../features/auth/domain/models/auth_models.dart';
import '../../../../core/config/supabase_config.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  });
  Future<Unit> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  /// Sube una imagen de perfil y actualiza la URL en el perfil del usuario
  /// [imageFile] es el archivo de imagen a subir
  /// [userId] es el ID del usuario
  /// Retorna la URL de la imagen subida
  Future<String> uploadProfileImage(File imageFile, String userId);
  /// Versión por bytes (Web)
  Future<String> uploadProfileImageBytes(Uint8List bytes, String fileName, String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final supabase.SupabaseClient _supabase = SupabaseConfig.client;
  final supabase.GoTrueClient _auth = SupabaseConfig.auth;

  // Cloudinary config (usar tus valores reales)
  static const String _cloudName = 'dtxikv1nx';
  static const String _uploadPreset = 'uploads_unsigned';

  @override
  Future<UserProfile> getProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UnauthenticatedException('Usuario no autenticado');
      }

      final response = await _supabase
          .from('employees')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      throw ServerException('Error en la base de datos: ${e.message}');
    } on supabase.AuthException catch (e) {
      throw AuthException('Error de autenticación: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al obtener el perfil: $e');
    }
  }

  @override
  Future<UserProfile> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UnauthenticatedException('Usuario no autenticado');
      }

      final updates = <String, dynamic>{
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (position != null) 'position': position,
        if (department != null) 'department': department,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('employees')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } on supabase.PostgrestException catch (e) {
      throw ServerException('Error al actualizar en la base de datos: ${e.message}');
    } on supabase.AuthException catch (e) {
      throw AuthException('Error de autenticación al actualizar: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al actualizar el perfil: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Generar nombre y leer bytes
      final ext = imageFile.path.contains('.') ? imageFile.path.split('.').last.toLowerCase() : 'jpg';
      final safeExt = ext.isEmpty ? 'jpg' : (ext == 'jpeg' ? 'jpg' : ext);
      final fileName = 'profile_$userId.${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final bytes = await imageFile.readAsBytes();

      // Subir a Cloudinary
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/'+_cloudName+'/auto/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = fileName
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      final streamed = await request.send();
      final responseHttp = await http.Response.fromStream(streamed);
      if (responseHttp.statusCode < 200 || responseHttp.statusCode >= 300) {
        throw ServerException('Cloudinary error ${responseHttp.statusCode}: ${responseHttp.body}');
      }
      final data = json.decode(responseHttp.body) as Map<String, dynamic>;
      final secureUrl = (data['secure_url'] ?? data['url']) as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw ServerException('Cloudinary no devolvió URL');
      }

      // Actualizar perfil en Supabase
      final response = await _supabase
          .from('employees')
          .update({'avatar_url': secureUrl})
          .eq('id', userId)
          .select()
          .single();
      print('Perfil actualizado: $response');

      return secureUrl;
    } on supabase.PostgrestException catch (e) {
      throw ServerException('Error al actualizar el perfil: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<String> uploadProfileImageBytes(Uint8List bytes, String fileName, String userId) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/'+_cloudName+'/auto/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..fields['public_id'] = fileName
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      final streamed = await request.send();
      final responseHttp = await http.Response.fromStream(streamed);
      if (responseHttp.statusCode < 200 || responseHttp.statusCode >= 300) {
        throw ServerException('Cloudinary error ${responseHttp.statusCode}: ${responseHttp.body}');
      }
      final data = json.decode(responseHttp.body) as Map<String, dynamic>;
      final secureUrl = (data['secure_url'] ?? data['url']) as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw ServerException('Cloudinary no devolvió URL');
      }

      final response = await _supabase
          .from('employees')
          .update({'avatar_url': secureUrl})
          .eq('id', userId)
          .select()
          .single();
      print('Perfil actualizado: $response');
      return secureUrl;
    } on supabase.PostgrestException catch (e) {
      throw ServerException('Error al actualizar el perfil: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<Unit> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const UnauthenticatedException('Usuario no autenticado');
      }

      // Primero, verificar la contraseña actual
      await _auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Si la autenticación es exitosa, actualizar la contraseña
      await _auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );

      return unit;
    } on supabase.AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw const AuthException('La contraseña actual es incorrecta');
      }
      throw AuthException('Error al actualizar la contraseña: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado al actualizar la contraseña: $e');
    }
  }
}
