import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String companyId;
  final String role;
  final String? position;
  final String? department;
  final String? phone;
  final String? avatarUrl;
  final String status;

  const UserProfile({
    required this.id,
    required this.email,
    required this.companyId,
    required this.role,
    this.fullName,
    this.position,
    this.department,
    this.phone,
    this.avatarUrl,
    this.status = 'active',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      companyId: json['company_id'] as String,
      role: json['role'] as String,
      position: json['position'] as String?,
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (fullName != null) 'full_name': fullName,
      'company_id': companyId,
      'role': role,
      if (position != null) 'position': position,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'status': status,
    };
  }

  UserProfile copyWith({
    String? email,
    String? fullName,
    String? role,
    String? position,
    String? department,
    String? phone,
    String? avatarUrl,
    String? status,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      companyId: companyId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      position: position ?? this.position,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        companyId,
        role,
        position,
        department,
        phone,
        avatarUrl,
        status,
      ];
}

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String? fullName;
  final String? avatarUrl;
  final String? companyId;
  final String? role;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    this.phone,
    this.fullName,
    this.avatarUrl,
    this.companyId,
    this.role,
    this.isEmailVerified = false,
  });

  static const empty = AuthUser(id: '', email: '');

  bool get isEmpty => this == AuthUser.empty;
  bool get isNotEmpty => this != AuthUser.empty;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      companyId: json['company_id'] as String?,
      role: json['role'] as String?,
      isEmailVerified: json['email_confirmed_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (phone != null) 'phone': phone,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (companyId != null) 'company_id': companyId,
      if (role != null) 'role': role,
    };
  }

  AuthUser copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    String? avatarUrl,
    String? companyId,
    String? role,
    bool? isEmailVerified,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      companyId: companyId ?? this.companyId,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        avatarUrl,
        companyId,
        role,
        isEmailVerified,
      ];
}

class AuthCredentials {
  final String email;
  final String password;
  final String? fullName;
  final String? phone;
  final String? companyName;
  final String? companyRuc;
  final String? companyAddress;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.fullName,
    this.phone,
    this.companyName,
    this.companyRuc,
    this.companyAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (companyName != null) 'company_name': companyName,
      if (companyRuc != null) 'company_ruc': companyRuc,
      if (companyAddress != null) 'company_address': companyAddress,
    };
  }
}

class AuthResponse {
  final AuthUser user;
  final String? error;
  final String? sessionId;

  const AuthResponse({
    required this.user,
    this.error,
    this.sessionId,
  });

  bool get hasError => error != null;
}
