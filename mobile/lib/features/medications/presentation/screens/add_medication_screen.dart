import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../services/medication_service.dart';
import '../../../../services/notification_service.dart';
import '../../data/medication_model.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  int _selectedFrequency = 0;
  bool _isLoading = false;

  final _medicationService = MedicationService();
  final _notificationService = NotificationService();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
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

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name and dosage')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final med = MedicationModel(
        id: '',
        medicationName: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency == 0 ? 'Once' : 'Daily',
        specificTimes: _timeController.text.trim(),
        startDate: DateTime.now().toIso8601String(),
        endDate: '',
        instructions: '',
        medicineType: '',
        prescribedBy: '',
        color: '',
        reminderEnabled: _timeController.text.isNotEmpty,
        createdAt: DateTime.now(),
      );

      final docId = await _medicationService.addMedication(med);

      if (_timeController.text.isNotEmpty) {
        final timeParts = _parseTime(_timeController.text);
        if (timeParts != null) {
          await _notificationService.scheduleMedicationReminder(
            id: docId.hashCode,
            medicationName: med.medicationName,
            dosage: med.dosage,
            hour: timeParts[0],
            minute: timeParts[1],
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication saved!')),
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

  List<int>? _parseTime(String timeStr) {
    try {
      final cleaned = timeStr.toUpperCase().trim();
      final isPM = cleaned.contains('PM');
      final timePart = cleaned.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = timePart.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return [hour, minute];
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Neutral.neutral100,
      appBar: AppBar(
        backgroundColor: Neutral.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Medication",
          style: AppTypography.headingMedium.copyWith(color: Neutral.neutral900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField("Medication Name", "e.g Paracetamol", _nameController),
            const SizedBox(height: 20),
            _buildField("Dosage", "500 mg", _dosageController),
            const SizedBox(height: 20),
            _buildField("Time", "08:00 AM", _timeController,
                readOnly: true, onTap: _pickTime),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Frequency", style: AppTypography.bodyMedium),
            ),
            const SizedBox(height: 10),
            _buildFrequencyToggle(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VitalRed.vitalRed500,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Save Medication",
                        style: AppTypography.bodyMedium
                            .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap}) {
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
          decoration: InputDecoration(
            hintText: hint,
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
    return Container(
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
}