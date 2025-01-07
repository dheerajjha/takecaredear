import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/qa_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'question_detail_screen.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final _questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<QAProvider>(context, listen: false).loadQuestions());
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    // If we returned from login and are authenticated, post the question
    if (result == true && mounted) {
      await _addQuestion();
    }
  }

  Future<void> _handleQuestionSubmit() async {
    if (_questionController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      await _navigateToLogin();
      return;
    }

    await _addQuestion();
  }

  Future<void> _addQuestion() async {
    setState(() => _isLoading = true);
    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      final userEmail =
          Provider.of<AuthProvider>(context, listen: false).userEmail;

      if (userId == null || userEmail == null) {
        throw Exception('User not authenticated');
      }

      await Provider.of<QAProvider>(context, listen: false).addQuestion(
        userId,
        userEmail,
        _questionController.text.trim(),
      );

      if (mounted) {
        _questionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question posted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post question: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _handleQuestionSubmit,
                    child: const Text('Post'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<QAProvider>(
              builder: (context, qaProvider, child) {
                final questions = qaProvider.questions;
                if (questions.isEmpty) {
                  return const Center(
                    child: Text('No questions yet. Be the first to ask!'),
                  );
                }
                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(question['question']),
                        subtitle: Text(
                          'Asked by ${question['userEmail']} • ${question['answers'].length} answers',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionDetailScreen(
                                question: question,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
