import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _endpoint = 'init.openai.azure.com';
  static const String _apiVersion = '2024-10-01-preview';
  static const String _deploymentName = 'gpt-4o-mini';
  static const String _apiKey =
      'DjsQif8bMwHVqoJ2FEHMR1W7v7O7qYoBnRrDJc0ZH386eoWCeRXyJQQJ99AJACYeBjFXJ3w3AAABACOGOH8O';

  Future<Map<String, dynamic>> analyzeMedicalReport(
      String base64File, bool isPdf) async {
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
              '''You are a medical professional assistant that helps analyze medical reports and test results. 
Analyze the provided medical report and return a JSON response with the following structure:
{
  "summary": "A brief overview of the report",
  "key_findings": [
    {
      "category": "category name",
      "value": "actual value",
      "normal_range": "reference range",
      "interpretation": "what this means in simple terms"
    }
  ],
  "abnormal_results": [
    {
      "name": "test name",
      "value": "abnormal value",
      "severity": "low/medium/high",
      "concern": "what this might indicate"
    }
  ],
  "recommendations": [
    {
      "type": "follow_up/lifestyle/medication/etc",
      "description": "detailed recommendation"
    }
  ],
  "questions_to_ask": [
    {
      "topic": "topic area",
      "question": "suggested question"
    }
  ]
}

Ensure all responses strictly follow this JSON format. Provide clear, patient-friendly explanations while maintaining medical accuracy.'''
        }
      ]
    };

    final userMessage = {
      'role': 'user',
      'content': [
        {
          'type': 'text',
          'text': isPdf
              ? 'Please analyze this PDF medical report and provide a structured analysis:'
              : 'Please analyze this medical report image and provide a structured analysis:'
        },
        {
          'type': isPdf ? 'file_url' : 'image_url',
          isPdf ? 'file_url' : 'image_url': {
            'url': isPdf
                ? 'data:application/pdf;base64,$base64File'
                : 'data:image/png;base64,$base64File'
          }
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
          'max_tokens': 1000,
          'stream': false,
          'response_format': {'type': 'json_object'}
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        final content = jsonResponse['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to analyze report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing report: $e');
    }
  }
}
