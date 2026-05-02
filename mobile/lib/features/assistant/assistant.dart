import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';

class NabadAssistantScreen extends StatefulWidget {
  const NabadAssistantScreen({super.key});

  @override
  State<NabadAssistantScreen> createState() => _NabadAssistantScreenState();
}

class _NabadAssistantScreenState extends State<NabadAssistantScreen> {
  final _messageController = TextEditingController();

  final List<String> _suggestions = [
    'Explain my blood pressure reading',
    'Is my temperature normal?',
    'When is my next medication?',
    'What does my heart rate mean?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
          'Nabad Assistant',
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _avatar(),
                  const SizedBox(height: 24),
                  Text(
                    "Hi, I'm your Nabad Assistant",
                    textAlign: TextAlign.center,
                    style: AppTypography.headingLarge.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "I'm here to help you understand your vitals, medications, and health insights.\nAsk me anything about your health data or daily wellbeing.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Neutral.neutral700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Some Suggestions',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Neutral.neutral900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _suggestionChips(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: Neutral.neutral200,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            bottom: 24,
            child: Container(
              width: 110,
              height: 100,
              decoration: BoxDecoration(
                color: Neutral.neutral100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AccentRed.accentRed100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: VitalRed.vitalRed500,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Head
          Positioned(
            top: 30,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFF4D5B5),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hair
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 70,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B4226),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                    ),
                  ),
                  // Eyes
                  Positioned(
                    top: 32,
                    left: 18,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Neutral.neutral900,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 32,
                    right: 18,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Neutral.neutral900,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Smile
                  const Positioned(
                    bottom: 16,
                    child: Icon(Icons.sentiment_satisfied_alt, size: 0),
                  ),
                ],
              ),
            ),
          ),
          // Waving hand
          Positioned(
            top: 50,
            left: 18,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFF4D5B5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: _suggestions.map((s) => _chip(s)).toList(),
    );
  }

  Widget _chip(String text) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AccentRed.accentRed100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Neutral.neutral100,
        boxShadow: [
          BoxShadow(
            color: Neutral.neutral900.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: Neutral.neutral600,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800,
              ),
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Neutral.neutral600),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () {
              _messageController.clear();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Neutral.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send,
                color: Neutral.neutral700,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
