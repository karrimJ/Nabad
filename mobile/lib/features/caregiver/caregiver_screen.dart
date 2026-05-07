import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  final _emailController = TextEditingController();
  bool _isAdding = false;
  List<String> _linkedEmails = [];

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data();
    if (data != null && data['linkedAccounts'] != null) {
      setState(() {
        _linkedEmails = List<String>.from(data['linkedAccounts']);
      });
    }
  }

  Future<void> _addCaregiver() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isAdding = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'linkedAccounts': FieldValue.arrayUnion([email]),
    }, SetOptions(merge: true));

    setState(() {
      _linkedEmails.add(email);
      _isAdding = false;
    });

    _emailController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$email added as caregiver'),
        backgroundColor: Success.success500,
      ),
    );
  }

  Future<void> _removeCaregiver(String email) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
      'linkedAccounts': FieldValue.arrayRemove([email]),
    });

    setState(() => _linkedEmails.remove(email));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
          'Family & Caregiver',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 24),
            Text(
              'Add Caregiver',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _addCaregiverCard(),
            const SizedBox(height: 24),
            Text(
              'Linked Caregivers',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_linkedEmails.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Neutral.neutral100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'No caregivers added yet',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Neutral.neutral600,
                    ),
                  ),
                ),
              )
            else
              ..._linkedEmails.map((email) => _caregiverTile(email)),
            const SizedBox(height: 24),
            Text(
              'Live Vitals View',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (uid != null) _liveVitalsCard(uid),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AccentRed.accentRed100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: VitalRed.vitalRed500, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add a family member or caregiver by email. They can monitor your vitals in real-time.',
              style: AppTypography.bodySmall.copyWith(
                color: VitalRed.vitalRed500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addCaregiverCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral900,
            ),
            decoration: InputDecoration(
              hintText: 'Enter caregiver email',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral500,
              ),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Neutral.neutral600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Neutral.neutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Neutral.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: VitalRed.vitalRed500),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _isAdding ? null : _addCaregiver,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: VitalRed.vitalRed500,
                borderRadius: BorderRadius.circular(24),
              ),
              child: _isAdding
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : Text(
                      'Add Caregiver',
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

  Widget _caregiverTile(String email) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AccentRed.accentRed100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: VitalRed.vitalRed500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              email,
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: VitalRed.vitalRed500),
            onPressed: () => _removeCaregiver(email),
          ),
        ],
      ),
    );
  }

  Widget _liveVitalsCard(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('iotReadings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .map((snap) => snap.docs.first),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Neutral.neutral100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'No live vitals yet — connect a wearable or start simulation',
                style: AppTypography.bodySmall.copyWith(
                  color: Neutral.neutral600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Neutral.neutral100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Success.success500, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: AppTypography.bodySmall.copyWith(
                      color: Success.success500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _vitalRow('❤️ Heart Rate', '${data['heartRate'] ?? '--'} bpm'),
              _vitalRow('🌡️ Temperature', '${data['temperature'] ?? '--'}°C'),
              _vitalRow('💧 SpO₂', '${data['oxygenLevel'] ?? '--'}%'),
              _vitalRow('👟 Steps', '${data['steps'] ?? '--'}'),
              _vitalRow('🩺 Blood Pressure',
                  '${data['systolic'] ?? '--'}/${data['diastolic'] ?? '--'}'),
            ],
          ),
        );
      },
    );
  }

  Widget _vitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral700,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}