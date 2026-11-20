import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/user_model.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/custom_text_field.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/constants/app_strings.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthViewModel _auth = Get.find<AuthViewModel>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(UserRole role) {
    _auth.selectedLoginRole.value = role;
    if (role == UserRole.patient) {
      _emailController.text = AppStrings.demoPatientEmail;
      _passwordController.text = AppStrings.demoPatientPassword;
    } else {
      _emailController.text = AppStrings.demoDoctorEmail;
      _passwordController.text = AppStrings.demoDoctorPassword;
    }
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _auth.login(
      email: _emailController.text,
      password: _passwordController.text,
      expectedRole: _auth.selectedLoginRole.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.visibility_rounded,
                              color: AppColors.accentMint,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Secure Ophthalmic Screening Portal',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Obx(
                        () => Row(
                          children: UserRole.values.map((UserRole role) {
                            final bool selected =
                                _auth.selectedLoginRole.value == role;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: role == UserRole.patient ? 6 : 0,
                                  left: role == UserRole.doctor ? 6 : 0,
                                ),
                                child: InkWell(
                                  onTap: () =>
                                      _auth.selectedLoginRole.value = role,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.deepNavy
                                          : AppColors.backgroundLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.deepNavy
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          role == UserRole.patient
                                              ? Icons.person_outline_rounded
                                              : Icons.medical_services_outlined,
                                          size: 18,
                                          color: selected
                                              ? AppColors.accentMint
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          role.label,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5,
                                            color: selected
                                                ? AppColors.surfaceWhite
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'name@clinical.org',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? v) {
                          if (v == null || v.trim().isEmpty || !v.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                        validator: (String? v) {
                          if (v == null || v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => CustomButton(
                          label: 'Sign In',
                          icon: Icons.login_rounded,
                          isLoading: _auth.isLoading.value,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Quick Demo Account Fill',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: CustomButton(
                              label: 'Demo Patient',
                              isOutlined: true,
                              icon: Icons.person_pin_outlined,
                              onPressed: () => _fillDemo(UserRole.patient),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              label: 'Demo Doctor',
                              isOutlined: true,
                              icon: Icons.local_hospital_outlined,
                              onPressed: () => _fillDemo(UserRole.doctor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          const Text(
                            'New to RetinaScan AI?',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.register),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}