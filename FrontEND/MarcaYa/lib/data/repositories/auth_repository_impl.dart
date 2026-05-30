import '../../core/network/api_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using the legacy [ApiService].
///
/// Bridge between the Clean Architecture domain layer and the existing
/// [ApiService] singleton. As the migration progresses, this will
/// delegate to [AuthRemoteDataSource] instead.
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _api;

  AuthRepositoryImpl(this._api);

  @override
  Future<AppUser> login(String email, String password) async {
    final result = await _api.login(email, password);
    return AppUser.fromJson(result.perfil);
  }

  @override
  Future<void> logout() async {
    await _api.logout();
  }

  @override
  Future<AppUser> fetchProfile() async {
    final data = await _api.obtenerPerfil();
    final perfilJson = data['perfil'] as Map<String, dynamic>;
    return AppUser.fromJson(perfilJson);
  }

  @override
  Future<AppUser> updateProfile({
    required String nombre,
    required String correo,
  }) async {
    final data = await _api.actualizarPerfil(
      nombre: nombre,
      correo: correo,
    );
    final perfilJson = data['perfil'] as Map<String, dynamic>;
    return AppUser.fromJson(perfilJson);
  }

  @override
  Future<String?> getToken() => _api.getToken();
}
