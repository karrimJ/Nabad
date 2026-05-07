import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../components/auth_input.dart';
import '../components/auth_button.dart';
import '../components/auth_header.dart';
import '../components/auth_footer.dart';
import '../components/social_button.dart';

import '../../../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeader(
                title: "Good to see you again!",
                subtitle:
                    "Log in to check your health stats, follow your progress, and stay on track with your wellbeing.",
              ),

              const SizedBox(height: 28),

              AuthInput(
                hint: "Enter your email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 16),

              AuthInput(
                hint: "Password",
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
                        "Remember Me",
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral700,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Forgot Password?",
                      style: AppTypography.bodySmall.copyWith(
                        color: VitalRed.vitalRed500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AuthButton(
                text: "Log In",
                onPressed: _login,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Neutral.neutral300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Or",
                      style: AppTypography.bodySmall.copyWith(
                        color: Neutral.neutral600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Neutral.neutral300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SocialButton(
                text: "Log In With Google",
                assetPath: "assets/icons/google.svg",
                onPressed: () {},
              ),

              const SizedBox(height: 12),

              SocialButton(
                text: "Log In With Apple",
                assetPath: "assets/icons/apple.svg",
                onPressed: () {},
              ),

              const SizedBox(height: 40),

              Center(
                child: AuthFooter(
                  text: "Don't have an account? ",
                  actionText: "Sign Up",
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