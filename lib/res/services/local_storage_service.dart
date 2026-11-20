import 'dart:convert';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/models/user_model.dart';
import 'package:retina_scan_app/res/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService extends GetxService {
  static const String _usersKey = 'retina_users_v1';
  static const String _screeningsKey = 'retina_screenings_v1';
  static const String _currentUserIdKey = 'retina_current_user_id_v1';
  static const String _lastSyncKey = 'retina_last_sync_v1';

  late final SharedPreferences _prefs;

  Future<LocalStorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedInitialDataIfEmpty();
    return this;
  }

  Future<void> _seedInitialDataIfEmpty() async {
    final List<UserModel> existingUsers = getUsers();
    if (existingUsers.isEmpty) {
      final DateTime now = DateTime.now();
      final List<UserModel> seededUsers = <UserModel>[
        UserModel(
          id: 'usr_patient_01',
          fullName: 'Sarah Chen',
          email: AppStrings.demoPatientEmail,
          password: AppStrings.demoPatientPassword,
          role: UserRole.patient,
          createdAt: now.subtract(const Duration(days: 14)).toIso8601String(),
        ),
        UserModel(
          id: 'usr_doctor_01',
          fullName: 'Dr. Marcus Vance',
          email: AppStrings.demoDoctorEmail,
          password: AppStrings.demoDoctorPassword,
          role: UserRole.doctor,
          medicalLicenseId: 'MD-OPHTH-88412',
          specialty: 'Vitreoretinal Surgery & Medical Retina',
          createdAt: now.subtract(const Duration(days: 60)).toIso8601String(),
        ),
      ];
      await _saveAllUsers(seededUsers);
    }

    final List<ScreeningModel> existingScreenings = getScreenings();
    if (existingScreenings.isEmpty) {
      final DateTime now = DateTime.now();
      final List<ScreeningModel> seededScreenings = <ScreeningModel>[
        ScreeningModel(
          id: 'SCN-1003',
          patientId: 'usr_patient_01',
          patientName: 'Sarah Chen',
          eyeSide: 'Right Eye (OD)',
          imagePath: 'sample://fundus_1',
          symptomNotes: 'Intermittent central blur when reading fine print over the past 2 weeks.',
          createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
          status: ScreeningStatus.pending,
          severity: DrSeverity.severeNpdr,
          confidenceScore: 0.946,
          aiSummary:
              'High-probability intraretinal microvascular abnormalities and clustered dot-blot hemorrhages detected superior to the macula.',
          detectionPoints: const <DetectionPoint>[
            DetectionPoint(
              id: 'dp_1',
              label: 'Microaneurysm Cluster',
              xRatio: 0.62,
              yRatio: 0.36,
              confidence: 0.96,
            ),
            DetectionPoint(
              id: 'dp_2',
              label: 'Hard Exudate Deposit',
              xRatio: 0.54,
              yRatio: 0.58,
              confidence: 0.91,
            ),
          ],
          isSynced: true,
        ),
        ScreeningModel(
          id: 'SCN-1002',
          patientId: 'usr_patient_01',
          patientName: 'Sarah Chen',
          eyeSide: 'Left Eye (OS)',
          imagePath: 'sample://fundus_2',
          symptomNotes: 'Routine 6-month Type 2 diabetic retinal follow-up; mild glare sensitivity.',
          createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          status: ScreeningStatus.reviewed,
          severity: DrSeverity.moderateNpdr,
          confidenceScore: 0.928,
          aiSummary:
              'Moderate non-proliferative diabetic retinopathy features identified with localized perimacular exudates.',
          detectionPoints: const <DetectionPoint>[
            DetectionPoint(
              id: 'dp_3',
              label: 'Perimacular Microaneurysm',
              xRatio: 0.44,
              yRatio: 0.42,
              confidence: 0.93,
            ),
          ],
          doctorId: 'usr_doctor_01',
          doctorName: 'Dr. Marcus Vance',
          doctorLicenseId: 'MD-OPHTH-88412',
          doctorRemarks:
              'Confirmed Moderate NPDR without clinically significant macular edema. Recommend OCT macula imaging and 4-month follow-up.',
          reviewedAt: now.subtract(const Duration(days: 1, hours: 18)).toIso8601String(),
          isSynced: true,
        ),
        ScreeningModel(
          id: 'SCN-1001',
          patientId: 'usr_patient_01',
          patientName: 'Sarah Chen',
          eyeSide: 'Right Eye (OD)',
          imagePath: 'sample://fundus_3',
          symptomNotes: 'Baseline annual vision checkup. No visual disturbances reported.',
          createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
          status: ScreeningStatus.reviewed,
          severity: DrSeverity.noDr,
          confidenceScore: 0.974,
          aiSummary:
              'Clear optic disc margins, normal foveal reflex, and intact retinal vascular arcades without hemorrhagic lesions.',
          detectionPoints: const <DetectionPoint>[
            DetectionPoint(
              id: 'dp_4',
              label: 'Optic Nerve Head Baseline',
              xRatio: 0.30,
              yRatio: 0.50,
              confidence: 0.98,
            ),
          ],
          doctorId: 'usr_doctor_01',
          doctorName: 'Dr. Marcus Vance',
          doctorLicenseId: 'MD-OPHTH-88412',
          doctorRemarks:
              'Normal baseline retinal fundus appearance. Continue annual diabetic ophthalmic screening.',
          reviewedAt: now.subtract(const Duration(days: 9)).toIso8601String(),
          isSynced: true,
        ),
      ];
      await _saveAllScreenings(seededScreenings);
    }
  }

  List<UserModel> getUsers() {
    final String? raw = _prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <UserModel>[];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => UserModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllUsers(List<UserModel> users) async {
    final String encoded = jsonEncode(users.map((UserModel u) => u.toJson()).toList());
    await _prefs.setString(_usersKey, encoded);
  }

  Future<void> saveUser(UserModel user) async {
    final List<UserModel> users = getUsers();
    final int index = users.indexWhere((UserModel u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _saveAllUsers(users);
  }

  UserModel? findUserByEmail(String email) {
    final String normalized = email.trim().toLowerCase();
    for (final UserModel user in getUsers()) {
      if (user.email.trim().toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<bool> updateUserPassword(String email, String newPassword) async {
    final UserModel? existing = findUserByEmail(email);
    if (existing == null) return false;
    await saveUser(existing.copyWith(password: newPassword));
    return true;
  }

  List<ScreeningModel> getScreenings() {
    final String? raw = _prefs.getString(_screeningsKey);
    if (raw == null || raw.isEmpty) return <ScreeningModel>[];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => ScreeningModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllScreenings(List<ScreeningModel> screenings) async {
    final String encoded =
        jsonEncode(screenings.map((ScreeningModel s) => s.toJson()).toList());
    await _prefs.setString(_screeningsKey, encoded);
  }

  Future<void> saveScreening(ScreeningModel screening) async {
    final List<ScreeningModel> list = getScreenings();
    final int index = list.indexWhere((ScreeningModel s) => s.id == screening.id);
    if (index >= 0) {
      list[index] = screening;
    } else {
      list.insert(0, screening);
    }
    await _saveAllScreenings(list);
  }

  String? getCurrentUserId() => _prefs.getString(_currentUserIdKey);

  Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_currentUserIdKey);
    } else {
      await _prefs.setString(_currentUserIdKey, userId);
    }
  }

  String? getLastSyncTime() => _prefs.getString(_lastSyncKey);

  Future<void> setLastSyncTime(String isoTimestamp) async {
    await _prefs.setString(_lastSyncKey, isoTimestamp);
  }
}