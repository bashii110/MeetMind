import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meetmind_ai/features/auth/presentation/providers/auth_controller.dart';

import '../../../../core/network/api_failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/spacing.dart';

/// Shown right after registration — SRD FR-1.3's email-verification gate,
/// implemented as a 6-digit OTP rather than a clickable link so it works
/// the same on every platform without a deep-link handler.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otp = TextEditingController();

  bool _submitting = false;
  bool _resending = false;
  String? _error;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _otp.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 30);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds -= 1);
      }
    });
  }

  Future<void> _verify() async {
    if (_otp.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code from your email.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(
        email: widget.email,
        otp: _otp.text.trim(),
      );
      // Router redirect (authStatusProvider) takes over on success.
    } catch (e) {
      final failure = ApiFailure.from(e);
      setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).resendOtp(widget.email);
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new code has been sent to your email.')),
        );
      }
    } catch (e) {
      setState(() => _error = ApiFailure.from(e).message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'Check your email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'We sent a 6-digit code to ${widget.email}.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xl),
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: Spacing.md),
                  ],
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(counterText: '', hintText: '000000'),
                    onSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: Spacing.lg),
                  ElevatedButton(
                    onPressed: _submitting ? null : _verify,
                    child: _submitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: Spacing.lg),
                  TextButton(
                    onPressed: (_resending || _cooldownSeconds > 0) ? null : _resend,
                    child: Text(
                      _cooldownSeconds > 0
                          ? 'Resend code in ${_cooldownSeconds}s'
                          : (_resending ? 'Sending…' : "Didn't get a code? Resend"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}