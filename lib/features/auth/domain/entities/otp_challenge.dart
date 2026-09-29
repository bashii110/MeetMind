/// Returned by RegisterUseCase now that registration no longer logs the
/// user in directly — it just confirms an OTP was sent, per
/// backend AuthController::register()'s `{ user, otp_required: true }`.
class OtpChallenge {
  const OtpChallenge({required this.email});

  final String email;
}