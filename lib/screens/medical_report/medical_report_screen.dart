import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medical_report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/analysis_components.dart';
import 'add_report_screen.dart';

class MedicalReportScreen extends StatefulWidget {
  const MedicalReportScreen({super.key});

  @override
  State<MedicalReportScreen> createState() => _MedicalReportScreenState();
}

class _MedicalReportScreenState extends State<MedicalReportScreen> {
  Widget _buildSectionCard(String title, Widget content,
      {Color? color, IconData? icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color ?? Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color?.withOpacity(0.1) ?? Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color ?? Colors.grey.shade700),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 64,
            color: Colors.blue.shade200,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Medical Reports Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first medical report to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddReportScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Medical Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade700,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement retry logic here
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading medical reports...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(Map<String, dynamic> analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (analysis['summary'] != null)
          _buildSectionCard(
            'Summary',
            Text(
              analysis['summary'],
              style: const TextStyle(fontSize: 16),
            ),
            color: Colors.blue,
            icon: Icons.summarize,
          ),
        if (analysis['key_findings'] != null)
          _buildSectionCard(
            'Key Findings',
            AnalysisComponents.buildKeyFindings(analysis['key_findings']),
            color: Colors.blue,
            icon: Icons.analytics,
          ),
        if (analysis['abnormal_results'] != null)
          _buildSectionCard(
            'Abnormal Results',
            AnalysisComponents.buildAbnormalResults(
                analysis['abnormal_results']),
            color: Colors.orange,
            icon: Icons.warning_amber,
          ),
        if (analysis['recommendations'] != null)
          _buildSectionCard(
            'Recommendations',
            AnalysisComponents.buildRecommendations(
                analysis['recommendations']),
            color: Colors.green,
            icon: Icons.recommend,
          ),
        if (analysis['questions_to_ask'] != null)
          _buildSectionCard(
            'Questions to Ask Your Doctor',
            AnalysisComponents.buildQuestionsToAsk(
                analysis['questions_to_ask']),
            color: Colors.purple,
            icon: Icons.help_outline,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MedicalReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return _buildLoadingState();
          }

          if (reportProvider.error != null) {
            return _buildErrorState(reportProvider.error!);
          }

          if (reportProvider.analysis != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildAnalysisResult(reportProvider.analysis!),
            );
          }

          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Report'),
      ),
    );
  }
}
