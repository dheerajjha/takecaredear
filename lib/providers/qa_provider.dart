import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QAProvider with ChangeNotifier {
  List<Map<String, dynamic>> _questions = [];

  List<Map<String, dynamic>> get questions => _questions;

  Future<void> addQuestion(
      String userId, String userEmail, String question) async {
    final newQuestion = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'userEmail': userEmail,
      'question': question,
      'answers': <Map<String, dynamic>>[],
      'timestamp': DateTime.now().toIso8601String(),
    };

    _questions.add(newQuestion);
    await _saveQuestions();
    notifyListeners();
  }

  Future<void> addAnswer(
      String questionId, String userId, String userEmail, String answer) async {
    final questionIndex = _questions.indexWhere((q) => q['id'] == questionId);
    if (questionIndex != -1) {
      final newAnswer = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': userId,
        'userEmail': userEmail,
        'answer': answer,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _questions[questionIndex]['answers'].add(newAnswer);
      await _saveQuestions();
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    _questions.removeWhere((q) => q['id'] == questionId);
    await _saveQuestions();
    notifyListeners();
  }

  Future<void> deleteAnswer(String questionId, String answerId) async {
    final questionIndex = _questions.indexWhere((q) => q['id'] == questionId);
    if (questionIndex != -1) {
      final answers =
          _questions[questionIndex]['answers'] as List<Map<String, dynamic>>;
      answers.removeWhere((a) => a['id'] == answerId);
      await _saveQuestions();
      notifyListeners();
    }
  }

  Future<void> _saveQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qa_data', jsonEncode(_questions));
  }

  Future<void> loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsJson = prefs.getString('qa_data');
    if (questionsJson != null) {
      _questions = List<Map<String, dynamic>>.from(
          jsonDecode(questionsJson).map((x) => Map<String, dynamic>.from(x)));
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getUserQuestions(String userId) {
    return _questions.where((q) => q['userId'] == userId).toList();
  }

  List<Map<String, dynamic>> searchQuestions(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _questions
        .where((q) =>
            q['question'].toLowerCase().contains(lowercaseQuery) ||
            (q['answers'] as List<Map<String, dynamic>>)
                .any((a) => a['answer'].toLowerCase().contains(lowercaseQuery)))
        .toList();
  }
}
