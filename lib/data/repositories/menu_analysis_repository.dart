import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_analysis_model.dart';

/// System prompt sent with every menu-scan request.
/// The server may override this if it has its own prompt logic.
const _kMenuSystemPrompt = '''
You are a professional nutritionist and OCR expert analyzing a café or restaurant menu photo.

YOUR TASK:
1. Read ALL visible text from the image using OCR — names, descriptions, weights, prices.
2. Identify each individual dish or item listed in the menu.
3. For every dish, estimate its likely ingredients based on the dish name and any description.
4. Calculate approximate nutritional values (КБЖУ): calories (kcal), protein (g), fat (g), carbohydrates (g).
5. Use a confidence score (0.0–1.0) reflecting how certain you are about the nutritional data.

STRICT RULES:
- Do NOT invent dishes that are not visible in the image.
- If the image is blurry or a section is illegible, skip that dish — do not guess its name.
- If confidence < 0.6, set isApproximate = true.
- Never claim exact precision for КБЖУ; values are always estimates.
- Return ONLY valid JSON — no markdown, no extra text.

OUTPUT FORMAT (strict JSON):
{
  "dishes": [
    {
      "dishName": "Caesar Salad",
      "description": "Romaine lettuce, croutons, parmesan, caesar dressing",
      "weight": "250g",
      "price": 1200,
      "estimatedIngredients": ["romaine lettuce", "chicken breast", "croutons", "parmesan", "caesar dressing"],
      "calories": 380,
      "protein": 28.5,
      "fats": 22.0,
      "carbs": 18.5,
      "confidence": 0.85,
      "isApproximate": false
    }
  ],
  "rawMenuText": "full OCR text of the menu here"
}
''';

class MenuAnalysisRepository {
  static const String _baseUrl =
      'https://ai-proxy-server-git-main-yaroslavv-5681s-projects.vercel.app/analyze-menu-image';

  /// Sends a base64-encoded menu image to the AI proxy and parses the result.
  Future<MenuAnalysisResult> analyzeMenuImage({
    required String base64Image,
    required String mimeType,
  }) async {
    final url = Uri.parse(_baseUrl);

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'imageBase64': base64Image,
            'mimeType': mimeType,
            'mode': 'menu', // hint for server-side routing
            'systemPrompt': _kMenuSystemPrompt,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final decoded = _extractJson(response.body);
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      final result = MenuAnalysisResult.fromJson(json);
      if (result.isEmpty) {
        throw Exception(
          'No dishes were detected. Try a clearer photo of the menu.',
        );
      }
      return result;
    } else {
      String errorMsg = 'Menu analysis failed (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['error'] != null) errorMsg = errJson['error'].toString();
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  /// Strips markdown code fences if the server wraps JSON in ```json ... ```.
  String _extractJson(String raw) {
    final trimmed = raw.trim();
    // Remove ```json ... ``` or ``` ... ```
    final fencePattern = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = fencePattern.firstMatch(trimmed);
    if (match != null) return match.group(1)!.trim();
    return trimmed;
  }
}
