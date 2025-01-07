import 'package:flutter/foundation.dart';
import '../services/openai_service.dart';
import '../services/file_service.dart';

class MedicalReportProvider with ChangeNotifier {
  final _openAIService = OpenAIService();
  final _fileService = FileService();

  bool _isLoading = false;
  String? _analysis;
  String? _error;

  bool get isLoading => _isLoading;
  String? get analysis => _analysis;
  String? get error => _error;

  Future<void> analyzeImageReport() async {
    _setLoading(true);
    _clearState();

    try {
      final base64Image = await _fileService.pickAndConvertImage();
      if (base64Image == null) {
        _setError('No image selected');
        return;
      }

      final analysis = await _openAIService.analyzeMedicalReport(base64Image);
      _setAnalysis(analysis);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> analyzePdfReport() async {
    _setLoading(true);
    _clearState();

    try {
      final base64Pdf = await _fileService.pickAndConvertPdf();
      if (base64Pdf == null) {
        _setError('No PDF selected');
        return;
      }

      final analysis = await _openAIService.analyzeMedicalReport(base64Pdf);
      _setAnalysis(analysis);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setAnalysis(String value) {
    _analysis = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    _analysis = null;
    notifyListeners();
  }

  void _clearState() {
    _analysis = null;
    _error = null;
    notifyListeners();
  }
}
