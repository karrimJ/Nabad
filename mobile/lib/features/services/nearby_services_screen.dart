import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  String _selectedType = 'All';

  final List<String> _types = ['All', 'Hospital', 'Pharmacy', 'Clinic', 'Lab'];

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
          'Nearby Services',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _typeFilter(),
          Expanded(child: _servicesList()),
        ],
      ),
    );
  }

  Widget _typeFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? VitalRed.vitalRed500 : Neutral.neutral100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : Neutral.neutral900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _servicesList() {
    Query query = FirebaseFirestore.instance
        .collection('services')
        .where('city', isEqualTo: 'Tripoli');

    if (_selectedType != 'All') {
      query = query.where('type', isEqualTo: _selectedType);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: VitalRed.vitalRed500),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No services found',
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _serviceCard(data);
          },
        );
      },
    );
  }

  Widget _serviceCard(Map<String, dynamic> data) {
    final phoneNumber = data['phoneNumber']?.toString() ?? '';
    final hasPhone = phoneNumber.isNotEmpty;
    final isEmergency = data['isEmergencyAvailable'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(data['type'] ?? ''),
              color: VitalRed.vitalRed500,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Unknown',
                  style: AppTypography.bodyLarge.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data['type'] ?? ''} • ${data['address'] ?? ''}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral600,
                  ),
                ),
                if (hasPhone) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: Neutral.neutral600),
                      const SizedBox(width: 4),
                      Text(
                        phoneNumber,
                        style: AppTypography.bodySmall.copyWith(
                          color: Neutral.neutral700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isEmergency) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: VitalRed.vitalRed500,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '24/7 Emergency',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.medication;
      case 'clinic':
        return Icons.medical_services;
      case 'lab':
        return Icons.science;
      default:
        return Icons.place;
    }
  }
}