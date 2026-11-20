import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/custom_text_field.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final AuthViewModel _auth = Get.find<AuthViewModel>();

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bool ok = await _auth.resetPassword(
      email: _emailController.text,
      newPassword: _newPasswordController.text,
    );
    if (ok && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Account Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Enter your registered email address and choose a new password.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Registered Email',
                        hint: 'name@domain.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? v) =>
                            (v == null || !v.contains('@'))
                                ? 'Enter a valid email address'
                                : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _newPasswordController,
                        label: 'New Password',
                        hint: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_reset_rounded,
                        obscureText: true,
                        validator: (String? v) => (v == null || v.length < 6)
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => CustomButton(
                          label: 'Update Password',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _auth.isLoading.value,
                          onPressed: _handleReset,
                        ),
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