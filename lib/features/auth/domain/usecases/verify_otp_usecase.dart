import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String otp}) {
    return _repository.verifyOtp(email: email, otp: otp);
  }
}