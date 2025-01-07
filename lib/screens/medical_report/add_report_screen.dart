import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medical_report_provider.dart';
import '../../providers/auth_provider.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final Map<String, dynamic> _reportData = {
    'title': '',
    'date': '',
    'doctor': '',
    'hospital': '',
    'symptoms': '',
    'diagnosis': '',
    'medications': '',
    'tests': '',
    'notes': '',
  };

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final userId = Provider.of<AuthProvider>(context, listen: false).userId;
        final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
        
        _reportData['userId'] = userId;
        _reportData['userEmail'] = userEmail;
        
        await Provider.of<MedicalReportProvider>(context, listen: false)
            .analyzeReport(_reportData);
            
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting report: ${e.toString()}')),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(String label, String field, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onSaved: (value) {
          _reportData[field] = value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Report'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField('Report Title', 'title'),
                    _buildTextField('Date', 'date'),
                    _buildTextField('Doctor\'s Name', 'doctor'),
                    _buildTextField('Hospital/Clinic', 'hospital'),
                    _buildTextField('Symptoms', 'symptoms', maxLines: 3),
                    _buildTextField('Diagnosis', 'diagnosis', maxLines: 3),
                    _buildTextField('Medications', 'medications', maxLines: 3),
                    _buildTextField('Tests Performed', 'tests', maxLines: 3),
                    _buildTextField('Additional Notes', 'notes', maxLines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_isLoading ? 'Submitting...' : 'Submit Report'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 