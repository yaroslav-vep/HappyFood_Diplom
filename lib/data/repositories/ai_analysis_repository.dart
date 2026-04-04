import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_analysis_model.dart';

class AiAnalysisRepository {
  static const String _baseUrl =
      'https://ai-proxy-server-production-bfd3.up.railway.app/analyze-food-image';

  Future<FoodAnalysisModel> analyzeImage({
    required String base64Image,
    required String mimeType,
  }) async {
    final url = Uri.parse(_baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imageBase64': base64Image, 'mimeType': mimeType}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return FoodAnalysisModel.fromJson(json);
    } else {
      String errorMsg = 'Failed to analyze image (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['error'] != null) errorMsg = errJson['error'].toString();
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }
}
