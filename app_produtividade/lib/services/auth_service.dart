import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'user_data';

  Future<UserModel> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = UserModel(
      id: 'email_${DateTime.now().millisecondsSinceEpoch}',
      name: email.contains('@') ? email.split('@')[0] : email,
      email: email,
      authProvider: 'email',
    );
    await _saveUser(user);
    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    final user = UserModel(
      id: 'google_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Usuário Google',
      email: 'usuario@gmail.com',
      authProvider: 'google',
    );
    await _saveUser(user);
    return user;
  }

  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    final user = UserModel(
      id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Usuário Apple',
      email: 'usuario@icloud.com',
      authProvider: 'apple',
    );
    await _saveUser(user);
    return user;
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData == null) {
        print('Nenhum usuário encontrado');
        return null;
      }
      
      print('Dados do usuário recuperados: $userData');
      final Map<String, dynamic> userMap = json.decode(userData);
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Erro ao recuperar usuário: $e');
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(user.toJson());
      print('Salvando dados do usuário: $userData');
      await prefs.setString(_userKey, userData);
    } catch (e) {
      print('Erro ao salvar usuário: $e');
      rethrow;
    }
  }
} 