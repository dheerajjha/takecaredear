import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _endpoint = 'init.openai.azure.com';
  static const String _apiVersion = '2024-10-01-preview';
  static const String _deploymentName = 'gpt-4o-mini';
  static const String _apiKey =
      'DjsQif8bMwHVqoJ2FEHMR1W7v7O7qYoBnRrDJc0ZH386eoWCeRXyJQQJ99AJACYeBjFXJ3w3AAABACOGOH8O';

  Future<String> analyzeMedicalReport(String base64Image) async {
    final uri = Uri.https(
      _endpoint,
      '/openai/deployments/$_deploymentName/chat/completions',
      {'api-version': _apiVersion},
    );

    final systemMessage = {
      'role': 'system',
      'content': [
        {
          'type': 'text',
          'text':
              'You are a medical professional assistant that helps analyze medical reports and test results. Provide clear explanations in simple terms that patients can understand. Focus on key findings, any abnormal values, and what they might indicate. Also suggest relevant follow-up questions patients might want to ask their healthcare provider.'
        }
      ]
    };

    final userMessage = {
      'role': 'user',
      'content': [
        {
          'type': 'text',
          'text':
              'Please analyze this medical report and explain the findings in simple terms:'
        },
        {
          'type': 'image_url',
          'image_url': {'url': 'data:image/png;base64,$base64Image'}
        }
      ]
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'api-key': _apiKey,
        },
        body: jsonEncode({
          'messages': [systemMessage, userMessage],
          'temperature': 0.7,
          'top_p': 0.95,
          'frequency_penalty': 0,
          'presence_penalty': 0,
          'max_tokens': 800,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        print(response);
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to analyze report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing report: $e');
    }
  }
}
