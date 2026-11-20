import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/res/constants/app_strings.dart';
import 'package:retina_scan_app/res/routes/app_pages.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/res/services/local_storage_service.dart';
import 'package:retina_scan_app/res/services/retina_api_service.dart';
import 'package:retina_scan_app/res/services/retina_sync_service.dart';
import 'package:retina_scan_app/res/theme/app_theme.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

Future<void> initAppDependencies() async {
  if (!Get.isRegistered<LocalStorageService>()) {
    final LocalStorageService storage = await LocalStorageService().init();
    Get.put<LocalStorageService>(storage, permanent: true);
  }
  if (!Get.isRegistered<RetinaApiService>()) {
    Get.put<RetinaApiService>(RetinaApiService(), permanent: true);
  }
  if (!Get.isRegistered<RetinaSyncService>()) {
    Get.put<RetinaSyncService>(RetinaSyncService(), permanent: true);
  }
  if (!Get.isRegistered<AuthViewModel>()) {
    Get.put<AuthViewModel>(AuthViewModel(), permanent: true);
  }
  if (!Get.isRegistered<ScreeningViewModel>()) {
    Get.put<ScreeningViewModel>(ScreeningViewModel(), permanent: true);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppDependencies();
  runApp(const RetinaScanApp());
}

class RetinaScanApp extends StatelessWidget {
  final String initialRoute;

  const RetinaScanApp({
    super.key,
    this.initialRoute = AppRoutes.splash,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}