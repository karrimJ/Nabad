import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

import '../data/medical_info_model.dart';
import '../data/medical_info_service.dart';

class EditMedicalIdScreen extends StatefulWidget {
  const EditMedicalIdScreen({super.key});

  @override
  State<EditMedicalIdScreen> createState() => _EditMedicalIdScreenState();
}

class _EditMedicalIdScreenState extends State<EditMedicalIdScreen> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _dateController = TextEditingController();

  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final MedicalInfoService _medicalInfoService = MedicalInfoService();

  String _bloodType = 'AB+';
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  /// Backing DateTime for the date controller string.
  DateTime? _selectedDate;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _dateController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalInfo() async {
    try {
      final info = await _medicalInfoService.getMedicalInfo();
      if (!mounted) return;

      _nameController.text = info.fullName;
      _allergiesController.text = info.allergies;
      _conditionsController.text = info.chronicConditions;
      _medicationsController.text = info.currentMedications;

      if (info.dateOfBirth != null) {
        _selectedDate = info.dateOfBirth;
        _dateController.text = _formatDate(info.dateOfBirth!);
      }

      if (info.bloodType.isNotEmpty && _bloodTypes.contains(info.bloodType)) {
        _bloodType = info.bloodType;
      }

      _emergencyNameController.text = info.emergencyContact.name;
      _emergencyRelationController.text = info.emergencyContact.relationship;
      _emergencyPhoneController.text = info.emergencyContact.phone;
    } on MedicalInfoException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not load Medical ID: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    final fullName = _nameController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Full name cannot be empty.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final info = MedicalInfoModel(
        fullName: fullName,
        bloodType: _bloodType,
        dateOfBirth: _selectedDate,
        allergies: _allergiesController.text.trim(),
        chronicConditions: _conditionsController.text.trim(),
        currentMedications: _medicationsController.text.trim(),
        emergencyContact: EmergencyContact(
          name: _emergencyNameController.text.trim(),
          relationship: _emergencyRelationController.text.trim(),
          phone: _emergencyPhoneController.text.trim(),
        ),
      );

      await _medicalInfoService.saveMedicalInfo(info);

      if (!mounted) return;
      _showMessage('Medical ID saved.', isError: false);
      Navigator.pop(context);
    } on MedicalInfoException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not save Medical ID: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2005, 8, 3),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

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
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
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

  Widget _buildBloodTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Type',
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Neutral.neutral100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Neutral.neutral400, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _bloodType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Neutral.neutral700),
              style: AppTypography.bodyMedium
                  .copyWith(color: Neutral.neutral800),
              dropdownColor: Neutral.neutral100,
              items: _bloodTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _bloodType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contact',
          style: AppTypography.bodyMedium.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Neutral.neutral100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Neutral.neutral400, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _emergencySubField('Name', _emergencyNameController),
              const SizedBox(height: 12),
              _emergencySubField('Relationship', _emergencyRelationController),
              const SizedBox(height: 12),
              _emergencySubField('Phone', _emergencyPhoneController),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emergencySubField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Neutral.neutral200,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Neutral.neutral400, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cancelButton() {
    return GestureDetector(
      onTap: _isSaving ? null : () => Navigator.pop(context),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Neutral.neutral400, width: 1),
        ),
        child: Text(
          'Cancel',
          style: AppTypography.bodyLarge.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
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
      appBar: AppBar(
        backgroundColor: Neutral.neutral300,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Neutral.neutral900),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Medical ID',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VitalRed.vitalRed500),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          label: 'Full Name',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildBloodTypeDropdown(),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Date of Birth',
                          controller: _dateController,
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Neutral.neutral600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Allergies',
                          controller: _allergiesController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Chronic Conditions',
                          controller: _conditionsController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Current Medications',
                          controller: _medicationsController,
                        ),
                        const SizedBox(height: 16),
                        _buildEmergencyContactSection(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      AuthButton(
                        text: _isSaving ? 'Saving...' : 'Save Medical ID',
                        onPressed: _isSaving ? () {} : _save,
                      ),
                      const SizedBox(height: 12),
                      _cancelButton(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}