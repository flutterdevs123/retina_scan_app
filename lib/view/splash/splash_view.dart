import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/constants/app_strings.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final AuthViewModel auth = Get.find<AuthViewModel>();
    final String route = auth.resolveInitialRoute();
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentMint, width: 2),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color: AppColors.accentMint,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surfaceWhite,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentMint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}