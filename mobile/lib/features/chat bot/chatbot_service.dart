import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  static const String _apiKey = 'AIzaSyBAGVEIHbzN_YL4qZonztA3MCEYF4dZWkM';

  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash', // ✅ updated from deprecated 'gemini-pro'
    apiKey: _apiKey,
    systemInstruction: Content.system('''
You are Nabad, a helpful medical assistant app for Lebanese users.
Answer health-related questions in the same language the user writes in.
If the user writes in Arabic, respond in Arabic.
If the user writes in English, respond in English.
Keep answers simple, clear, and helpful.
If the question is not health-related, politely redirect to health topics.
Never diagnose — always recommend seeing a doctor for serious concerns.
'''),
  );

  late final ChatSession _chat = _model.startChat();

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'Sorry, I could not understand that.';
    } catch (e) {
      return _faqFallback(message);
    }
  }

  String _faqFallback(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('emergency') || msg.contains('طوارئ')) {
      return 'For emergencies, please call 140 (Lebanese Red Cross) immediately.';
    } else if (msg.contains('appointment') || msg.contains('موعد')) {
      return 'You can book an appointment through the Services section.';
    } else if (msg.contains('medication') || msg.contains('دواء')) {
      return 'Check your medications in the Medications section.';
    } else {
      return 'I am having trouble connecting. Please try again shortly.';
    }
  }
}