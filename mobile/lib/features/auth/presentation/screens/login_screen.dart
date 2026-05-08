import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../components/auth_input.dart';
import '../components/auth_button.dart';
import '../components/auth_header.dart';
import '../components/auth_footer.dart';
import '../components/social_button.dart';
import '../../data/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool rememberMe = true;
  bool _isLoading = false;
  bool _isResetLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Welcome back!', isError: false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle(source: 'google_login');

      if (!mounted) return;

      _showMessage('Welcome back!', isError: false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Google login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithApple(source: 'apple_login');

      if (!mounted) return;

      _showMessage('Welcome back!', isError: false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Apple login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onForgotPassword() async {
    final resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'Enter your account email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  resetEmailController.text.trim(),
                );
              },
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );

    resetEmailController.dispose();

    if (email == null) return;

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    setState(() => _isResetLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      _showMessage(
        'Password reset link sent. Check your inbox and spam folder.',
        isError: false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not send reset email: $e');
    } finally {
      if (mounted) {
        setState(() => _isResetLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? VitalRed.vitalRed500 : Success.success500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socialDisabled = _isLoading || _isResetLoading;

    return Scaffold(
      backgroundColor: Neutral.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: 'Good to see you again!',
                subtitle:
                    'Log in to check your health stats, follow your progress, and stay on track with your wellbeing.',
              ),

              const SizedBox(height: 28),

              AuthInput(
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 16),

              AuthInput(
                hint: 'Password',
                icon: Icons.lock_outline,
                controller: passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                        activeColor: VitalRed.vitalRed500,
                      ),
                      Text(
                        'Remember Me',
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral700,
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: (_isLoading || _isResetLoading)
                        ? null
                        : _onForgotPassword,
                    child: Text(
                      _isResetLoading ? 'Sending...' : 'Forgot Password?',
                      style: AppTypography.bodySmall.copyWith(
                        color: VitalRed.vitalRed500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AuthButton(
                text: _isLoading ? 'Logging in...' : 'Log In',
                onPressed: _isLoading ? () {} : _login,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: Neutral.neutral300, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Or',
                      style: AppTypography.bodySmall.copyWith(
                        color: Neutral.neutral600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Neutral.neutral300, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SocialButton(
                text: 'Log In With Google',
                assetPath: 'assets/icons/google.svg',
                onPressed: socialDisabled ? () {} : _loginWithGoogle,
              ),

              const SizedBox(height: 12),

              SocialButton(
                text: 'Log In With Apple',
                assetPath: 'assets/icons/apple.svg',
                onPressed: socialDisabled ? () {} : _loginWithApple,
              ),

              const SizedBox(height: 40),

              Center(
                child: AuthFooter(
                  text: "Don't have an account? ",
                  actionText: 'Sign Up',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}