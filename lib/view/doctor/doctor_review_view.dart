import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/custom_text_field.dart';
import 'package:retina_scan_app/res/components/fundus_visualizer.dart';
import 'package:retina_scan_app/res/components/status_badge.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/services/responsive_service.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

class DoctorReviewView extends StatefulWidget {
  const DoctorReviewView({super.key});

  @override
  State<DoctorReviewView> createState() => _DoctorReviewViewState();
}

class _DoctorReviewViewState extends State<DoctorReviewView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _remarksController = TextEditingController();
  final ScreeningViewModel _screeningVm = Get.find<ScreeningViewModel>();

  bool _showGradCam = true;
  bool _isApproved = true;

  @override
  void initState() {
    super.initState();
    final ScreeningModel? scan = _screeningVm.activeScreening.value;
    if (scan != null && scan.doctorRemarks != null) {
      _remarksController.text = scan.doctorRemarks!;
      _isApproved = scan.status != ScreeningStatus.rejected;
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitDecision(ScreeningModel scan) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bool ok = await _screeningVm.submitDoctorReview(
      screeningId: scan.id,
      isApproved: _isApproved,
      clinicalRemarks: _remarksController.text,
    );
    if (ok && mounted) {
      Get.back();
      Get.snackbar(
        'Clinical Review Recorded',
        'Patient record ${scan.id} updated live.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = ResponsiveService.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Clinical Verification & Sign-Off')),
      body: SafeArea(
        child: Obx(() {
          final ScreeningModel? scan = _screeningVm.activeScreening.value;
          if (scan == null) {
            return const Center(child: Text('No patient record selected.'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ChoiceChip(
                              label: const SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Original Fundus',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              selected: !_showGradCam,
                              onSelected: (_) =>
                                  setState(() => _showGradCam = false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Grad-CAM Overlay',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              selected: _showGradCam,
                              selectedColor: AppColors.primaryTeal.withAlpha(55),
                              onSelected: (_) =>
                                  setState(() => _showGradCam = true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FundusVisualizer(
                        imagePath: scan.imagePath,
                        detectionPoints: scan.detectionPoints,
                        showGradCam: _showGradCam,
                        height: 245,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    '${scan.patientName} â€¢ ${scan.id}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: scan.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${scan.eyeSide} â€¢ AI Confidence ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SeverityBadge(severity: scan.severity),
                            const SizedBox(height: 10),
                            Text(
                              scan.aiSummary,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Divider(height: 22),
                            const Text(
                              'Reported Patient Symptoms',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scan.symptomNotes,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Text(
                              'Clinical Determination',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.deepNavy,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _isApproved = true),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isApproved
                                            ? AppColors.successGreen.withAlpha(32)
                                            : AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isApproved
                                              ? AppColors.successGreen
                                              : AppColors.borderLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: AppColors.successGreen,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Approve & Verify',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _isApproved = false),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !_isApproved
                                            ? AppColors.dangerCrimson.withAlpha(30)
                                            : AppColors.backgroundLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: !_isApproved
                                              ? AppColors.dangerCrimson
                                              : AppColors.borderLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.cancel_outlined,
                                            color: AppColors.dangerCrimson,
                                            size: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Reject / Rescan',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _remarksController,
                              label: 'Required Clinical Notes & Follow-Up Plan',
                              hint:
                                  'Document fundus verification, OCT referral, or image quality feedback...',
                              prefixIcon: Icons.medical_information_outlined,
                              maxLines: 4,
                              validator: (String? v) {
                                if (v == null || v.trim().length < 8) {
                                  return 'Please enter at least 8 characters of clinical remarks';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            CustomButton(
                              label: _isApproved
                                  ? 'Publish Verified Clinical Report'
                                  : 'Reject Scan & Notify Patient',
                              icon: Icons.send_rounded,
                              backgroundColor: _isApproved
                                  ? AppColors.primaryTeal
                                  : AppColors.dangerCrimson,
                              isLoading: _screeningVm.isSubmitting.value,
                              onPressed: () => _submitDecision(scan),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}