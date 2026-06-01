import 'package:flutter/foundation.dart';
import '../src/app_state.dart';
import '../src/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final MarcaYAState _state;

  AuthProvider(this._state);

  MarcaYAState get state => _state;

  bool get isLoggedIn => _state.currentUser != null;

  String? _userRole;

  String? get userRole => _userRole;

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
      final data = await ApiService.instance.obtenerPerfil();

      final perfilJson = data['perfil'] as Map<String, dynamic>;
      final perfil = AppUser.fromJson(perfilJson);

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
      final data =
      await ApiService.instance.actualizarPerfil(
        nombre: nombre,
        correo: correo,
      );

      final perfilJson =
      data['perfil'] as Map<String, dynamic>;

      final perfil =
      AppUser.fromJson(perfilJson);

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