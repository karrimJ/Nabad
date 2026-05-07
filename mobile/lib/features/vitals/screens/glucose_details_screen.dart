import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/components/auth_button.dart';
import 'add_manual_reading_screen.dart';
import 'package:mobile/routes/app_routes.dart';


class GlucoseDetailsScreen extends StatefulWidget {
  const GlucoseDetailsScreen({super.key});

  @override
  State<GlucoseDetailsScreen> createState() => _GlucoseDetailsScreenState();
}

class _GlucoseDetailsScreenState extends State<GlucoseDetailsScreen> {
  int _selectedTab = 0;

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
          'Glucose Level',
          style: AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),
            const SizedBox(height: 24),
            Text(
              'Glucose Trend',
              style: AppTypography.headingSmall.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _dayWeekToggle(),
            const SizedBox(height: 16),
            _noDataChartCard(),
            const SizedBox(height: 16),
            _infoBanner(),
            const SizedBox(height: 16),
            _addReadingButton(),
            const SizedBox(height: 12),
            AuthButton(text: 'View History', onPressed: () {
              Navigator.pushNamed(context, AppRoutes.glucoseHistory);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '--',
                style: AppTypography.headingLarge.copyWith(
                  color: Neutral.neutral500,
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'mg/dL',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: Neutral.neutral500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PENDING',
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral100,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayWeekToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Neutral.neutral400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_toggleButton('Day', 0), _toggleButton('Week', 1)],
      ),
    );
  }

  Widget _toggleButton(String text, int value) {
    final selected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? VitalRed.vitalRed500 : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: selected ? Neutral.neutral100 : Neutral.neutral700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _noDataChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'No data yet',
          style: AppTypography.bodyLarge.copyWith(color: Neutral.neutral600),
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Neutral.neutral400,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.science_outlined,
            color: Neutral.neutral700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'There is no glucose data available yet.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Neutral.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please take a manual reading to start tracking your glucose level.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Neutral.neutral700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addReadingButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReadingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Neutral.neutral100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: VitalRed.vitalRed500, size: 22),
            const SizedBox(width: 12),
            Text(
              'Add Manual Reading',
              style: AppTypography.bodyLarge.copyWith(
                color: Neutral.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
