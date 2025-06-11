import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  bool _needsProfileCompletion = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  bool get needsProfileCompletion => _needsProfileCompletion;

  AuthProvider() {
    checkAuth();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmail(email, password);
      _needsProfileCompletion = _user?.hasFullProfile == false;
      debugPrint('AuthProvider: signInWithEmail - Usuário: ${_user?.email}, Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: signInWithEmail - Erro: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
      _needsProfileCompletion = _user?.hasFullProfile == false;
      debugPrint('AuthProvider: signInWithGoogle - Usuário: ${_user?.email}, Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: signInWithGoogle - Erro: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithApple();
      _needsProfileCompletion = _user?.hasFullProfile == false;
      debugPrint('AuthProvider: signInWithApple - Usuário: ${_user?.email}, Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: signInWithApple - Erro: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _needsProfileCompletion = false;
      debugPrint('AuthProvider: signOut - Usuário deslogado. Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: signOut - Erro: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      _needsProfileCompletion = _user?.hasFullProfile == false;
      debugPrint('AuthProvider: checkAuth - Usuário: ${_user?.email}, Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: checkAuth - Erro: $_error');
      print('Erro ao verificar autenticação: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeUserProfile(String name, double weight, double height) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_user == null || _user!.id.isEmpty) {
        throw Exception('Usuário não autenticado para completar o perfil.');
      }
      await _authService.saveUserProfileData(_user!.id, name, weight, height);
      _user = _user!.copyWith(name: name, weight: weight, height: height);
      _needsProfileCompletion = false;
      debugPrint('AuthProvider: completeUserProfile - Perfil completo. Usuário: ${_user?.email}, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: completeUserProfile - Erro: $_error');
      print('Erro ao completar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithEmail(email, password);
      _needsProfileCompletion = _user?.hasFullProfile == false;
      debugPrint('AuthProvider: signUpWithEmail - Usuário: ${_user?.email}, Autenticado: $isAuthenticated, Precisa completar perfil: $_needsProfileCompletion');
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: signUpWithEmail - Erro: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 