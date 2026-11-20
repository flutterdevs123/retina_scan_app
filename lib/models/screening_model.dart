enum ScreeningStatus {
  pending,
  reviewed,
  rejected;

  String get label {
    switch (this) {
      case ScreeningStatus.pending:
        return 'Pending Review';
      case ScreeningStatus.reviewed:
        return 'Reviewed';
      case ScreeningStatus.rejected:
        return 'Rejected';
    }
  }

  static ScreeningStatus fromValue(String value) {
    return ScreeningStatus.values.firstWhere(
      (ScreeningStatus s) => s.name == value,
      orElse: () => ScreeningStatus.pending,
    );
  }
}

enum DrSeverity {
  noDr,
  mildNpdr,
  moderateNpdr,
  severeNpdr,
  proliferativeDr;

  String get label {
    switch (this) {
      case DrSeverity.noDr:
        return 'No DR Detected';
      case DrSeverity.mildNpdr:
        return 'Mild NPDR';
      case DrSeverity.moderateNpdr:
        return 'Moderate NPDR';
      case DrSeverity.severeNpdr:
        return 'Severe NPDR';
      case DrSeverity.proliferativeDr:
        return 'Proliferative DR';
    }
  }

  bool get isHighRisk {
    return this == DrSeverity.severeNpdr || this == DrSeverity.proliferativeDr;
  }

  static DrSeverity fromValue(String value) {
    return DrSeverity.values.firstWhere(
      (DrSeverity d) => d.name == value,
      orElse: () => DrSeverity.noDr,
    );
  }
}

class DetectionPoint {
  final String id;
  final String label;
  final double xRatio;
  final double yRatio;
  final double confidence;

  const DetectionPoint({
    required this.id,
    required this.label,
    required this.xRatio,
    required this.yRatio,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'xRatio': xRatio,
      'yRatio': yRatio,
      'confidence': confidence,
    };
  }

  factory DetectionPoint.fromJson(Map<String, dynamic> json) {
    return DetectionPoint(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Lesion Region',
      xRatio: (json['xRatio'] as num?)?.toDouble() ?? 0.5,
      yRatio: (json['yRatio'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
    );
  }
}

class ScreeningModel {
  final String id;
  final String patientId;
  final String patientName;
  final String eyeSide;
  final String imagePath;
  final String symptomNotes;
  final String createdAt;
  final ScreeningStatus status;
  final DrSeverity severity;
  final double confidenceScore;
  final String aiSummary;
  final List<DetectionPoint> detectionPoints;
  final String? doctorId;
  final String? doctorName;
  final String? doctorLicenseId;
  final String? doctorRemarks;
  final String? reviewedAt;
  final bool isSynced;

  const ScreeningModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.eyeSide,
    required this.imagePath,
    required this.symptomNotes,
    required this.createdAt,
    required this.status,
    required this.severity,
    required this.confidenceScore,
    required this.aiSummary,
    required this.detectionPoints,
    this.doctorId,
    this.doctorName,
    this.doctorLicenseId,
    this.doctorRemarks,
    this.reviewedAt,
    this.isSynced = true,
  });

  ScreeningModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? eyeSide,
    String? imagePath,
    String? symptomNotes,
    String? createdAt,
    ScreeningStatus? status,
    DrSeverity? severity,
    double? confidenceScore,
    String? aiSummary,
    List<DetectionPoint>? detectionPoints,
    String? doctorId,
    String? doctorName,
    String? doctorLicenseId,
    String? doctorRemarks,
    String? reviewedAt,
    bool? isSynced,
  }) {
    return ScreeningModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      eyeSide: eyeSide ?? this.eyeSide,
      imagePath: imagePath ?? this.imagePath,
      symptomNotes: symptomNotes ?? this.symptomNotes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      aiSummary: aiSummary ?? this.aiSummary,
      detectionPoints: detectionPoints ?? this.detectionPoints,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorLicenseId: doctorLicenseId ?? this.doctorLicenseId,
      doctorRemarks: doctorRemarks ?? this.doctorRemarks,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'eyeSide': eyeSide,
      'imagePath': imagePath,
      'symptomNotes': symptomNotes,
      'createdAt': createdAt,
      'status': status.name,
      'severity': severity.name,
      'confidenceScore': confidenceScore,
      'aiSummary': aiSummary,
      'detectionPoints': detectionPoints.map((DetectionPoint p) => p.toJson()).toList(),
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorLicenseId': doctorLicenseId,
      'doctorRemarks': doctorRemarks,
      'reviewedAt': reviewedAt,
      'isSynced': isSynced,
    };
  }

  factory ScreeningModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPoints = json['detectionPoints'] as List<dynamic>? ?? <dynamic>[];
    return ScreeningModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? 'Unknown Patient',
      eyeSide: json['eyeSide'] as String? ?? 'Right Eye (OD)',
      imagePath: json['imagePath'] as String? ?? 'sample://fundus_1',
      symptomNotes: json['symptomNotes'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      status: ScreeningStatus.fromValue(json['status'] as String? ?? 'pending'),
      severity: DrSeverity.fromValue(json['severity'] as String? ?? 'noDr'),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.90,
      aiSummary: json['aiSummary'] as String? ?? '',
      detectionPoints: rawPoints
          .map((dynamic e) => DetectionPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      doctorId: json['doctorId'] as String?,
      doctorName: json['doctorName'] as String?,
      doctorLicenseId: json['doctorLicenseId'] as String?,
      doctorRemarks: json['doctorRemarks'] as String?,
      reviewedAt: json['reviewedAt'] as String?,
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }
}