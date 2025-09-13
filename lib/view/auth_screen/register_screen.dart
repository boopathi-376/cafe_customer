import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/modern_button.dart';
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

  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;
  bool _emailSent = false;
  bool _checkingVerification = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(Icons.coffee, size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('Create Account',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),

                // Input fields
                FloatingStyleTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                ),
                FloatingStyleTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter email';
                    if (!value.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                FloatingStyleTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter your password';
                    if (value.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                FloatingStyleTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirm your password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 24),

                if (!_emailSent)
                  ModernButton(
                    text: 'Create Account',
                    icon: Icons.person_add,
                    isLoading: authProvider.isLoading,
                    onPressed: authProvider.isLoading ? null : () => _submitForm(context),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mail_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "A verification link has been sent to your email.",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ModernButton(
                              text: "Resend Email",
                              icon: Icons.email,
                              isPrimary: false,
                              onPressed: _resendVerificationEmail,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ModernButton(
                              text: "I've Verified",
                              icon: Icons.verified_user,
                              isPrimary: true,
                              isLoading: _checkingVerification,
                              onPressed: _checkingVerification ? null : _checkEmailVerified,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text("Sign In"),
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

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (success && context.mounted) {
      await authProvider.sendEmailVerification();
      setState(() => _emailSent = true);
    }
  }

  Future<void> _resendVerificationEmail() async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    await authProvider.sendEmailVerification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Verification email resent")),
    );
  }

  Future<void> _checkEmailVerified() async {
    setState(() => _checkingVerification = true);
    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = await auth.reloadAndCheckVerified();

    setState(() => _checkingVerification = false);
    if (user != null && user.emailVerified) {
      // ✅ Save to Firestore only after verification
      await auth.saveUserToFirestore(user);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet. Check your inbox or spam folder.")),
      );
    }
  }
}
