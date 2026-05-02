import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';

class AddReadingScreen extends StatefulWidget {
  const AddReadingScreen({super.key});

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen> {
  final _valueController = TextEditingController(text: '78');
  final _dateController = TextEditingController(text: '15 May 2025');
  final _timeController = TextEditingController(text: '08:30 AM');
  final _notesController = TextEditingController();

  String _vitalType = 'Heart Rate';
  final List<String> _vitalTypes = [
    'Heart Rate',
    'Blood Pressure',
    'Temperature',
    'Oxygen Level',
  ];

  String get _unit {
    switch (_vitalType) {
      case 'Heart Rate':
        return 'bpm';
      case 'Blood Pressure':
        return 'mmHg';
      case 'Temperature':
        return '°C';
      case 'Oxygen Level':
        return '%';
      default:
        return '';
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      setState(() {
        _dateController.text =
            '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
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
      hintStyle:
          AppTypography.bodyMedium.copyWith(color: Neutral.neutral500),
      suffixIcon: suffix,
      filled: true,
      fillColor: Neutral.neutral100,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Neutral.neutral700),
              style: AppTypography.bodyMedium
                  .copyWith(color: Neutral.neutral800),
              dropdownColor: Neutral.neutral100,
              items: _vitalTypes
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
          keyboardType: TextInputType.number,
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
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
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
          onTap: _pickDate,
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
          onTap: _pickTime,
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
      onTap: () => Navigator.pop(context),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  text: 'Save Reading',
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