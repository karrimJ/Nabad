import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

import '../data/vital_type.dart';
import '../data/vital_reading_model.dart';
import '../data/vitals_service.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _valueController = TextEditingController();
  final _dateController  = TextEditingController();
  final _timeController  = TextEditingController();
  final _notesController = TextEditingController();

  final VitalsService _vitalsService = VitalsService();

  /// Display label, e.g. 'Heart Rate'. Mapped to VitalType on save.
  String _vitalType = VitalType.displayLabels.first;

  /// Backing date and time for the controllers — kept in sync via
  /// [_pickDate] and [_pickTime] so the saved Timestamp matches what the
  /// user picked exactly.
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _dateController.text = _formatDate(_selectedDate);
    // _timeController is filled in didChangeDependencies because
    // TimeOfDay.format(context) needs a BuildContext.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _unit =>
      VitalType.unitFor(VitalType.fromDisplayLabel(_vitalType));

  bool get _isBloodPressure => _vitalType == 'Blood Pressure';

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  // ── Pickers ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  // ── Save flow ─────────────────────────────────────────────────────────
  Future<void> _save() async {
    final raw = _valueController.text.trim();

    if (raw.isEmpty) {
      _showMessage('Reading value is required.');
      return;
    }

    final type = VitalType.fromDisplayLabel(_vitalType);
    final unit = VitalType.unitFor(type);

    final recordedAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final notes = _notesController.text.trim();
    final notesOrNull = notes.isEmpty ? null : notes;

    VitalReadingModel reading;

    if (_isBloodPressure) {
      // Expected format: "120/80" (with optional spaces).
      final parts = raw.split('/');
      if (parts.length != 2) {
        _showMessage('Blood pressure must be entered as "systolic/diastolic", e.g. 120/80.');
        return;
      }
      final sys = double.tryParse(parts[0].trim());
      final dia = double.tryParse(parts[1].trim());
      if (sys == null || dia == null || sys <= 0 || dia <= 0) {
        _showMessage('Both blood pressure values must be positive numbers.');
        return;
      }

      reading = VitalReadingModel.bloodPressure(
        systolic: sys,
        diastolic: dia,
        recordedAt: recordedAt,
        notes: notesOrNull,
      );
    } else {
      final v = double.tryParse(raw);
      if (v == null || v <= 0) {
        _showMessage('Reading must be a positive number.');
        return;
      }

      reading = VitalReadingModel.singleValue(
        type: type,
        value: v,
        unit: unit,
        recordedAt: recordedAt,
        notes: notesOrNull,
      );
    }

    setState(() => _isSaving = true);

    try {
      await _vitalsService.addManualReading(reading);

      if (!mounted) return;
      _showMessage('Reading saved.', isError: false);
      Navigator.pop(context);
    } on VitalsException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not save reading: $e');
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

  // ── UI builders (UI unchanged) ────────────────────────────────────────
  Widget _label(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTypography.bodyMedium.copyWith(
                color: VitalRed.vitalRed500,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _decoration({Widget? suffix, String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: Neutral.neutral500),
      suffixIcon: suffix,
      filled: true,
      fillColor: Neutral.neutral100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Neutral.neutral400, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Neutral.neutral400, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Neutral.neutral400, width: 1),
      ),
    );
  }

  Widget _buildVitalTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Vital Type'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Neutral.neutral100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Neutral.neutral400, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _vitalType,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Neutral.neutral700,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800,
              ),
              dropdownColor: Neutral.neutral100,
              items: VitalType.displayLabels
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _vitalType = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Reading Value'),
        TextField(
          controller: _valueController,
          // BP needs '/' which the numeric keyboard does not always expose.
          keyboardType: _isBloodPressure
              ? TextInputType.text
              : const TextInputType.numberWithOptions(decimal: true),
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: _decoration(
            suffix: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _unit,
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            ),
          ).copyWith(
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Date'),
        TextField(
          controller: _dateController,
          readOnly: true,
          onTap: _isSaving ? null : _pickDate,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: _decoration(
            suffix: const Icon(
              Icons.calendar_today_outlined,
              color: Neutral.neutral600,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Time'),
        TextField(
          controller: _timeController,
          readOnly: true,
          onTap: _isSaving ? null : _pickTime,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: _decoration(
            suffix: const Icon(
              Icons.access_time,
              color: Neutral.neutral600,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Notes (optional)', required: false),
        TextField(
          controller: _notesController,
          maxLines: 4,
          style: AppTypography.bodyMedium.copyWith(color: Neutral.neutral800),
          decoration: _decoration(hint: 'Add a note ....'),
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
          border: Border.all(color: VitalRed.vitalRed500, width: 1.5),
        ),
        child: Text(
          'Cancel',
          style: AppTypography.bodyLarge.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
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
          'Add Reading',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVitalTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildReadingValue(),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTimeField(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                AuthButton(
                  text: _isSaving ? 'Saving...' : 'Save Reading',
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