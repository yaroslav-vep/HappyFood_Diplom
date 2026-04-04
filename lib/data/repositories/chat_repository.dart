import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';

class ChatRepository {
  // Local Gemini proxy server (node server.js running on port 3000)
  static const String _baseUrl =
      'https://ai-proxy-server-production-bfd3.up.railway.app/chat';

  Future<ChatMessage> sendMessage(String message, UserModel? profile) async {
    try {
      final url = Uri.parse(_baseUrl);

      // Build a context-aware prompt using the user's profile if available
      String prompt = message;
      if (profile != null) {
        prompt =
            'User profile: weight=${profile.weight}kg, height=${profile.height}cm, '
            'age=${profile.age}, gender=${profile.gender}, goal=${profile.goal}, '
            'activity=${profile.activityLevel}, allergies=${profile.allergies.join(', ')}. '
            'User question: $message';
      }

      final Map<String, dynamic> body = {'message': prompt};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Local proxy returns { reply: "..." }
        return ChatMessage.ai(
          jsonResponse['reply'] ?? "I'm sorry, I couldn't generate a response.",
        );
      } else {
        String errorText = "Something went wrong. Please try again.";
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['error'] != null) {
            errorText = errorJson['error'].toString();
          }
        } catch (_) {}

        return ChatMessage.error(errorText);
      }
    } catch (e) {
      return ChatMessage.error("Network error: $e");
    }
  }
}
