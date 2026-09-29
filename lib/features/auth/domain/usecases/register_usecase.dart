import '../entities/otp_challenge.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<OtpChallenge> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? timezone,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      timezone: timezone,
    );
  }
}