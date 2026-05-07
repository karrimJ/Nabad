import 'package:flutter/material.dart';
import 'package:mobile/theme/app_colors.dart';
import 'package:mobile/theme/app_typography.dart';
import '../chat bot/chatbot_service.dart';

class NabadAssistantScreen extends StatefulWidget {
  const NabadAssistantScreen({super.key});

  @override
  State<NabadAssistantScreen> createState() =>
      _NabadAssistantScreenState();
}

class _NabadAssistantScreenState
    extends State<NabadAssistantScreen> {
  final _messageController = TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final ChatbotService _service = ChatbotService();

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;
  bool _chatStarted = false;

  final List<String> _suggestions = [
    'Explain my blood pressure reading',
    'Is my temperature normal?',
    'When is my next medication?',
    'What does my heart rate mean?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) async {
    final message =
        (text ?? _messageController.text).trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });

      _isLoading = true;
      _chatStarted = true;
    });

    _messageController.clear();

    _scrollToBottom();

    final response =
        await _service.sendMessage(message);

    setState(() {
      _messages.add({
        'role': 'bot',
        'text': response,
      });

      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
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
          icon: const Icon(
            Icons.arrow_back,
            color: Neutral.neutral900,
          ),

          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Nabad Assistant',

          style:
              AppTypography.headingSmall.copyWith(
            color: Neutral.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: _chatStarted
                ? _buildChat()
                : _buildWelcome(),
          ),

          _inputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        children: [
          const SizedBox(height: 10),

          _avatar(),

          const SizedBox(height: 8),

          Text(
            "Hi, I’m your Nabad\nAssistant",

            textAlign: TextAlign.center,

            style:
                AppTypography.headingLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "I'm here to help you understand your vitals,\nmedications, and health insights.\nAsk me anything about your health data or daily\nwellbeing.",

            textAlign: TextAlign.center,

            style:
                AppTypography.bodyMedium.copyWith(
              color: Neutral.neutral700,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Some Suggestions',

            style:
                AppTypography.bodyLarge.copyWith(
              color: Neutral.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _suggestionChips(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return ListView.builder(
      controller: _scrollController,

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      itemCount:
          _messages.length + (_isLoading ? 1 : 0),

      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.only(
              left: 12,
              top: 8,
            ),

            child: Align(
              alignment: Alignment.centerLeft,

              child: CircularProgressIndicator(
                color: VitalRed.vitalRed500,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final msg = _messages[index];

        final isUser = msg['role'] == 'user';

        return Align(
          alignment: isUser
              ? Alignment.centerRight
              : Alignment.centerLeft,

          child: Container(
            margin:
                const EdgeInsets.symmetric(vertical: 6),

            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            constraints:
                const BoxConstraints(maxWidth: 280),

            decoration: BoxDecoration(
              color: isUser
                  ? VitalRed.vitalRed500
                  : Neutral.neutral100,

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              msg['text'] ?? '',

              style:
                  AppTypography.bodyMedium.copyWith(
                color: isUser
                    ? Colors.white
                    : Neutral.neutral900,

                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 260,
      height: 260,

      child: Image.asset(
        'assets/images/assistant.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _suggestionChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,

      children:
          _suggestions.map((s) => _chip(s)).toList(),
    );
  }

  Widget _chip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: AccentRed.accentRed100,
          borderRadius: BorderRadius.circular(24),

          border: Border.all(
            color: VitalRed.vitalRed500.withOpacity(0.2),
          ),
        ),

        child: Text(
          text,

          style:
              AppTypography.bodyMedium.copyWith(
            color: VitalRed.vitalRed500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24,
      ),

      decoration: BoxDecoration(
        color: Neutral.neutral100,

        boxShadow: [
          BoxShadow(
            color:
                Neutral.neutral900.withOpacity(0.04),

            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,

              style:
                  AppTypography.bodyMedium.copyWith(
                color: Neutral.neutral800,
              ),

              decoration: InputDecoration(
                hintText:
                    'Message... / أرسل رسالة',

                hintStyle:
                    AppTypography.bodyMedium.copyWith(
                  color: Neutral.neutral500,
                ),

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,

                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),

              onSubmitted: (_) => _sendMessage(),
            ),
          ),

          GestureDetector(
            onTap: () => _sendMessage(),

            child: Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: VitalRed.vitalRed500,
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}