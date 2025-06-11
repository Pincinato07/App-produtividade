import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthProviderType {
  email,
  google,
  apple,
  unknown,
}

class UserModel {
  final String id;
  final String? name;
  final String email;
  final double? weight;
  final double? height;
  final AuthProviderType authProvider;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.weight,
    this.height,
    required this.authProvider,
  });

  factory UserModel.fromFirebaseUser(User user, AuthProviderType provider) {
    return UserModel(
      id: user.uid,
      name: user.displayName,
      email: user.email ?? '',
      authProvider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'authProvider': authProvider.toString().split('.').last,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    AuthProviderType providerType;
    try {
      providerType = AuthProviderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['authProvider'] as String,
      );
    } catch (e) {
      providerType = AuthProviderType.unknown;
    }

    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      authProvider: providerType,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? weight,
    double? height,
    AuthProviderType? authProvider,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  bool get hasFullProfile => name != null && weight != null && height != null && name!.isNotEmpty;
}
