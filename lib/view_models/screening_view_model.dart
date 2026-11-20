import 'package:get/get.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/models/user_model.dart';
import 'package:retina_scan_app/res/services/local_storage_service.dart';
import 'package:retina_scan_app/res/services/retina_api_service.dart';
import 'package:retina_scan_app/res/services/retina_sync_service.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';

class ScreeningViewModel extends GetxController {
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  final RetinaApiService _api = Get.find<RetinaApiService>();
  final RetinaSyncService _syncService = Get.find<RetinaSyncService>();
  final AuthViewModel _auth = Get.find<AuthViewModel>();

  final RxList<ScreeningModel> allScreenings = <ScreeningModel>[].obs;
  final RxString selectedPatientFilter = 'All'.obs;
  final RxString selectedDoctorFilter = 'Pending'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<ScreeningModel> activeScreening = Rxn<ScreeningModel>();

  @override
  void onInit() {
    super.onInit();
    loadScreenings();
  }

  void loadScreenings() {
    final List<ScreeningModel> items = _storage.getScreenings();
    items.sort((ScreeningModel a, ScreeningModel b) => b.createdAt.compareTo(a.createdAt));
    allScreenings.assignAll(items);
    _syncService.refreshPendingCount();

    final ScreeningModel? current = activeScreening.value;
    if (current != null) {
      for (final ScreeningModel updated in items) {
        if (updated.id == current.id) {
          activeScreening.value = updated;
          break;
        }
      }
    }
  }

  List<ScreeningModel> get patientScreenings {
    final String? uid = _auth.currentUser.value?.id;
    if (uid == null) return <ScreeningModel>[];
    return allScreenings
        .where((ScreeningModel s) => s.patientId == uid)
        .toList();
  }

  List<ScreeningModel> get filteredPatientScreenings {
    final List<ScreeningModel> base = patientScreenings;
    final String filter = selectedPatientFilter.value;
    if (filter == 'Pending') {
      return base.where((ScreeningModel s) => s.status == ScreeningStatus.pending).toList();
    }
    if (filter == 'Reviewed') {
      return base.where((ScreeningModel s) => s.status == ScreeningStatus.reviewed).toList();
    }
    if (filter == 'Rejected') {
      return base.where((ScreeningModel s) => s.status == ScreeningStatus.rejected).toList();
    }
    return base;
  }

  int get patientTotalCount => patientScreenings.length;

  int get patientPendingCount => patientScreenings
      .where((ScreeningModel s) => s.status == ScreeningStatus.pending)
      .length;

  int get patientReviewedCount => patientScreenings
      .where((ScreeningModel s) => s.status == ScreeningStatus.reviewed)
      .length;

  int get doctorPendingCount => allScreenings
      .where((ScreeningModel s) => s.status == ScreeningStatus.pending)
      .length;

  int get doctorReviewedCount => allScreenings
      .where((ScreeningModel s) => s.status != ScreeningStatus.pending)
      .length;

  int get doctorHighRiskCount => allScreenings
      .where((ScreeningModel s) =>
          s.status == ScreeningStatus.pending && s.severity.isHighRisk)
      .length;

  List<ScreeningModel> get doctorFilteredScreenings {
    final String filter = selectedDoctorFilter.value;
    final String query = searchQuery.value.trim().toLowerCase();

    return allScreenings.where((ScreeningModel s) {
      final bool matchesTab = filter == 'All'
          ? true
          : filter == 'Pending'
              ? s.status == ScreeningStatus.pending
              : s.status != ScreeningStatus.pending;
      if (!matchesTab) return false;

      if (query.isEmpty) return true;
      return s.patientName.toLowerCase().contains(query) ||
          s.id.toLowerCase().contains(query) ||
          s.severity.label.toLowerCase().contains(query);
    }).toList();
  }

  void openScreening(ScreeningModel screening) {
    activeScreening.value = screening;
  }

  Future<ScreeningModel?> submitNewScan({
    required String eyeSide,
    required String imagePath,
    required String symptomNotes,
  }) async {
    final UserModel? patient = _auth.currentUser.value;
    if (patient == null) return null;

    isSubmitting.value = true;
    try {
      final ScreeningModel analyzed = await _api.analyzeFundusScan(
        patientId: patient.id,
        patientName: patient.fullName,
        eyeSide: eyeSide,
        imagePath: imagePath,
        symptomNotes: symptomNotes,
      );
      await _storage.saveScreening(analyzed);
      loadScreenings();
      activeScreening.value = analyzed;
      return analyzed;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> submitDoctorReview({
    required String screeningId,
    required bool isApproved,
    required String clinicalRemarks,
  }) async {
    final UserModel? doctor = _auth.currentUser.value;
    if (doctor == null) return false;

    isSubmitting.value = true;
    try {
      final int idx =
          allScreenings.indexWhere((ScreeningModel s) => s.id == screeningId);
      if (idx < 0) return false;

      final ScreeningModel updated = allScreenings[idx].copyWith(
        status: isApproved ? ScreeningStatus.reviewed : ScreeningStatus.rejected,
        doctorId: doctor.id,
        doctorName: doctor.fullName,
        doctorLicenseId: doctor.medicalLicenseId ?? 'MD-VERIFIED',
        doctorRemarks: clinicalRemarks.trim(),
        reviewedAt: DateTime.now().toIso8601String(),
        isSynced: false,
      );

      await _storage.saveScreening(updated);
      loadScreenings();
      await _syncService.syncNow();
      loadScreenings();
      return true;
    } finally {
      isSubmitting.value = false;
    }
  }
}