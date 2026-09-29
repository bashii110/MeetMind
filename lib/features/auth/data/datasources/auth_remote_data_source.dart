import 'package:dio/dio.dart';

import '../models/app_user_model.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// Registration now only triggers an OTP email — see
  /// backend AuthController::register(); it no longer returns tokens.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? timezone,
  }) async {
    await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (timezone != null) 'timezone': timezone,
    });
  }

  Future<AuthSessionModel> verifyOtp({required String email, required String otp}) async {
    final response = await _dio.post('/auth/verify-otp', data: {
      'email': email,
      'otp': otp,
    });
    return AuthSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> resendOtp(String email) {
    return _dio.post('/auth/resend-otp', data: {'email': email});
  }

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    return AuthSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSessionModel> loginWithGoogle(String googleAccessToken) async {
    final response = await _dio.post('/auth/google', data: {
      'access_token': googleAccessToken,
    });

    return AuthSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AuthSessionModel> refresh() async {
    final response = await _dio.post('/auth/refresh');

    return AuthSessionModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() => _dio.post('/auth/logout');

  Future<AppUserModel> me() async {
    final response = await _dio.get('/auth/me');

    return AppUserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) {
    return _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _dio.post('/auth/reset-password', data: {
      'token': token,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}