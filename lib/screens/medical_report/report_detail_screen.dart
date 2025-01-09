import 'package:flutter/material.dart';
import '../../models/medical_report.dart';
import '../../widgets/analysis_components.dart';

class ReportDetailScreen extends StatelessWidget {
  final MedicalReport report;

  const ReportDetailScreen({super.key, required this.report});

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

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: report.isSynced
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        report.isSynced ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: report.isSynced
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.isSynced ? 'Synced' : 'Not Synced',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: report.isSynced
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created on ${report.dateTime.toString().split('.')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Report'),
                  content: const Text(
                      'Are you sure you want to delete this report?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implement delete functionality
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (report.analysis['summary'] != null)
              _buildSectionCard(
                'Summary',
                Text(
                  report.analysis['summary'],
                  style: const TextStyle(fontSize: 16),
                ),
                color: Colors.blue,
                icon: Icons.summarize,
              ),
            if (report.analysis['key_findings'] != null)
              _buildSectionCard(
                'Key Findings',
                AnalysisComponents.buildKeyFindings(
                    report.analysis['key_findings']),
                color: Colors.blue,
                icon: Icons.analytics,
              ),
            if (report.analysis['abnormal_results'] != null)
              _buildSectionCard(
                'Abnormal Results',
                AnalysisComponents.buildAbnormalResults(
                    report.analysis['abnormal_results']),
                color: Colors.orange,
                icon: Icons.warning_amber,
              ),
            if (report.analysis['recommendations'] != null)
              _buildSectionCard(
                'Recommendations',
                AnalysisComponents.buildRecommendations(
                    report.analysis['recommendations']),
                color: Colors.green,
                icon: Icons.recommend,
              ),
            if (report.analysis['questions_to_ask'] != null)
              _buildSectionCard(
                'Questions to Ask Your Doctor',
                AnalysisComponents.buildQuestionsToAsk(
                    report.analysis['questions_to_ask']),
                color: Colors.purple,
                icon: Icons.help_outline,
              ),
          ],
        ),
      ),
    );
  }
}
