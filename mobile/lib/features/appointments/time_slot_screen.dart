import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class TimeSlotScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final String doctorId;
  final String doctorName;
  final String specialty;

  const TimeSlotScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
  });

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _isBooking = false;

  final List<String> _timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
  ];

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: VitalRed.vitalRed500,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isBooking = false);
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .add({
      'doctorName': widget.doctorName,
      'specialty': widget.specialty,
      'serviceName': widget.serviceName,
      'date': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      'time': _selectedSlot,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isBooking = false);

    if (!mounted) return;
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Neutral.neutral100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Success.success100,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.check,
                color: Success.success500,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Appointment Confirmed!',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.doctorName}\n$_selectedSlot on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pop(context);
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
                'Done',
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Neutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Appointment',
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _doctorSummaryCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Select Date',
                    style: AppTypography.headingSmall.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dateSelector(),
                  const SizedBox(height: 24),
                  Text(
                    'Select Time',
                    style: AppTypography.headingSmall.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _timeSlotGrid(),
                ],
              ),
            ),
          ),
          _confirmButton(),
        ],
      ),
    );
  }

  Widget _doctorSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AccentRed.accentRed100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.person, color: VitalRed.vitalRed500, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: AppTypography.bodyLarge.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.specialty,
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral600,
                  ),
                ),
                Text(
                  widget.serviceName,
                  style: AppTypography.bodySmall.copyWith(
                    color: VitalRed.vitalRed500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index + 1));
          final isSelected = _selectedDate.day == date.day &&
              _selectedDate.month == date.month;
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayName = days[date.weekday - 1];

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? VitalRed.vitalRed500 : Neutral.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? Colors.white : Neutral.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: AppTypography.headingSmall.copyWith(
                      color: isSelected ? Colors.white : Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _timeSlotGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final slot = _timeSlots[index];
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? VitalRed.vitalRed500 : Neutral.neutral100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              slot,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? Colors.white : Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _confirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _isBooking ? null : _confirmBooking,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: VitalRed.vitalRed500,
            borderRadius: BorderRadius.circular(28),
          ),
          child: _isBooking
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3)
              : Text(
                  'Confirm Appointment',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}