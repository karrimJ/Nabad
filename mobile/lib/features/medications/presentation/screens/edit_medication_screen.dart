import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';
import '../../../../services/medication_service.dart';
import '../../../../services/notification_service.dart';
import '../../data/medication_model.dart';

class EditMedicationScreen extends StatefulWidget {
  final MedicationModel medication;
  const EditMedicationScreen({super.key, required this.medication});

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();

  int _selectedFrequency = 0;
  bool _isLoading = false;

  final _medicationService = MedicationService();
  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.medication.medicationName;
    _dosageController.text = widget.medication.dosage;
    _timeController.text = widget.medication.specificTimes;
    _dateController.text = widget.medication.startDate;
    _selectedFrequency = widget.medication.frequency == 'Daily' ? 1 : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day} ${_monthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m - 1];
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name and dosage')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _medicationService.updateMedication(widget.medication.id, {
        'medicationName': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'specificTimes': _timeController.text.trim(),
        'frequency': _selectedFrequency == 0 ? 'Once' : 'Daily',
        'startDate': _dateController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication updated!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMedication() async {
    setState(() => _isLoading = true);
    try {
      await _medicationService.deleteMedication(widget.medication.id);
      await _notificationService
          .cancelReminder(widget.medication.id.hashCode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication deleted')),
        );
        Navigator.pop(context);
        Navigator.pop(context); // go back to list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium
                .copyWith(color: Neutral.neutral500),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Neutral.neutral100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Neutral.neutral400, width: 1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Neutral.neutral400, width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Neutral.neutral400, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequency',
            style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Neutral.neutral100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Neutral.neutral400, width: 1),
          ),
          child: Row(
            children: [
              _toggleSide('Once', 0),
              _toggleSide('Daily', 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleSide(String text, int value) {
    final isSelected = _selectedFrequency == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFrequency = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? VitalRed.vitalRed500 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(text,
              style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : Neutral.neutral600,
                  fontWeight: FontWeight.w500)),
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
        title: Text('Edit Medication',
            style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField(
                      label: 'Medication Name',
                      controller: _nameController,
                      hint: 'e.g Paracetamol'),
                  const SizedBox(height: 20),
                  _buildField(
                      label: 'Dosage',
                      controller: _dosageController,
                      hint: '500 mg'),
                  const SizedBox(height: 20),
                  _buildField(
                      label: 'Time',
                      controller: _timeController,
                      hint: '08:00 AM',
                      readOnly: true,
                      onTap: _pickTime),
                  const SizedBox(height: 20),
                  _buildFrequencyToggle(),
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Start Date',
                    controller: _dateController,
                    hint: '15 May 2025',
                    readOnly: true,
                    onTap: _pickDate,
                    suffixIcon: const Icon(Icons.calendar_today_outlined,
                        color: Neutral.neutral600, size: 20),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                AuthButton(
                  text: 'Save Changes',
                  onPressed: _isLoading ? () {} : _saveChanges,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _deleteMedication,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Neutral.neutral100,
                      borderRadius: BorderRadius.circular(28),
                      border:
                          Border.all(color: Neutral.neutral400, width: 1),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text('Delete Medication',
                            style: AppTypography.bodyLarge.copyWith(
                                color: VitalRed.vitalRed500,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}