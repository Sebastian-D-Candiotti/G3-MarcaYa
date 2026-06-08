import 'package:flutter/foundation.dart';
import '../src/app_state.dart';
import '../src/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final MarcaYAState _state;

  AuthProvider(this._state);

  MarcaYAState get state => _state;

  bool get isLoggedIn => _state.currentUser != null;

  String? _userRole;
  String? _recoveryEmail;
  String? _verificationToken;

  String? get userRole => _userRole;
  String? get recoveryEmail => _recoveryEmail;
  String? get verificationToken => _verificationToken;

  AppUser? get currentUserProfile => _state.currentUser;

  // ==========================================
  // LOGIN REAL CONTRA BACKEND
  // ==========================================
  Future<bool> login(String email, String password) async {
    try {
      final result = await ApiService.instance.login(
        email,
        password,
      );
      print(result.perfil);
      _userRole = result.rol;

      final perfil = AppUser.fromJson(result.perfil);
      print(result.perfil);
      print(perfil.nombre);
      print(perfil.correo);
      final idx = _state.users.indexWhere(
            (u) => u.id == perfil.id,
      );

      if (idx != -1) {
        _state.users[idx] = perfil;
      } else {
        _state.users.add(perfil);
      }

      _state.currentUser = perfil;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error login: $e');
      return false;
    }
  }

  // ==========================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ==========================================
  Future<bool> solicitarCodigo(String email) async {
    try {
      await ApiService.instance.solicitarCodigo(email);
      _recoveryEmail = email;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error solicitar código: $e');
      return false;
    }
  }

  Future<String?> verificarCodigo(String codigo) async {
    try {
      if (_recoveryEmail == null) return null;
      final result = await ApiService.instance.verificarCodigo(_recoveryEmail!, codigo);
      _verificationToken = result['verification_token'] as String?;
      notifyListeners();
      return _verificationToken;
    } catch (e) {
      debugPrint('Error verificar código: $e');
      rethrow;
    }
  }

  Future<bool> restablecerContrasena(String nuevaClave) async {
    try {
      if (_verificationToken == null) return false;
      await ApiService.instance.restablecerContrasena(_verificationToken!, nuevaClave);
      _recoveryEmail = null;
      _verificationToken = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error restablecer contraseña: $e');
      return false;
    }
  }

  // ==========================================
  // LOGOUT
  // ==========================================
  Future<void> logout() async {
    await ApiService.instance.logout();

    _state.logout();
    _userRole = null;

    notifyListeners();
  }

  // ==========================================
  // PERFIL
  // ==========================================
  Future<void> fetchProfile() async {
    try {
      final data = await ApiService.instance.obtenerMiPerfil();
      final perfil = AppUser.fromJson(data);

      final idx = _state.users.indexWhere(
            (u) => u.id == perfil.id,
      );

      if (idx != -1) {
        _state.users[idx] = perfil;
      } else {
        _state.users.add(perfil);
      }

      _state.currentUser = perfil;

      notifyListeners();
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    }
  }

  // ==========================================
  // ACTUALIZAR PERFIL
  // ==========================================
  Future<void> updateProfile({
    required String nombre,
    required String correo,
  }) async {
    try {
      final usuarioId = _state.currentUser != null
          ? int.parse(_state.currentUser!.id)
          : 0;

      final data = await ApiService.instance.actualizarPerfil(
        usuarioId,
        nombre: nombre,
        correo: correo,
      );

      final perfil = AppUser.fromJson(data);

      final idx = _state.users.indexWhere(
            (u) => u.id == perfil.id,
      );

      if (idx != -1) {
        _state.users[idx] = perfil;
      } else {
        _state.users.add(perfil);
      }

      _state.currentUser = perfil;

      notifyListeners();
    } catch (e) {
      debugPrint('updateProfile error: $e');
    }
  }

}