import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/modern_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth =
        Provider.of<AuthenticationProvider>(context, listen: false);
    auth.clearError();

    await auth.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    // Show success state regardless — avoids leaking whether
    // an email exists in the system (security best practice)
    if (auth.error == null) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _emailSent
              ? _SuccessView(
                  email: _emailController.text.trim(),
                  onBack: () => Navigator.pop(context),
                  cs: cs,
                  theme: theme,
                )
              : _FormView(
                  formKey: _formKey,
                  emailController: _emailController,
                  auth: auth,
                  onSubmit: _submit,
                  cs: cs,
                  theme: theme,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final AuthenticationProvider auth;
  final VoidCallback onSubmit;
  final ColorScheme cs;
  final ThemeData theme;

  const _FormView({
    required this.formKey,
    required this.emailController,
    required this.auth,
    required this.onSubmit,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Icon(Icons.lock_reset_outlined, size: 56, color: cs.primary),
          const SizedBox(height: 20),
          Text(
            'Forgot Password?',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "No worries. Enter your email and we'll send you a link to reset your password.",
            style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 36),
          FloatingStyleTextField(
            controller: emailController,
            hintText: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Please enter a valid email';
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
                  Icon(Icons.error_outline, color: cs.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          ModernButton(
            text: 'Send Reset Link',
            icon: Icons.send_outlined,
            isLoading: auth.isLoading,
            onPressed: auth.isLoading ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;
  final ColorScheme cs;
  final ThemeData theme;

  const _SuccessView({
    required this.email,
    required this.onBack,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined,
              size: 40, color: cs.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Check your inbox',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to:',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.primary, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          'Click the link in the email to set a new password.\nCheck your spam folder if you don\'t see it.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ModernButton(
          text: 'Back to Sign In',
          icon: Icons.arrow_back,
          onPressed: onBack,
        ),
      ],
    );
  }
}
