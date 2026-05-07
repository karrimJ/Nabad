import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'doctor_list_screen.dart';

class AppointmentBookingScreen extends StatelessWidget {
  const AppointmentBookingScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('city', isEqualTo: 'Tripoli')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: VitalRed.vitalRed500),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No services available',
                style: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral700,
                ),
              ),
            );
          }

          final services = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Select a Service',
                style: AppTypography.bodyLarge.copyWith(
                  color: Neutral.neutral700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...services.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _serviceCard(context, doc.id, data);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _serviceCard(
      BuildContext context, String docId, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorListScreen(
              serviceId: docId,
              serviceName: data['name'] ?? 'Service',
            ),
          ),
        );
      },
      child: Container(
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
                    data['name'] ?? 'Service',
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
                  if (data['isEmergencyAvailable'] == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      '24/7 Emergency Available',
                      style: AppTypography.bodySmall.copyWith(
                        color: Success.success500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Neutral.neutral500,
            ),
          ],
        ),
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