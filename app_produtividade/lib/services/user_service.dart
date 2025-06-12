import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserModel user) async {
    try {
      debugPrint('UserService: saveUserProfile - Salvando perfil do usuário: ${user.toJson()}');
      final userData = user.toJson();
      await _firestore.collection('users').doc(user.id).set(userData);
      debugPrint('UserService: saveUserProfile - Perfil salvo com sucesso');
    } catch (e) {
      debugPrint('UserService: saveUserProfile - Erro ao salvar perfil: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      debugPrint('UserService: getUserProfile - Buscando perfil do usuário: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final userData = doc.data()!;
        debugPrint('UserService: getUserProfile - Perfil encontrado: $userData');
        
        try {
          final user = UserModel.fromJson(userData);
          debugPrint('UserService: getUserProfile - Perfil convertido com sucesso: ${user.toJson()}');
          return user;
        } catch (e) {
          debugPrint('UserService: getUserProfile - Erro ao converter perfil: $e');
          return null;
        }
      } else {
        debugPrint('UserService: getUserProfile - Perfil não encontrado para o usuário: $userId');
        return null;
      }
    } catch (e) {
      debugPrint('UserService: getUserProfile - Erro ao buscar perfil: $e');
      rethrow;
    }
  }
} 