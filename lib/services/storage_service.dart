import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_report.dart';

class StorageService {
  static const String _reportsKey = 'medical_reports';

  Future<void> saveReport(MedicalReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();

    final existingIndex = reports.indexWhere((r) => r.id == report.id);
    if (existingIndex != -1) {
      reports[existingIndex] = report;
    } else {
      reports.add(report);
    }

    final jsonList = reports.map((r) => r.toJson()).toList();
    await prefs.setString(_reportsKey, jsonEncode(jsonList));
  }

  Future<List<MedicalReport>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_reportsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => MedicalReport.fromJson(json)).toList();
  }

  Future<void> deleteReport(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getReports();
    reports.removeWhere((r) => r.id == id);

    final jsonList = reports.map((r) => r.toJson()).toList();
    await prefs.setString(_reportsKey, jsonEncode(jsonList));
  }

  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final reports = await getReports();
    final index = reports.indexWhere((r) => r.id == id);
    if (index != -1) {
      reports[index] = reports[index].copyWith(isSynced: isSynced);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = reports.map((r) => r.toJson()).toList();
      await prefs.setString(_reportsKey, jsonEncode(jsonList));
    }
  }
}
