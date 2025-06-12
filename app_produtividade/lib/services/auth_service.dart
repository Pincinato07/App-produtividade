import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'user_service.dart';

class AuthService {
  static const String _userKey = 'user_data';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();

  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      UserModel user = UserModel.fromFirebaseUser(result.user!, AuthProviderType.email);
      await _userService.saveUserProfile(user);
      await _saveUser(user);
      debugPrint('AuthService: signUpWithEmail - Sucesso. UID: ${user.id}');
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('Já existe uma conta para este email.');
      }
      debugPrint('AuthService: signUpWithEmail - Erro FirebaseAuth: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService: signUpWithEmail - Erro geral: $e');
      rethrow;
    }
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user == null) {
        throw Exception('Falha ao autenticar usuário');
      }

      UserModel user = UserModel.fromFirebaseUser(result.user!, AuthProviderType.email);
      debugPrint('AuthService: signInWithEmail - Usuário criado do Firebase: ${user.toJson()}');
      
      try {
        final fullProfile = await _userService.getUserProfile(user.id);
        debugPrint('AuthService: signInWithEmail - Perfil completo obtido: ${fullProfile?.toJson()}');
        
        if (fullProfile != null) {
          user = user.copyWith(
            name: fullProfile.name,
            weight: fullProfile.weight,
            height: fullProfile.height,
          );
          debugPrint('AuthService: signInWithEmail - Usuário atualizado com perfil: ${user.toJson()}');
        } else {
          // Se não existe perfil, salva o perfil básico no Firestore
          await _userService.saveUserProfile(user);
          debugPrint('AuthService: signInWithEmail - Perfil básico salvo no Firestore');
        }
      } catch (e) {
        debugPrint('AuthService: signInWithEmail - Erro ao buscar/salvar perfil: $e');
        // Continua mesmo com erro no perfil, pois o usuário está autenticado
      }
      
      await _saveUser(user);
      debugPrint('AuthService: signInWithEmail - Sucesso. UID: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('AuthService: signInWithEmail - Erro: $e');
      rethrow;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('AuthService: signInWithGoogle - Login com Google cancelado.');
        throw Exception('Login com Google cancelado pelo usuário');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      
      if (result.user == null) {
        throw Exception('Falha ao autenticar usuário');
      }

      UserModel user = UserModel.fromFirebaseUser(result.user!, AuthProviderType.google);
      debugPrint('AuthService: signInWithGoogle - Usuário criado do Firebase: ${user.toJson()}');
      
      try {
        final fullProfile = await _userService.getUserProfile(user.id);
        debugPrint('AuthService: signInWithGoogle - Perfil completo obtido: ${fullProfile?.toJson()}');
        
        if (fullProfile != null) {
          user = user.copyWith(
            name: fullProfile.name,
            weight: fullProfile.weight,
            height: fullProfile.height,
          );
          debugPrint('AuthService: signInWithGoogle - Usuário atualizado com perfil: ${user.toJson()}');
        } else {
          // Se não existe perfil, salva o perfil básico no Firestore
          await _userService.saveUserProfile(user);
          debugPrint('AuthService: signInWithGoogle - Perfil básico salvo no Firestore');
        }
      } catch (e) {
        debugPrint('AuthService: signInWithGoogle - Erro ao buscar/salvar perfil: $e');
        // Continua mesmo com erro no perfil, pois o usuário está autenticado
      }
      
      await _saveUser(user);
      debugPrint('AuthService: signInWithGoogle - Sucesso. UID: ${user.id}');
      return user;
    } catch (e) {
      debugPrint('AuthService: signInWithGoogle - Erro: $e');
      rethrow;
    }
  }

  Future<UserModel> signInWithApple() async {
    // Implementação do login com Apple será feita posteriormente
    throw UnimplementedError('Login com Apple ainda não implementado');
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      debugPrint('AuthService: signOut - Sucesso.');
    } catch (e) {
      debugPrint('AuthService: signOut - Erro: $e');
      rethrow;
    }
  }

  Future<void> saveUserProfileData(String userId, String name, double weight, double height) async {
    try {
      // Primeiro, tente obter o usuário atual para atualizar seus dados
      UserModel? currentUser = await getCurrentUser();
      if (currentUser == null) {
        debugPrint('AuthService: saveUserProfileData - Usuário não autenticado.');
        throw Exception('Usuário não autenticado para salvar perfil.');
      }

      // Crie um novo UserModel com os dados atualizados
      final updatedUser = currentUser.copyWith(
        name: name,
        weight: weight,
        height: height,
      );

      // Salve no Firestore
      await _userService.saveUserProfile(updatedUser);

      // Salve no SharedPreferences
      await _saveUser(updatedUser);
      debugPrint('AuthService: saveUserProfileData - Perfil salvo com sucesso para UID: ${updatedUser.id}');
    } catch (e) {
      debugPrint('AuthService: saveUserProfileData - Erro: $e');
      print('Erro ao salvar dados do perfil do usuário: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData == null) {
        debugPrint('AuthService: getCurrentUser - Nenhum usuário encontrado no SharedPreferences.');
        return null;
      }

      debugPrint('AuthService: getCurrentUser - Dados do usuário recuperados do SharedPreferences.');
      final Map<String, dynamic> userMap = json.decode(userData);
      return UserModel.fromJson(userMap);
    } catch (e) {
      debugPrint('AuthService: getCurrentUser - Erro ao recuperar usuário: $e');
      return null;
    }
  }

  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      print('Erro ao salvar usuário: $e');
      rethrow;
    }
  }
} 