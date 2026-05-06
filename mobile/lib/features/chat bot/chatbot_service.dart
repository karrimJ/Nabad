import 'package:cloud_functions/cloud_functions.dart';

class ChatbotService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<String> sendMessage(String message) async {
    try {
      final callable = _functions.httpsCallable('nabadAssistant');

      final result = await callable.call({
        'message': message,
      });

      final data = result.data;

      if (data is Map && data['reply'] != null) {
        return data['reply'].toString();
      }

      return 'Sorry, I could not understand that.';
    } catch (e) {
  print('CHATBOT ERROR: $e');
  return 'Error: $e';
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
    } else if (msg.contains('temperature') || msg.contains('حرارة')) {
      return 'A normal body temperature is usually around 36.5°C to 37.5°C. If it is high, persistent, or you feel very unwell, please contact a doctor.';
    } else if (msg.contains('blood pressure') || msg.contains('ضغط')) {
      return 'Blood pressure depends on the reading. If it is very high, very low, or you feel chest pain, dizziness, or shortness of breath, please seek medical help.';
    } else {
      return 'The assistant is temporarily unavailable. Please try again shortly.';
    }
  }
}