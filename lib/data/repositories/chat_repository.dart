import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/user_model.dart';

class ChatRepository {
  // TODO: Replace with your actual Firebase Function URL after deployment
  static const String _baseUrl = 'YOUR_FUNCTION_URL_HERE';

  Future<ChatMessage> sendMessage(String message, UserModel? profile) async {
    try {
      final url = Uri.parse(_baseUrl);

      final Map<String, dynamic> body = {
        'data': {
          // 'data' wrapper required for Firebase Callables
          'message': message,
          'profile': profile?.toJson(),
        },
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Firebase Callables return data in a 'result' key
        final result = jsonResponse['result'];

        if (result != null) {
          return ChatMessage.ai(
            result['reply'] ?? "I'm sorry, I couldn't generate a response.",
            isCalorieRelated: result['calorieMentioned'] ?? false,
          );
        } else {
          // Direct response (if using onRequest without callable wrapper logic) in some cases,
          // but our backend uses onCall/onRequest which might differ.
          // Our backend is 'onRequest' but we output { reply: ... }.
          // Wait, if we use 'onRequest' in backend, we return generic JSON, NOT wrapped in 'result' unless we did that manually.
          // In index.js we did: res.status(200).json({ reply: ..., ... })
          // So it is NOT wrapped in 'result' like a Callable.
          // It is a standard REST response.

          // Correction: The backend is onRequest, not onCall.
          // So the response body is directly the object.

          return ChatMessage.ai(
            jsonResponse['reply'] ??
                "I'm sorry, I couldn't generate a response.",
            isCalorieRelated: jsonResponse['caloriesMentioned'] ?? false,
          );
        }
      } else {
        // Handle error
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
