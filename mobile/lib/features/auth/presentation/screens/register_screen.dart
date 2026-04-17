import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../components/auth_input.dart';
import '../components/auth_button.dart';
import '../components/auth_header.dart';
import '../components/auth_footer.dart';
import '../components/social_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 TOP SPACING (important for design)
              const SizedBox(height: 40),

              /// HEADER
              AuthHeader(
                title: "Create your Nabad\naccount",
                subtitle:
                    "Join Nabad to track your vitals, manage your medications, and monitor your wellbeing — all in one place.",
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

              const SizedBox(height: 16),

              /// CONFIRM PASSWORD
              AuthInput(
                hint: "Confirm Password",
                icon: Icons.lock_outline,
                controller: confirmController,
                isPassword: true,
              ),

              const SizedBox(height: 24),

              /// SIGN UP BUTTON
              AuthButton(
                text: "Sign up",
                onPressed: () {
                  if (passwordController.text != confirmController.text) {
                    debugPrint("Passwords do not match");
                  }
                },
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

              /// GOOGLE
              SocialButton(
                text: "Log In With Google",
                assetPath: "assets/icons/google.svg",
                onPressed: () {},
              ),

              const SizedBox(height: 12),

              /// APPLE
              SocialButton(
                text: "Log In With Apple",
                assetPath: "assets/icons/apple.svg",
                onPressed: () {},
              ),

              /// 🔥 PUSH FOOTER DOWN (important)
              const SizedBox(height: 60),

              /// FOOTER
              Center(
                child: AuthFooter(
                  text: "Already have an account? ",
                  actionText: "Login",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}