import 'package:flutter/foundation.dart';

import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../src/app_state.dart';

/// Presentation-layer state provider for authentication.
///
/// Wraps the legacy [MarcaYAState] for mock compatibility and delegates
/// remote operations to the [AuthRepository] (Clean Architecture pattern).
class AuthProvider extends ChangeNotifier {
  final MarcaYAState _state;
  final AuthRepository _repository;

  AuthProvider(this._state, {AuthRepository? repository})
      : _repository = repository ?? _MockAuthRepository(_state);

  MarcaYAState get state => _state;
  bool get isLoggedIn => _state.currentUser != null;
  String? get userRole {
    final user = _state.currentUser;
    if (user == null) return null;
    return user.role == UserRole.employee ? 'empleado' : 'empresa';
  }

  /// Full profile of the authenticated user (from backend or mock).
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

  /// Fetch the profile from the real backend and sync with mock state.
  Future<void> fetchProfile() async {
    try {
      final perfil = await _repository.fetchProfile();
      final idx = _state.users.indexWhere((u) => u.id == perfil.id);
      if (idx != -1) {
        _state.users[idx] = perfil;
      }
      _state.currentUser = perfil;
      notifyListeners();
    } catch (_) {
      debugPrint('fetchProfile: sin backend disponible, usando mock');
    }
  }

  /// Update name and email on the backend and sync with mock state.
  Future<void> updateProfile({
    required String nombre,
    required String correo,
  }) async {
    try {
      final perfil = await _repository.updateProfile(
        nombre: nombre,
        correo: correo,
      );
      final idx = _state.users.indexWhere((u) => u.id == perfil.id);
      if (idx != -1) {
        _state.users[idx] = perfil;
      }
      _state.currentUser = perfil;
      notifyListeners();
    } catch (_) {
      debugPrint('updateProfile: sin backend disponible, actualizando solo mock');
    }
  }
}

/// In-memory mock repository that delegates to [MarcaYAState] for
/// local-only operation when no backend is available.
class _MockAuthRepository implements AuthRepository {
  final MarcaYAState _state;
  _MockAuthRepository(this._state);

  @override
  Future<AppUser> login(String email, String password) async {
    final ok = _state.login(email, password);
    if (!ok) throw Exception('Credenciales inválidas');
    return _state.currentUser!;
  }

  @override
  Future<void> logout() async {
    _state.logout();
  }

  @override
  Future<AppUser> fetchProfile() async => _state.currentUser!;

  @override
  Future<AppUser> updateProfile({
    required String nombre,
    required String correo,
  }) async {
    return _state.currentUser!;
  }

  @override
  Future<String?> getToken() async => null;
}
