import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/modern_button.dart';
import '../splash_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _emailSent = false;
  bool _checkingVerification = false;

  // Auto-polls Firebase every 3 seconds after email is sent
  // so the app redirects automatically when user clicks the link
  Timer? _verificationPoller;

  @override
  void dispose() {
    _verificationPoller?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    auth.clearError();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );
    if (success && mounted) {
      setState(() => _emailSent = true);
      _startVerificationPolling();
    }
  }

  /// Polls Firebase every 3 seconds to detect when the user
  /// clicks the verification link in their email.
  void _startVerificationPolling() {
    _verificationPoller?.cancel();
    _verificationPoller =
        Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final verified = await auth.isEmailVerified();
      if (verified && mounted) {
        _verificationPoller?.cancel();
        // Auto-navigate to main app — no need to tap anything
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _resendVerification() async {
    final auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    await auth.resendEmailVerification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent.')),
      );
    }
  }

  /// Manual check — user taps "I've Verified" button
  Future<void> _checkVerified() async {
    setState(() => _checkingVerification = true);
    try {
      final auth =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final verified = await auth.isEmailVerified();
      if (!mounted) return;
      if (verified) {
        _verificationPoller?.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Not verified yet. Please click the link in your email.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checkingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(Icons.coffee, size: 72, color: cs.primary),
                const SizedBox(height: 16),
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                if (!_emailSent) ...[
                  // ── Registration form ──────────────────────────
                  FloatingStyleTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter your name' : null,
                  ),
                  FloatingStyleTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  FloatingStyleTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  FloatingStyleTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: cs.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ModernButton(
                    text: 'Create Account',
                    icon: Icons.person_add,
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _submitForm,
                  ),
                ] else ...[
                  // ── Verification waiting screen ────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mark_email_unread_outlined,
                            size: 48, color: cs.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Verify your email',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a link to:',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailController.text.trim(),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Click the link in your email.\nThis screen redirects automatically.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Waiting for verification...',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ModernButton(
                          text: 'Resend Email',
                          icon: Icons.refresh,
                          isPrimary: false,
                          onPressed: _resendVerification,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernButton(
                          text: "I've Verified",
                          icon: Icons.verified_user,
                          isLoading: _checkingVerification,
                          onPressed:
                              _checkingVerification ? null : _checkVerified,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      _verificationPoller?.cancel();
                      // Sign out the unverified user before going back
                      await Provider.of<AuthenticationProvider>(
                              context,
                              listen: false)
                          .signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    child: Text(
                      'Use a different account',
                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                if (!_emailSent)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
