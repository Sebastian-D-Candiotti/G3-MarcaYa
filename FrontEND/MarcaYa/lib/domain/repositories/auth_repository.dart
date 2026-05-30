import '../entities/app_user.dart';

/// Abstract repository interface for authentication.
///
/// Domain layer contracts — implementations live in [data/repositories/].
abstract class AuthRepository {
  /// Attempt login with [email] and [password].
  /// Returns the authenticated [AppUser] on success, throws on failure.
  Future<AppUser> login(String email, String password);

  /// Log out the current user.
  Future<void> logout();

  /// Fetch the authenticated user's profile from the backend.
  Future<AppUser> fetchProfile();

  /// Update the user's name and email.
  Future<AppUser> updateProfile({
    required String nombre,
    required String correo,
  });

  /// Get the stored JWT token, if any.
  Future<String?> getToken();
}
