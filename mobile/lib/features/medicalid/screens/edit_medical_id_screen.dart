import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

class EditMedicalIdScreen extends StatefulWidget {
  const EditMedicalIdScreen({super.key});

  @override
  State<EditMedicalIdScreen> createState() => _EditMedicalIdScreenState();
}

class _EditMedicalIdScreenState extends State<EditMedicalIdScreen> {
  final _nameController = TextEditingController(text: 'Karim Jundi');
  final _allergiesController = TextEditingController(text: 'Penicillin');
  final _conditionsController = TextEditingController(text: 'Hypertension');
  final _medicationsController =
      TextEditingController(text: 'Paracetamol, Metformin');
  final _dateController = TextEditingController(text: 'August 3, 2005');

  final _emergencyNameController = TextEditingController(text: 'Sarah');
  final _emergencyRelationController = TextEditingController(text: 'Sister');
  final _emergencyPhoneController =
      TextEditingController(text: '+961 71 015 648');

  String _bloodType = 'AB+';
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 8, 3),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      setState(() {
        _dateController.text =
            '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
      });
    }
  }

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
      onTap: () => Navigator.pop(context),
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
          onPressed: () => Navigator.pop(context),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  text: 'Save Medical ID',
                  onPressed: () {
                    Navigator.pop(context);
                  },
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