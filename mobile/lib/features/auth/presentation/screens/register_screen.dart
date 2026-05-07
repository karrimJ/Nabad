import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../components/auth_button.dart';
import '../components/auth_footer.dart';
import '../components/auth_header.dart';
import '../components/auth_input.dart';
import '../components/social_button.dart';
import '../../../../widgets/main_navigation.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _privacyConsent = false;
  bool _healthDataConsent = false;
  bool _isLoading = false;

  static const String consentVersion = '1.0';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyConsentScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyConsentScreen()),
    );

    if (result == true) {
      setState(() {
        _privacyConsent = true;
        _healthDataConsent = true;
      });
    }
  }

  Future<void> _register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (!_privacyConsent || !_healthDataConsent) {
      _showMessage('You must accept the privacy consent before signing up.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;

      if (user == null) {
        _showMessage('Signup failed. Please try again.');
        return;
      }

      final uid = user.uid;
      final now = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'createdAt': now,

        // GDPR/privacy consent summary on user document
        'privacyConsentGranted': true,
        'privacyConsentVersion': consentVersion,
        'privacyConsentGrantedAt': now,

        // Health app specific consent
        'healthDataConsentGranted': true,
        'healthDataConsentVersion': consentVersion,
        'healthDataConsentGrantedAt': now,
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('privacyConsents')
          .doc('current')
          .set({
            'accepted': true,
            'version': consentVersion,
            'acceptedAt': now,
            'source': 'signup',
            'platform': Theme.of(context).platform.name,
            'consentText':
                'User consented to Nabad collecting and storing account data, health profile data, vitals, medications, medical ID information, emergency contacts, wearable readings, SOS logs, appointments, notifications, uploaded files, and app activity needed to provide Nabad features.',
            'purposes': [
              'Create and manage user account',
              'Track vitals and health readings',
              'Manage medications and reminders',
              'Store medical ID and emergency information',
              'Support SOS and nearby medical services features',
              'Store wearable/device readings when connected',
              'Improve user safety and app reliability',
            ],
            'dataCategories': [
              'Email/account identifier',
              'Vitals readings',
              'Medication records',
              'Medical ID information',
              'Emergency contacts',
              'SOS logs and location when SOS is used',
              'Wearable/device readings',
              'Appointments and notifications',
              'Uploaded medical files if added by user',
            ],
            'withdrawalNotice':
                'User can request withdrawal/deletion from privacy settings or by contacting the Nabad team.',
          }, SetOptions(merge: true));

      if (!mounted) return;

      _showMessage('Account created successfully.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Signup failed.');
    } catch (e) {
      _showMessage('Something went wrong: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: VitalRed.vitalRed500),
    );
  }

  void _showSocialSignupMessage() {
    _showMessage('Please use email signup for now so consent is recorded.');
  }

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
              const SizedBox(height: 40),

              AuthHeader(
                title: 'Create your Nabad\naccount',
                subtitle:
                    'Join Nabad to track your vitals, manage your medications, and monitor your wellbeing — all in one place.',
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

              const SizedBox(height: 16),

              AuthInput(
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                controller: confirmController,
                isPassword: true,
              ),

              const SizedBox(height: 20),

              _ConsentCard(
                privacyConsent: _privacyConsent,
                healthDataConsent: _healthDataConsent,
                onPrivacyChanged: (value) {
                  setState(() => _privacyConsent = value ?? false);
                },
                onHealthChanged: (value) {
                  setState(() => _healthDataConsent = value ?? false);
                },
                onOpenDetails: _openPrivacyConsentScreen,
              ),

              const SizedBox(height: 24),

              AuthButton(
                text: _isLoading ? 'Creating account...' : 'Sign up',
                onPressed: _isLoading
                    ? () {}
                    : () {
                        _register();
                      },
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
                onPressed: _showSocialSignupMessage,
              ),

              const SizedBox(height: 12),

              SocialButton(
                text: 'Log In With Apple',
                assetPath: 'assets/icons/apple.svg',
                onPressed: _showSocialSignupMessage,
              ),

              const SizedBox(height: 60),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },

                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Neutral.neutral600,
                      ),

                      children: [
                        TextSpan(
                          text: 'Login',
                          style: AppTypography.bodyMedium.copyWith(
                            color: VitalRed.vitalRed500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _ConsentCard extends StatelessWidget {
  final bool privacyConsent;
  final bool healthDataConsent;
  final ValueChanged<bool?> onPrivacyChanged;
  final ValueChanged<bool?> onHealthChanged;
  final VoidCallback onOpenDetails;

  const _ConsentCard({
    required this.privacyConsent,
    required this.healthDataConsent,
    required this.onPrivacyChanged,
    required this.onHealthChanged,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Neutral.neutral300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip_outlined, color: VitalRed.vitalRed500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy Consent',
                  style: AppTypography.headingSmall.copyWith(
                    color: Neutral.neutral800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenDetails,
                child: Text(
                  'View',
                  style: AppTypography.bodySmall.copyWith(
                    color: VitalRed.vitalRed500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          CheckboxListTile(
            value: privacyConsent,
            onChanged: onPrivacyChanged,
            activeColor: VitalRed.vitalRed500,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I consent to Nabad collecting and storing my account data to provide app features.',
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral700,
              ),
            ),
          ),

          CheckboxListTile(
            value: healthDataConsent,
            onChanged: onHealthChanged,
            activeColor: VitalRed.vitalRed500,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I explicitly consent to Nabad processing my health-related data such as vitals, medications, medical ID, and wearable readings.',
              style: AppTypography.bodySmall.copyWith(
                color: Neutral.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        iconTheme: IconThemeData(color: Neutral.neutral800),
        title: Text(
          'Privacy & Data Consent',
          style: AppTypography.headingSmall.copyWith(color: Neutral.neutral800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(text: 'What data Nabad collects'),
                    _BulletText(text: 'Account information such as email.'),
                    _BulletText(
                      text:
                          'Vitals such as heart rate, oxygen level, blood pressure, temperature, and glucose.',
                    ),
                    _BulletText(text: 'Medication information and reminders.'),
                    _BulletText(
                      text: 'Medical ID and emergency contact information.',
                    ),
                    _BulletText(
                      text:
                          'SOS logs and location only when emergency/SOS features are used.',
                    ),
                    _BulletText(
                      text:
                          'Wearable readings only when a wearable/device is connected.',
                    ),
                    _BulletText(
                      text: 'Uploaded medical files only when you add them.',
                    ),

                    const SizedBox(height: 20),

                    _SectionTitle(text: 'Why Nabad collects this data'),
                    _BulletText(text: 'To create and manage your account.'),
                    _BulletText(
                      text: 'To help you monitor your health information.',
                    ),
                    _BulletText(
                      text:
                          'To support medication reminders and emergency features.',
                    ),
                    _BulletText(
                      text:
                          'To show your medical ID during emergency workflows.',
                    ),
                    _BulletText(
                      text:
                          'To improve safety, reliability, and app functionality.',
                    ),

                    const SizedBox(height: 20),

                    _SectionTitle(text: 'Your control'),
                    _BulletText(
                      text: 'You can request access to your stored data.',
                    ),
                    _BulletText(
                      text:
                          'You can request correction or deletion of your data.',
                    ),
                    _BulletText(
                      text:
                          'You can withdraw consent later from privacy settings or by contacting the Nabad team.',
                    ),
                    _BulletText(
                      text:
                          'Withdrawal does not affect processing already completed before withdrawal.',
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Neutral.neutral300,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'By accepting, you confirm that you understand what data Nabad collects, why it is collected, and that you explicitly consent to the processing of health-related data.',
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    CheckboxListTile(
                      value: _accepted,
                      onChanged: (value) {
                        setState(() => _accepted = value ?? false);
                      },
                      activeColor: VitalRed.vitalRed500,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'I have read and accept the Privacy & Data Consent.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Neutral.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Neutral.neutral400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTypography.buttonText.copyWith(
                          color: Neutral.neutral700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _accepted
                          ? () {
                              Navigator.pop(context, true);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VitalRed.vitalRed500,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Neutral.neutral400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: AppTypography.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.headingSmall.copyWith(color: Neutral.neutral800),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTypography.bodyMedium.copyWith(
              color: VitalRed.vitalRed500,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
