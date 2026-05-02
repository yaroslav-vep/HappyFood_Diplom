import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';

class ChatRepository {
  static const String _baseUrl =
      'https://ai-proxy-server-production-5ebf.up.railway.app/chat';

  Future<ChatMessage> sendMessage(String message, UserModel? profile) async {
    try {
      final url = Uri.parse(_baseUrl);

      // Build a context-aware system prompt with spam/off-topic protection
      final systemContext =
          'You are HappyFood AI — a friendly nutrition and cooking assistant. '
          'You help users with food, recipes, and healthy lifestyle choices. '
          'Allowed topics: '
          '- Greetings and introductions. '
          '- Food, recipes, and cooking techniques. '
          '- Nutrition, calories, and macronutrients. '
          '- Healthy eating, meal planning, and dietary goals. '
          '- The user\'s own profile data (weight, height, age, allergies, goals). '
          'Rule: If the user asks about ANYTHING completely unrelated to food, nutrition, or their health profile '
          '(e.g., cars, politics, general technology, etc.), you must reply '
          'EXACTLY with: "I can\'t answer that — it\'s outside my nutrition and cooking '
          'expertise. Feel free to ask me anything about food, recipes, or healthy eating!" '
          'Formatting rules: '
          'Use **bold** ONLY for: calorie/nutrient numbers, dish names, and critical warnings. '
          'Use bullet lists (- item) for steps or items. '
          'Be friendly, concise, and professional.';

      // Build user-context enriched prompt
      String userPrompt = message;
      if (profile != null) {
        userPrompt =
            'User profile: weight=${profile.weight}kg, height=${profile.height}cm, '
            'age=${profile.age}, gender=${profile.gender}, goal=${profile.goal}, '
            'activity=${profile.activityLevel}, allergies=${profile.allergies.join(', ')}. '
            'User question: $message';
      }

      final fullPrompt = '$systemContext\n\nUser: $userPrompt';

      final Map<String, dynamic> body = {'message': fullPrompt};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
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
