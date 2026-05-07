import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

import 'data/user_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  final UserProfileService _profileService = UserProfileService();

  bool _isLoading = true;
  bool _isSaving = false;

  /// Preserved across save so that a future "Change Picture" feature
  /// (Firebase Storage) does not get clobbered by this screen.
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;

      if (profile != null) {
        _nameController.text = profile.displayName;
        _phoneController.text = profile.phone ?? '';
        _bioController.text = profile.bio ?? '';
        _photoUrl = profile.photoUrl;
      }
    } on ProfileException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not load profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final phone = _phoneController.text.trim();
      final bio = _bioController.text.trim();

      await _profileService.updateProfile(
        displayName: name,
        phone: phone.isEmpty ? null : phone,
        bio: bio.isEmpty ? null : bio,
        photoUrl: _photoUrl,
      );

      if (!mounted) return;
      _showMessage('Profile saved.', isError: false);
      Navigator.pop(context);
    } on ProfileException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not save profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? VitalRed.vitalRed500 : Success.success500,
      ),
    );
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
        // TODO: handle picture change (requires firebase_storage)
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VitalRed.vitalRed500,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──────────────────────────────────────────
                    Text(
                      'Profile',
                      style: AppTypography.headingLarge.copyWith(
                        color: Neutral.neutral900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Avatar + Change Picture ────────────────────────
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

                    // ── Fields ─────────────────────────────────────────
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

                    // ── Save button ────────────────────────────────────
                    AuthButton(
                      text: _isSaving ? 'Saving...' : 'Save',
                      onPressed: _isSaving ? () {} : _save,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}