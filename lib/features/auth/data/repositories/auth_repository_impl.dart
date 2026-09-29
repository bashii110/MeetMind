import 'package:dio/dio.dart';

import '../../../../core/network/api_failure.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required GoogleAuthDataSource googleAuthDataSource,
    required TokenStorage tokenStorage,
  })  : _remote = remoteDataSource,
        _google = googleAuthDataSource,
        _tokens = tokenStorage;

  final AuthRemoteDataSource _remote;
  final GoogleAuthDataSource _google;
  final TokenStorage _tokens;

  @override
  Future<OtpChallenge> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? timezone,
  }) async {
    await _remote.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      timezone: timezone,
    );
    return OtpChallenge(email: email);
  }

  @override
  Future<AuthSession> verifyOtp({required String email, required String otp}) async {
    final session = await _remote.verifyOtp(email: email, otp: otp);
    await _persist(session);
    return session;
  }

  @override
  Future<void> resendOtp(String email) => _remote.resendOtp(email);

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final session = await _remote.login(email: email, password: password);
    await _persist(session);
    return session;
  }

  @override
  Future<AuthSession> loginWithGoogle() async {
    final googleAccessToken = await _google.signInAndGetAccessToken();
    final session = await _remote.loginWithGoogle(googleAccessToken);
    await _persist(session);
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on DioException {
      // Best-effort — see original comment.
    } finally {
      await _tokens.clear();
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final accessToken = await _tokens.readAccessToken();
    if (accessToken == null) return null;

    try {
      return await _remote.me();
    } on DioException catch (e) {
      final failure = e.error;
      if (failure is ApiFailure && failure.statusCode == 401) {
        return _tryRefresh();
      }
      rethrow;
    }
  }

  Future<AppUser?> _tryRefresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      await _tokens.saveTokens(accessToken: refreshToken, refreshToken: refreshToken);
      final session = await _remote.refresh();
      await _persist(session);
      return session.user;
    } on DioException {
      await _tokens.clear();
      return null;
    }
  }

  @override
  Future<void> forgotPassword(String email) => _remote.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _remote.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<void> _persist(AuthSession session) => _tokens.saveTokens(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
  );
}