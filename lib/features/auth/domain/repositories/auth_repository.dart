import '../entities/app_user.dart';
import '../entities/auth_session.dart';
import '../entities/otp_challenge.dart';

/// Implemented by data/repositories/auth_repository_impl.dart. Use cases
/// and the presentation layer depend on this abstraction, never the impl
/// directly (ARCHITECTURE.md 2.1).
abstract interface class AuthRepository {
  /// Registration no longer logs the user in directly — it sends an OTP
  /// and returns a challenge for the email that needs verifying.
  Future<OtpChallenge> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? timezone,
  });

  Future<AuthSession> verifyOtp({required String email, required String otp});

  Future<void> resendOtp(String email);

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> loginWithGoogle();

  Future<void> logout();

  Future<AppUser?> getCurrentUser();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
}