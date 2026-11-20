import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/user_model.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/custom_text_field.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final AuthViewModel _auth = Get.find<AuthViewModel>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _auth.register(
      fullName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _auth.selectedRegisterRole.value,
      medicalLicenseId: _licenseController.text,
      specialty: _specialtyController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Clinical Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Form(
                  key: _formKey,
                  child: Obx(
                    () {
                      final UserRole role = _auth.selectedRegisterRole.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            'Select Account Role',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: UserRole.values.map((UserRole item) {
                              final bool selected = role == item;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: item == UserRole.patient ? 6 : 0,
                                    left: item == UserRole.doctor ? 6 : 0,
                                  ),
                                  child: ChoiceChip(
                                    label: SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        item.label,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    selected: selected,
                                    selectedColor: AppColors.primaryTeal.withAlpha(45),
                                    onSelected: (_) =>
                                        _auth.selectedRegisterRole.value = item,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: role == UserRole.doctor
                                ? 'Dr. Elena Rostova'
                                : 'Alex Morgan',
                            prefixIcon: Icons.badge_outlined,
                            validator: (String? v) => (v == null || v.trim().length < 2)
                                ? 'Enter your full name'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
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
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Minimum 6 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (String? v) => (v == null || v.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          if (role == UserRole.doctor) ...<Widget>[
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _licenseController,
                              label: 'Medical License ID',
                              hint: 'e.g. MD-OPHTH-90421',
                              prefixIcon: Icons.verified_user_outlined,
                              validator: (String? v) =>
                                  (v == null || v.trim().length < 4)
                                      ? 'Medical License ID is required for doctors'
                                      : null,
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _specialtyController,
                              label: 'Ophthalmic Specialty',
                              hint: 'e.g. Medical Retina & Diabetic Eye Care',
                              prefixIcon: Icons.local_hospital_outlined,
                            ),
                          ],
                          const SizedBox(height: 20),
                          CustomButton(
                            label: 'Register & Continue',
                            icon: Icons.person_add_alt_1_rounded,
                            isLoading: _auth.isLoading.value,
                            onPressed: _submit,
                          ),
                        ],
                      );
                    },
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