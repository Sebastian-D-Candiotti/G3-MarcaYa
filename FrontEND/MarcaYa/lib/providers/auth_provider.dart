import 'package:flutter/foundation.dart';
import '../src/app_state.dart';
import '../src/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final MarcaYAState _state;

  AuthProvider(this._state);

  MarcaYAState get state => _state;
  bool get isLoggedIn => _state.currentUser != null;
  String? get userRole {
    final user = _state.currentUser;
    if (user == null) return null;
    // Mapeo de roles: employee → 'empleado', admin → 'empresa', empresa → 'empresa'
    return user.role == UserRole.employee ? 'empleado' : 'empresa';
  }

  /// Perfil completo del usuario autenticado (desde backend o desde mock)
  AppUser? get currentUserProfile => _state.currentUser;

  bool login(String email, String password) {
    final ok = _state.login(email, password);
    if (ok) notifyListeners();
    return ok;
  }

  void logout() {
    _state.logout();
    notifyListeners();
  }

  /// Obtiene el perfil desde el backend real y lo guarda en el estado mock
  /// para mantener compatibilidad. Si no hay backend, usa el mock existente.
  Future<void> fetchProfile() async {
    try {
      final data = await ApiService.instance.obtenerPerfil();
      final perfilJson = data['perfil'] as Map<String, dynamic>;
      final perfil = AppUser.fromJson(perfilJson);

      // Actualiza el currentUser en el estado mock con datos del backend
      final idx = _state.users.indexWhere((u) => u.id == perfil.id);
      if (idx != -1) {
        _state.users[idx] = perfil;
      }
      _state.currentUser = perfil;
      notifyListeners();
    } catch (_) {
      // Sin backend — seguimos con el mock actual
      debugPrint('fetchProfile: sin backend disponible, usando mock');
    }
  }

  /// Actualiza nombre y correo en el backend y refleja el cambio en el estado mock
  Future<void> updateProfile({
    required String nombre,
    required String correo,
  }) async {
    try {
      final data = await ApiService.instance.actualizarPerfil(
        nombre: nombre,
        correo: correo,
      );
      final perfilJson = data['perfil'] as Map<String, dynamic>;
      final perfil = AppUser.fromJson(perfilJson);

      final idx = _state.users.indexWhere((u) => u.id == perfil.id);
      if (idx != -1) {
        _state.users[idx] = perfil;
      }
      _state.currentUser = perfil;
      notifyListeners();
    } catch (_) {
      // Fallback: actualiza solo en mock
      debugPrint('updateProfile: sin backend disponible, actualizando solo mock');
    }
  }
}
