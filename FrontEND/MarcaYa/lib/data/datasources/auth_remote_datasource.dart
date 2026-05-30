/// Remote data source for authentication API calls.
///
/// Wraps HTTP calls to the backend auth endpoints.
/// Currently delegates to [ApiService]; in the future this will be
/// the sole responsibility of this class.
class AuthRemoteDataSource {
  // TODO: extract HTTP logic from ApiService into this class.
  // For now, ApiService (core/network/api_client.dart) handles
  // all backend communication directly.
}
