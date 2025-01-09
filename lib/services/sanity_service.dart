import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_report.dart';

class SanityService {
  static const String projectId = 'c7ipbm78';
  static const String dataset = 'production';
  static const String token =
      'skwY9iScGtkrWFue84CY5cFTRs1YlcVdrFzaTzfrsHSHW3RThK8RHO8LXraww9LNQ83ECDa15ynghuIHXOQ7M872tNApkMlfrFmokU4cYJVuaikx5Qj7vUaRULXtNuZZnVAXnjsbNUXv97BQs6sUTJy63jMyOvbrmpDg6eFtZgDDWsP4PPVc';
  static const String apiVersion = '2023-05-03';

  final String baseUrl =
      'https://$projectId.api.sanity.io/v$apiVersion/data/mutate/$dataset';

  Future<bool> syncReport(MedicalReport report) async {
    try {
      final mutations = [
        {
          'createOrReplace': {
            '_type': 'medicalReport',
            '_id': report.id,
            'name': report.name,
            'dateTime': report.dateTime.toIso8601String(),
            'analysis': report.analysis,
            'fileUrl': report.fileUrl,
          }
        }
      ];

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mutations': mutations}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error syncing report: $e');
      return false;
    }
  }

  Future<List<MedicalReport>> fetchReports() async {
    try {
      final query = '''
        *[_type == "medicalReport"] | order(dateTime desc) {
          _id,
          name,
          dateTime,
          analysis,
          fileUrl
        }
      ''';

      final response = await http.get(
        Uri.parse(
            'https://$projectId.api.sanity.io/v$apiVersion/data/query/$dataset?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reports = (data['result'] as List).map((json) {
          return MedicalReport(
            id: json['_id'],
            name: json['name'],
            dateTime: DateTime.parse(json['dateTime']),
            analysis: json['analysis'],
            fileUrl: json['fileUrl'],
            isSynced: true,
          );
        }).toList();
        return reports;
      }
      return [];
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }
}
