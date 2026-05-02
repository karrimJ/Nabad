import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Nabad Developer');
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ── Field builder ──────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral800,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral500,
            ),
            filled: true,
            fillColor: Neutral.neutral100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // ── Change Picture button ──────────────────────────────────────────────
  Widget _changePictureButton() {
    return GestureDetector(
      onTap: () {
        // TODO: handle picture change
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AccentRed.accentRed100,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: VitalRed.vitalRed500, width: 1),
        ),
        child: Text(
          'Change Picture',
          style: AppTypography.bodyMedium.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral300,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────
              Text(
                'Profile',
                style: AppTypography.headingLarge.copyWith(
                  color: Neutral.neutral900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // ── Avatar + Change Picture ────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Neutral.neutral400,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 70,
                        color: Neutral.neutral600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _changePictureButton(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Fields ─────────────────────────────────────────────
              _buildField(
                label: 'Name',
                controller: _nameController,
                hint: 'Nabad Developer',
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: 'your phone number....',
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Bio',
                controller: _bioController,
                hint: 'Bio, e. g...',
              ),
              const SizedBox(height: 32),

              // ── Save button ────────────────────────────────────────
              AuthButton(
                text: 'Save',
                onPressed: () {
                  // TODO: connect save API
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}