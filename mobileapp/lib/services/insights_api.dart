import 'dart:convert';

import 'package:http/http.dart' as http;

class InsightsApi {
  static final Uri _insightsUri = Uri.parse(
    'https://kyfr.onrender.com/insights',
  );

  Future<String> fetchWeeklyInsight() async {
    final response = await http
        .get(_insightsUri)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Insights request failed with ${response.statusCode}');
    }

    final decodedBody = jsonDecode(response.body);
    if (decodedBody is! Map<String, dynamic>) {
      throw const FormatException('Insights response must be an object');
    }

    final message = decodedBody['message'];
    if (message is! String || message.trim().isEmpty) {
      throw const FormatException('Insights response is missing message');
    }

    return message.trim();
  }
}
