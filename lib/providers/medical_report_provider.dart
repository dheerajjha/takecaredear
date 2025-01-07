import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicalReportProvider with ChangeNotifier {
  final String _baseUrl = 'YOUR_OPENAI_API_ENDPOINT';
  final String _apiKey = 'YOUR_OPENAI_API_KEY'; // TODO: Move to secure storage
  List<Map<String, dynamic>> _reports = [];

  List<Map<String, dynamic>> get reports => _reports;

  Future<Map<String, dynamic>> analyzeReport(
      Map<String, dynamic> reportData) async {
    try {
      final prompt = '''
      Analyze the following medical report data and provide a detailed analysis:
      Patient Data: ${jsonEncode(reportData)}
      
      Please provide:
      1. Key findings and observations
      2. Potential health concerns
      3. Recommendations for follow-up
      4. Lifestyle suggestions
      5. Any critical alerts or warnings
      
      Format the response as a JSON object with the following structure:
      {
        "findings": [],
        "concerns": [],
        "followUp": [],
        "lifestyle": [],
        "alerts": []
      }
      ''';

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a medical report analysis assistant.'
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final analysisResponse = jsonDecode(response.body);
        final analysis =
            jsonDecode(analysisResponse['choices'][0]['message']['content']);

        // Save the report and analysis
        final report = {
          ...reportData,
          'analysis': analysis,
          'timestamp': DateTime.now().toIso8601String(),
        };

        _reports.add(report);
        await _saveReports();
        notifyListeners();
        return analysis;
      } else {
        throw Exception('Failed to analyze report');
      }
    } catch (e) {
      throw Exception('Error analyzing report: $e');
    }
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medical_reports', jsonEncode(_reports));
  }

  Future<void> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString('medical_reports');
    if (reportsJson != null) {
      _reports = List<Map<String, dynamic>>.from(
          jsonDecode(reportsJson).map((x) => Map<String, dynamic>.from(x)));
      notifyListeners();
    }
  }

  Future<void> deleteReport(int index) async {
    if (index >= 0 && index < _reports.length) {
      _reports.removeAt(index);
      await _saveReports();
      notifyListeners();
    }
  }
}
