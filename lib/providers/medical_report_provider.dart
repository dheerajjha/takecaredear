import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medical_report.dart';
import '../services/openai_service.dart';
import '../services/file_service.dart';
import '../services/storage_service.dart';
import '../services/sanity_service.dart';

class MedicalReportProvider with ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  final FileService _fileService = FileService();
  final StorageService _storageService = StorageService();
  final SanityService _sanityService = SanityService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _analysis;
  List<MedicalReport> _reports = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get analysis => _analysis;
  List<MedicalReport> get reports => _reports;

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load local reports
      _reports = await _storageService.getReports();

      // Try to sync with Sanity
      final onlineReports = await _sanityService.fetchReports();
      for (var report in onlineReports) {
        if (!_reports.any((r) => r.id == report.id)) {
          _reports.add(report);
          await _storageService.saveReport(report);
        }
      }

      _reports.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _error = null;
    } catch (e) {
      _error = 'Failed to load reports: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeImageReport() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final base64Image = await _fileService.pickAndConvertImage();
      if (base64Image == null) {
        _error = 'No image selected';
        return;
      }

      _analysis = await _openAIService.analyzeMedicalReport(base64Image, false);

      if (_analysis != null) {
        final report = MedicalReport(
          id: const Uuid().v4(),
          name: 'Medical Report ${DateTime.now().toString()}',
          dateTime: DateTime.now(),
          analysis: _analysis!,
        );

        await _storageService.saveReport(report);
        await _syncReport(report);

        _reports.insert(0, report);
      }
    } catch (e) {
      _error = 'Failed to analyze image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzePdfReport() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final base64Pdf = await _fileService.pickAndConvertPdf();
      if (base64Pdf == null) {
        _error = 'No PDF selected';
        return;
      }

      _analysis = await _openAIService.analyzeMedicalReport(base64Pdf, true);

      if (_analysis != null) {
        final report = MedicalReport(
          id: const Uuid().v4(),
          name: 'Medical Report ${DateTime.now().toString()}',
          dateTime: DateTime.now(),
          analysis: _analysis!,
        );

        await _storageService.saveReport(report);
        await _syncReport(report);

        _reports.insert(0, report);
      }
    } catch (e) {
      _error = 'Failed to analyze PDF: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncReport(MedicalReport report) async {
    try {
      final success = await _sanityService.syncReport(report);
      if (success) {
        await _storageService.updateSyncStatus(report.id, true);
        final index = _reports.indexWhere((r) => r.id == report.id);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(isSynced: true);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error syncing report: $e');
    }
  }

  Future<void> syncAllReports() async {
    final unsyncedReports = _reports.where((r) => !r.isSynced).toList();
    for (var report in unsyncedReports) {
      await _syncReport(report);
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _storageService.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete report: $e';
      notifyListeners();
    }
  }
}
