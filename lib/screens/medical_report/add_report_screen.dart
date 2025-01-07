import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medical_report_provider.dart';
import '../../widgets/analysis_components.dart';

class AddReportScreen extends StatelessWidget {
  const AddReportScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Add Medical Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<MedicalReportProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Upload Medical Report',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload your medical report as an image or PDF file to get an AI-powered analysis.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: provider.isLoading
                                    ? null
                                    : provider.analyzeImageReport,
                                icon: const Icon(Icons.image),
                                label: const Text('Upload Image'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: provider.isLoading
                                    ? null
                                    : provider.analyzePdfReport,
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Upload PDF'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Analyzing your report...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (provider.error != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Error',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(provider.error!),
                        ],
                      ),
                    ),
                  )
                else if (provider.analysis != null)
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildAnalysisResult(provider.analysis!),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
