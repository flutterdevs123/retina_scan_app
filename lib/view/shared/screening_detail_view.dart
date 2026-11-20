import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/fundus_visualizer.dart';
import 'package:retina_scan_app/res/components/status_badge.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/services/responsive_service.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

class ScreeningDetailView extends StatefulWidget {
  const ScreeningDetailView({super.key});

  @override
  State<ScreeningDetailView> createState() => _ScreeningDetailViewState();
}

class _ScreeningDetailViewState extends State<ScreeningDetailView> {
  bool _showGradCam = true;

  String _formatDate(String iso) {
    final DateTime? parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('MMM d, yyyy â€¢ HH:mm').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final ScreeningViewModel screeningVm = Get.find<ScreeningViewModel>();
    final double hPad = ResponsiveService.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostic Screening Report')),
      body: SafeArea(
        child: Obx(() {
          final ScreeningModel? scan = screeningVm.activeScreening.value;
          if (scan == null) {
            return const Center(child: Text('No screening selected.'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showGradCam = false),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: !_showGradCam
                                    ? AppColors.deepNavy
                                    : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                'Original Fundus Scan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: !_showGradCam
                                      ? AppColors.surfaceWhite
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _showGradCam = true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: _showGradCam
                                    ? AppColors.primaryTeal
                                    : AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Text(
                                'Grad-CAM AI Localization',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _showGradCam
                                      ? AppColors.surfaceWhite
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FundusVisualizer(
                      imagePath: scan.imagePath,
                      detectionPoints: scan.detectionPoints,
                      showGradCam: _showGradCam,
                      height: 255,
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
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${scan.id} â€¢ ${scan.eyeSide}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge(status: scan.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Captured ${_formatDate(scan.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Divider(height: 22),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              SeverityBadge(severity: scan.severity),
                              Text(
                                'Model Confidence: ${(scan.confidenceScore * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            scan.aiSummary,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (scan.detectionPoints.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 14),
                            const Text(
                              'Localized AI Detection Points',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...scan.detectionPoints.map((DetectionPoint dp) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.my_location_rounded,
                                      size: 16,
                                      color: AppColors.primaryTeal,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        dp.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(dp.confidence * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
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
                          const Text(
                            'Patient Symptom Notes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            scan.symptomNotes,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: scan.status == ScreeningStatus.pending
                              ? AppColors.warningAmber.withAlpha(110)
                              : AppColors.primaryTeal.withAlpha(120),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Ophthalmologist Clinical Review',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (scan.status == ScreeningStatus.pending)
                            const Text(
                              'This screening is currently queued for specialist verification. Clinical remarks will appear here once reviewed.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else ...<Widget>[
                            Text(
                              'Reviewed by ${scan.doctorName ?? 'Specialist'} (${scan.doctorLicenseId ?? ''})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                            if (scan.reviewedAt != null) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(scan.reviewedAt!),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              scan.doctorRemarks ?? '',
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.4,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}