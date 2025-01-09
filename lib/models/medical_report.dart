import 'dart:convert';

class MedicalReport {
  final String id;
  final String name;
  final DateTime dateTime;
  final Map<String, dynamic> analysis;
  final String? fileUrl;
  final bool isSynced;

  MedicalReport({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.analysis,
    this.fileUrl,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'analysis': analysis,
      'fileUrl': fileUrl,
      'isSynced': isSynced,
    };
  }

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'],
      name: json['name'],
      dateTime: DateTime.parse(json['dateTime']),
      analysis: json['analysis'],
      fileUrl: json['fileUrl'],
      isSynced: json['isSynced'] ?? false,
    );
  }

  MedicalReport copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    Map<String, dynamic>? analysis,
    String? fileUrl,
    bool? isSynced,
  }) {
    return MedicalReport(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      analysis: analysis ?? this.analysis,
      fileUrl: fileUrl ?? this.fileUrl,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
