import 'package:flutter/material.dart';

import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../components/auth_input.dart';
import '../components/auth_button.dart';
import '../components/auth_header.dart';
import '../components/auth_footer.dart';
import '../components/social_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

              /// HEADER
              AuthHeader(
                title: "Good to see you again!",
                subtitle:
                    "Log in to check your health stats, follow your progress, and stay on track with your wellbeing.",
              ),

              const SizedBox(height: 28),

              /// EMAIL
              AuthInput(
                hint: "Enter your email",
                icon: Icons.email_outlined,
                controller: emailController,
              ),

              const SizedBox(height: 16),

              /// PASSWORD
              AuthInput(
                hint: "Password",
                icon: Icons.lock_outline,
                controller: passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 12),

              /// REMEMBER + FORGOT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (_) {},
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
                  Text(
                    "Forget Password?",
                    style: AppTypography.bodySmall.copyWith(
                      color: VitalRed.vitalRed500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// LOGIN BUTTON
              AuthButton(
                text: "Log In",
                onPressed: () {},
              ),

              const SizedBox(height: 24),

              /// DIVIDER
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

              /// GOOGLE BUTTON
              SocialButton(
                text: "Log In With Google",
                assetPath: "assets/icons/google.svg",
                onPressed: () {},
              ),

              const SizedBox(height: 12),

              /// APPLE BUTTON
              SocialButton(
                text: "Log In With Apple",
                assetPath: "assets/icons/apple.svg",
                onPressed: () {},
              ),

              const SizedBox(height: 40),

              /// FOOTER
              Center(
                child: AuthFooter(
                  text: "Don't have an account? ",
                  actionText: "Sign Up",
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}