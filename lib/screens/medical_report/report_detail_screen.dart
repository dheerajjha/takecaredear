import 'package:flutter/material.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  Widget _buildSection(String title, dynamic content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, List<dynamic>? items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (items != null && items.isNotEmpty)
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              const Text('No data available'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysis = report['analysis'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection('Report Title', report['title']),
            _buildSection('Date', report['date']),
            _buildSection('Doctor', report['doctor']),
            _buildSection('Hospital/Clinic', report['hospital']),
            _buildSection('Symptoms', report['symptoms']),
            _buildSection('Diagnosis', report['diagnosis']),
            _buildSection('Medications', report['medications']),
            _buildSection('Tests Performed', report['tests']),
            _buildSection('Additional Notes', report['notes']),
            if (analysis != null) ...[
              const Divider(height: 32),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalysisSection('Key Findings', analysis['findings'] as List?),
              _buildAnalysisSection('Health Concerns', analysis['concerns'] as List?),
              _buildAnalysisSection('Follow-up Recommendations', analysis['followUp'] as List?),
              _buildAnalysisSection('Lifestyle Suggestions', analysis['lifestyle'] as List?),
              _buildAnalysisSection('Critical Alerts', analysis['alerts'] as List?),
            ],
          ],
        ),
      ),
    );
  }
} 