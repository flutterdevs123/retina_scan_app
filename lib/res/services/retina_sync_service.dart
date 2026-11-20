import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/services/local_storage_service.dart';
import 'package:retina_scan_app/res/services/retina_api_service.dart';

class RetinaSyncService extends GetxService {
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  final RetinaApiService _api = Get.find<RetinaApiService>();

  final RxBool isSyncing = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxString lastSyncedLabel = 'Synced Locally'.obs;
  final RxBool isLiveApiEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialStatus();
  }

  void _loadInitialStatus() {
    refreshPendingCount();
    final String? savedTime = _storage.getLastSyncTime();
    if (savedTime != null) {
      final DateTime? parsed = DateTime.tryParse(savedTime);
      if (parsed != null) {
        lastSyncedLabel.value = DateFormat('MMM d, HH:mm').format(parsed);
      }
    }
  }

  void refreshPendingCount() {
    final List<ScreeningModel> all = _storage.getScreenings();
    pendingCount.value = all.where((ScreeningModel s) => !s.isSynced).length;
  }

  void setLiveApiMode(bool enabled) {
    isLiveApiEnabled.value = enabled;
    _api.useLiveApi = enabled;
  }

  Future<bool> syncNow() async {
    if (isSyncing.value) return false;
    isSyncing.value = true;
    try {
      final List<ScreeningModel> all = _storage.getScreenings();
      final List<ScreeningModel> unsynced =
          all.where((ScreeningModel s) => !s.isSynced).toList();

      final bool success = await _api.syncScreeningsBatch(unsynced);
      if (success) {
        for (final ScreeningModel item in unsynced) {
          await _storage.saveScreening(item.copyWith(isSynced: true));
        }
        final DateTime now = DateTime.now();
        await _storage.setLastSyncTime(now.toIso8601String());
        lastSyncedLabel.value = DateFormat('MMM d, HH:mm').format(now);
        refreshPendingCount();
      }
      return success;
    } finally {
      isSyncing.value = false;
    }
  }
}