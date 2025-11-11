import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app_multiplataforma/src/core/error/exceptions.dart';
import 'package:mi_app_multiplataforma/src/core/error/failures.dart';
import 'package:mi_app_multiplataforma/src/features/auth/domain/models/auth_models.dart';
import 'package:mi_app_multiplataforma/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:mi_app_multiplataforma/src/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:mi_app_multiplataforma/src/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mi_app_multiplataforma/src/features/profile/domain/repositories/profile_repository.dart';

// Estado del perfil
@immutable
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingImage;
  final bool isPasswordUpdating;
  final Failure? error;
  final String? imageUrl;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingImage = false,
    this.isPasswordUpdating = false,
    this.error,
    this.imageUrl,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingImage,
    bool? isPasswordUpdating,
    Failure? error,
    String? imageUrl,
    bool clearError = false,
    bool clearImageUrl = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isPasswordUpdating: isPasswordUpdating ?? this.isPasswordUpdating,
      error: clearError ? null : (error ?? this.error),
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
    );
  }
}

// Notifier para manejar el estado del perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileNotifier(this._repository, this._ref) : super(const ProfileState()) {
    // Cargar perfil automáticamente al inicializar
    loadProfile();
  }

  // Cargar perfil del usuario
  Future<void> loadProfile() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        throw const ServerException('Usuario no autenticado');
      }
      
      final result = await _repository.getProfile();
      
      result.fold(
        (failure) => state = state.copyWith(
          error: failure,
          isLoading: false,
        ),
        (profile) => state = state.copyWith(
          profile: profile,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : ServerFailure(e.toString()),
        isLoading: false,
      );
    }
  }

  // Actualizar perfil
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? position,
    String? department,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    
    try {
      final result = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        position: position,
        department: department,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            error: failure,
            isUpdating: false,
          );
          return false;
        },
        (profile) {
          state = state.copyWith(
            profile: profile,
            isUpdating: false,
            error: null,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : ServerFailure(e.toString()),
        isUpdating: false,
      );
      return false;
    }
  }

  // Subir imagen de perfil
  Future<String?> uploadProfileImage(File imageFile) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        throw const ServerException('Usuario no autenticado');
      }
      
      final result = await _repository.uploadProfileImage(
        imageFile,
        authState.user!.id,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            error: failure,
            isUploadingImage: false,
          );
          return null;
        },
        (imageUrl) {
          state = state.copyWith(
            profile: state.profile?.copyWith(avatarUrl: imageUrl),
            isUploadingImage: false,
            imageUrl: imageUrl,
            error: null,
          );
          return imageUrl;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : ServerFailure(e.toString()),
        isUploadingImage: false,
      );
      rethrow;
    }
  }

  // Subir imagen de perfil (Web) desde bytes
  Future<String?> uploadProfileImageWeb(Uint8List bytes, String fileName) async {
    state = state.copyWith(isUploadingImage: true, clearError: true);
    try {
      final authState = _ref.read(authProvider);
      if (authState.user == null) {
        throw const ServerException('Usuario no autenticado');
      }

      final safeName = (fileName.isEmpty)
          ? 'profile_${authState.user!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : fileName;

      final result = await _repository.uploadProfileImageBytes(
        bytes,
        safeName,
        authState.user!.id,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(
            error: failure,
            isUploadingImage: false,
          );
          return null;
        },
        (imageUrl) {
          state = state.copyWith(
            profile: state.profile?.copyWith(avatarUrl: imageUrl),
            isUploadingImage: false,
            imageUrl: imageUrl,
            error: null,
          );
          return imageUrl;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : ServerFailure(e.toString()),
        isUploadingImage: false,
      );
      rethrow;
    }
  }

  // Actualizar contraseña
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isPasswordUpdating: true, clearError: true);
    
    try {
      final result = await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      return result.fold(
        (failure) {
          state = state.copyWith(
            error: failure,
            isPasswordUpdating: false,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isPasswordUpdating: false,
            error: null,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: e is Failure ? e : ServerFailure(e.toString()),
        isPasswordUpdating: false,
      );
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
  
  // Limpiar URL de imagen temporal
  void clearImageUrl() {
    state = state.copyWith(clearImageUrl: true);
  }
}

// Proveedor del notifier
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceImpl(),
  );
  return ProfileNotifier(repository, ref);
});
