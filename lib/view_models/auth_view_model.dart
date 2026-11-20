import 'package:get/get.dart';
import 'package:retina_scan_app/models/user_model.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/res/services/local_storage_service.dart';

class AuthViewModel extends GetxController {
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final Rx<UserRole> selectedLoginRole = UserRole.patient.obs;
  final Rx<UserRole> selectedRegisterRole = UserRole.patient.obs;

  String resolveInitialRoute() {
    final String? savedId = _storage.getCurrentUserId();
    if (savedId == null || savedId.isEmpty) {
      return AppRoutes.login;
    }
    for (final UserModel user in _storage.getUsers()) {
      if (user.id == savedId) {
        currentUser.value = user;
        return user.role == UserRole.doctor
            ? AppRoutes.doctorDashboard
            : AppRoutes.patientDashboard;
      }
    }
    return AppRoutes.login;
  }

  Future<bool> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    isLoading.value = true;
    try {
      final UserModel? user = _storage.findUserByEmail(email);
      if (user == null || user.password != password) {
        Get.snackbar(
          'Authentication Failed',
          'Invalid email address or password.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      if (user.role != expectedRole) {
        Get.snackbar(
          'Role Mismatch',
          'This account is registered under the ${user.role.label} portal.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      currentUser.value = user;
      await _storage.setCurrentUserId(user.id);
      Get.offAllNamed(
        user.role == UserRole.doctor
            ? AppRoutes.doctorDashboard
            : AppRoutes.patientDashboard,
      );
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? medicalLicenseId,
    String? specialty,
  }) async {
    isLoading.value = true;
    try {
      if (_storage.findUserByEmail(email) != null) {
        Get.snackbar(
          'Account Exists',
          'An account with this email is already registered.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final UserModel newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: role,
        medicalLicenseId: role == UserRole.doctor ? medicalLicenseId?.trim() : null,
        specialty: role == UserRole.doctor ? specialty?.trim() : null,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _storage.saveUser(newUser);
      currentUser.value = newUser;
      await _storage.setCurrentUserId(newUser.id);

      Get.offAllNamed(
        role == UserRole.doctor
            ? AppRoutes.doctorDashboard
            : AppRoutes.patientDashboard,
      );
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    isLoading.value = true;
    try {
      final bool updated = await _storage.updateUserPassword(email, newPassword);
      if (!updated) {
        Get.snackbar(
          'Account Not Found',
          'No registered user matches that email address.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      Get.snackbar(
        'Password Updated',
        'You can now sign in with your new credentials.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    await _storage.setCurrentUserId(null);
    Get.offAllNamed(AppRoutes.login);
  }
}