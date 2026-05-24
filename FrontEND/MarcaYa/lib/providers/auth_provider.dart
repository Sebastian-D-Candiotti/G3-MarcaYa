import 'package:flutter/foundation.dart';
import '../src/app_state.dart';

class AuthProvider extends ChangeNotifier {
  final MarcaYAState _state;

  AuthProvider(this._state);

  MarcaYAState get state => _state;
  bool get isLoggedIn => _state.currentUser != null;
  String? get userRole {
    final user = _state.currentUser;
    if (user == null) return null;
    return user.role == UserRole.employee ? 'empleado' : 'empresa';
  }

  bool login(String email, String password) {
    final ok = _state.login(email, password);
    if (ok) notifyListeners();
    return ok;
  }

  void logout() {
    _state.logout();
    notifyListeners();
  }
}
