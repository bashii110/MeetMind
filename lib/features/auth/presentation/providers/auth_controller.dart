import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetmind_ai/core/notifications/fcm_providers.dart';

import '../../domain/entities/app_user.dart';
import 'auth_providers.dart';

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.read(getCurrentUserUseCaseProvider)();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(loginUseCaseProvider)(email: email, password: password);
      return session.user;
    });
    if (state.hasError) throw state.error!;
  }

  /// Registration now only sends an OTP — it deliberately does NOT touch
  /// `state` (the person isn't signed in yet), so the splash/router
  /// redirect logic isn't affected. Returns the email being verified so
  /// the caller can navigate to the OTP screen; throws on failure the
  /// same way every other auth action here does.
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? timezone,
  }) async {
    final challenge = await ref.read(registerUseCaseProvider)(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      timezone: timezone,
    );
    return challenge.email;
  }

  /// Completes registration: verifies the OTP and, on success, signs the
  /// user in (mirrors login()/register()'s AsyncLoading/guard pattern).
  Future<void> verifyOtp({required String email, required String otp}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(verifyOtpUseCaseProvider)(email: email, otp: otp);
      return session.user;
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> resendOtp(String email) {
    return ref.read(resendOtpUseCaseProvider)(email);
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(googleLoginUseCaseProvider)();
      return session.user;
    });
    if (state.hasError) throw state.error!;
  }

  Future<void> logout() async {
    await ref.read(fcmServiceProvider).unregister();
    await ref.read(logoutUseCaseProvider)();
    state = const AsyncData(null);
  }

  Future<void> forgotPassword(String email) {
    return ref.read(forgotPasswordUseCaseProvider)(email);
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return ref.read(resetPasswordUseCaseProvider)(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  void setUser(AppUser user) => state = AsyncData(user);
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);