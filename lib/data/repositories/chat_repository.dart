import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';

class ChatRepository {
  static const String _baseUrl =
      'https://ai-proxy-server-production-5ebf.up.railway.app/chat';

  Future<ChatMessage> sendMessage(
      List<ChatMessage> history, UserModel? profile) async {
    try {
      final url = Uri.parse(_baseUrl);

      // Get the latest user message
      final latestMessage =
          history.lastWhere((m) => m.isUser, orElse: () => history.last).text;
      
      // Detect if user is asking for a meal plan
      final isMealPlanRequest = _isMealPlanRequest(latestMessage);

      final systemContext =
          'You are HappyFood AI — a friendly nutrition and cooking assistant. '
          'You help users with food, recipes, and healthy lifestyle choices. '
          'Allowed topics: '
          '- Greetings and introductions. '
          '- Food, recipes, and cooking techniques. '
          '- Nutrition, calories, and macronutrients. '
          '- Healthy eating, meal planning, and dietary goals. '
          '- The user\'s own profile data (weight, height, age, allergies, goals). '
          'Rule 1: If the user asks about ANYTHING completely unrelated to food, nutrition, or their health profile '
          '(e.g., cars, politics, general technology, etc.), you must reply '
          'EXACTLY with: "I can\'t answer that — it\'s outside my nutrition and cooking '
          'expertise. Feel free to ask me anything about food, recipes, or healthy eating!" '
          'Rule 2: ALWAYS reply in the exact same language the user is speaking in. If the user writes in Russian, you MUST reply in Russian. '
          'Formatting rules: '
          'Use **bold** ONLY for: calorie/nutrient numbers, dish names, and critical warnings. '
          'Use bullet lists (- item) for steps or items. '
          'Be friendly, concise, and professional.'
          // Meal plan special instruction
          '${isMealPlanRequest ? ' When providing a meal plan, at the very end add a line: "[MEAL_PLAN_DISHES: Dish1, Dish2, Dish3]" listing the main dish names from the plan (max 5). Do not show this tag to the user in conversation, just add it at the very end.' : ''}';

      String profileContext = '';
      if (profile != null) {
        profileContext =
            'User profile: weight=${profile.weight}kg, height=${profile.height}cm, '
            'age=${profile.age}, gender=${profile.gender}, goal=${profile.goal}, '
            'activity=${profile.activityLevel}, allergies=${profile.allergies.join(', ')}.\n';
      }

      // Build conversation history
      final historyText = history.map((m) {
        final role = m.isUser ? 'User' : 'AI';
        return '$role: ${m.text}';
      }).join('\n\n');

      final fullPrompt = '$systemContext\n\n$profileContext\nConversation History:\n$historyText';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': fullPrompt}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final rawReply =
            jsonResponse['reply'] as String? ??
            "I'm sorry, I couldn't generate a response.";

        // Parse [MEAL_PLAN_DISHES: ...] tag from AI response
        final dishes = _extractDishes(rawReply);
        final cleanReply = _removeDishesTag(rawReply);

        return ChatMessage.ai(
          cleanReply,
          isMealPlan: dishes.isNotEmpty,
          suggestedDishes: dishes,
        );
      } else {
        String errorText = 'Something went wrong. Please try again.';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['error'] != null) {
            errorText = errorJson['error'].toString();
          }
        } catch (_) {}
        return ChatMessage.error(errorText);
      }
    } catch (e) {
      return ChatMessage.error('Network error: $e');
    }
  }

  /// Returns true if the message is asking for a meal plan.
  bool _isMealPlanRequest(String message) {
    final lower = message.toLowerCase();
    const keywords = [
      'meal plan',
      'план питания',
      'plan for today',
      'plan for the week',
      'weekly plan',
      'daily plan',
      'what should i eat',
      'что поесть',
      'план на неделю',
      'план на сегодня',
      'составь меню',
      'diet plan',
      'nutrition plan',
    ];
    return keywords.any((kw) => lower.contains(kw));
  }

  /// Extracts dish names from the [MEAL_PLAN_DISHES: ...] tag.
  List<String> _extractDishes(String text) {
    final regex = RegExp(r'\[MEAL_PLAN_DISHES:\s*([^\]]+)\]');
    final match = regex.firstMatch(text);
    if (match == null) return [];
    return match
        .group(1)!
        .split(',')
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();
  }

  /// Removes the hidden tag from the visible reply.
  String _removeDishesTag(String text) {
    return text.replaceAll(RegExp(r'\[MEAL_PLAN_DISHES:[^\]]*\]'), '').trim();
  }
}
