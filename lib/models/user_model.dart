enum UserRole {
  patient,
  doctor;

  String get label {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
    }
  }

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (UserRole r) => r.name == value,
      orElse: () => UserRole.patient,
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? medicalLicenseId;
  final String? specialty;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.medicalLicenseId,
    this.specialty,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? password,
    UserRole? role,
    String? medicalLicenseId,
    String? specialty,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      medicalLicenseId: medicalLicenseId ?? this.medicalLicenseId,
      specialty: specialty ?? this.specialty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role.name,
      'medicalLicenseId': medicalLicenseId,
      'specialty': specialty,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: UserRole.fromValue(json['role'] as String? ?? 'patient'),
      medicalLicenseId: json['medicalLicenseId'] as String?,
      specialty: json['specialty'] as String?,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}