import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('UserModel: fromFirebaseUser - Criando modelo do usuário Firebase: ${user.uid}');
    return UserModel(
      id: user.uid,
      name: user.displayName,
      email: user.email ?? '',
      authProvider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    debugPrint('UserModel: toJson - Convertendo modelo para JSON');
    final json = {
      'id': id,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'authProvider': authProvider.toString().split('.').last,
    };
    debugPrint('UserModel: toJson - JSON gerado: $json');
    return json;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    debugPrint('UserModel: fromJson - Convertendo JSON para modelo: $json');
    
    AuthProviderType providerType;
    try {
      final providerStr = json['authProvider'] as String? ?? 'unknown';
      providerType = AuthProviderType.values.firstWhere(
        (e) => e.toString().split('.').last == providerStr,
        orElse: () => AuthProviderType.unknown,
      );
    } catch (e) {
      debugPrint('UserModel: fromJson - Erro ao converter provider: $e');
      providerType = AuthProviderType.unknown;
    }

    try {
      final user = UserModel(
        id: json['id'] as String,
        name: json['name'] as String?,
        email: json['email'] as String,
        weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
        height: json['height'] != null ? (json['height'] as num).toDouble() : null,
        authProvider: providerType,
      );
      debugPrint('UserModel: fromJson - Modelo criado com sucesso: ${user.toJson()}');
      return user;
    } catch (e) {
      debugPrint('UserModel: fromJson - Erro ao criar modelo: $e');
      rethrow;
    }
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

  bool get hasFullProfile {
    final hasProfile = name != null && weight != null && height != null && name!.isNotEmpty;
    debugPrint('UserModel: hasFullProfile - Verificando perfil completo: $hasProfile');
    debugPrint('UserModel: hasFullProfile - Dados: name=$name, weight=$weight, height=$height');
    return hasProfile;
  }
}
