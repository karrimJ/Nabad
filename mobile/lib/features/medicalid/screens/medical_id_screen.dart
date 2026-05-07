import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

import '../../../widgets/main_navigation.dart';
import '../data/medical_info_model.dart';
import '../data/medical_info_service.dart';
import 'edit_medical_id_screen.dart';

class MedicalIdScreen extends StatefulWidget {
  const MedicalIdScreen({super.key});

  @override
  State<MedicalIdScreen> createState() => _MedicalIdScreenState();
}

class _MedicalIdScreenState extends State<MedicalIdScreen> {
  final MedicalInfoService _medicalInfoService = MedicalInfoService();

  @override
  void initState() {
    super.initState();
    _medicalInfoService.logAccess('viewed_medical_id');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  int _ageFrom(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  String _orDash(String? value) {
    if (value == null || value.isEmpty) return '—';
    return value;
  }

  String _buildQrPayload(MedicalInfoModel info, String displayName) {
    if (info.isEmpty) {
      return 'NABAD MEDICAL ID\n----------------\n'
          'No medical info entered yet.\nPlease contact the patient.';
    }

    final ageText = info.dateOfBirth != null
        ? _ageFrom(info.dateOfBirth!).toString()
        : '—';
    final name = info.fullName.isNotEmpty ? info.fullName : displayName;

    return '''
NABAD MEDICAL ID
----------------
Name: $name
Age: $ageText
Blood Type: ${_orDash(info.bloodType)}
Allergies: ${_orDash(info.allergies)}
Conditions: ${_orDash(info.chronicConditions)}
Medications: ${_orDash(info.currentMedications)}
----------------
EMERGENCY CONTACT
Name: ${_orDash(info.emergencyContact.name)} (${_orDash(info.emergencyContact.relationship)})
Phone: ${_orDash(info.emergencyContact.phone)}
----------------
In emergency, call: 140
''';
  }

  // ── QR dialog ───────────────────────────────────────────────────────────
  void _showQRCode(
    BuildContext context,
    MedicalInfoModel info,
    String displayName,
  ) {
    _medicalInfoService.logAccess('viewed_qr_code');

    final medicalData = _buildQrPayload(info, displayName);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Neutral.neutral100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Medical ID QR Code',
                  style: AppTypography.headingSmall.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan to view emergency medical info',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: medicalData,
                    version: QrVersions.auto,
                    size: 220,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AccentRed.accentRed100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⚠️ For emergency use only',
                    style: AppTypography.bodySmall.copyWith(
                      color: VitalRed.vitalRed500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: VitalRed.vitalRed500,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Close',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final fallbackEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return StreamBuilder<MedicalInfoModel>(
      stream: _medicalInfoService.medicalInfoStream(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final info = snapshot.data ?? MedicalInfoModel.empty();

        final displayName = info.fullName.isNotEmpty
            ? info.fullName
            : (fallbackEmail.isNotEmpty
                ? fallbackEmail.split('@').first
                : 'Nabad User');

        return Scaffold(
          backgroundColor: Neutral.neutral300,
          appBar: AppBar(
            backgroundColor: Neutral.neutral300,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Neutral.neutral900,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigation(),
                  ),
                );
              },
            ),
            title: Text(
              'Medical ID',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.qr_code,
                  color: VitalRed.vitalRed500,
                  size: 28,
                ),
                onPressed: isLoading
                    ? null
                    : () => _showQRCode(context, info, displayName),
                tooltip: 'Show QR Code',
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: VitalRed.vitalRed500,
                  ),
                )
              : hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load Medical ID: ${snapshot.error}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: VitalRed.vitalRed500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _userCard(displayName, info),
                          const SizedBox(height: 24),
                          _sectionTitle('Medical Information'),
                          const SizedBox(height: 12),
                          _infoCard([
                            _infoRow('Allergies', _orDash(info.allergies)),
                            _divider(),
                            _infoRow('Chronic Conditions',
                                _orDash(info.chronicConditions)),
                            _divider(),
                            _infoRow('Current Medications',
                                _orDash(info.currentMedications)),
                          ]),
                          const SizedBox(height: 24),
                          _sectionTitle('Emergency Contact'),
                          const SizedBox(height: 12),
                          _infoCard([
                            _infoRow('Name',
                                _orDash(info.emergencyContact.name)),
                            _divider(),
                            _infoRow('Relationship',
                                _orDash(info.emergencyContact.relationship)),
                            _divider(),
                            _infoRow('Phone',
                                _orDash(info.emergencyContact.phone)),
                          ]),
                          const SizedBox(height: 24),
                          Text(
                            'This information can be accessed during emergencies to help healthcare providers respond quickly.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Neutral.neutral600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _qrButton(context, info, displayName),
                          const SizedBox(height: 12),
                          _editButton(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  // ── Section helpers (UI unchanged, parameterized over data) ─────────────
  Widget _userCard(String displayName, MedicalInfoModel info) {
    final ageText = info.dateOfBirth != null
        ? '${_ageFrom(info.dateOfBirth!)} years'
        : '—';
    final bloodType = _orDash(info.bloodType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Neutral.neutral400,
            ),
            child: const Icon(
              Icons.person,
              size: 44,
              color: Neutral.neutral600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.headingSmall.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: $ageText',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
                Text(
                  'Blood Type: $bloodType',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: VitalRed.vitalRed500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.headingSmall.copyWith(
        color: Neutral.neutral900,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral800,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Neutral.neutral300,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _qrButton(
    BuildContext context,
    MedicalInfoModel info,
    String displayName,
  ) {
    return GestureDetector(
      onTap: () {
        _showQRCode(context, info, displayName);
      },
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: VitalRed.vitalRed500,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Show Emergency QR Code',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EditMedicalIdScreen(),
          ),
        );
      },
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          'Edit Medical ID',
          style: AppTypography.bodyLarge.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}