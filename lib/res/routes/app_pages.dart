import 'package:get/get.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/view/auth/forgot_password_view.dart';
import 'package:retina_scan_app/view/auth/login_view.dart';
import 'package:retina_scan_app/view/auth/register_view.dart';
import 'package:retina_scan_app/view/doctor/doctor_dashboard_view.dart';
import 'package:retina_scan_app/view/doctor/doctor_review_view.dart';
import 'package:retina_scan_app/view/patient/new_scan_view.dart';
import 'package:retina_scan_app/view/patient/patient_dashboard_view.dart';
import 'package:retina_scan_app/view/shared/screening_detail_view.dart';
import 'package:retina_scan_app/view/splash/splash_view.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.patientDashboard,
      page: () => const PatientDashboardView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.newScan,
      page: () => const NewScanView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.screeningDetail,
      page: () => const ScreeningDetailView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.doctorDashboard,
      page: () => const DoctorDashboardView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.doctorReview,
      page: () => const DoctorReviewView(),
    ),
  ];
}