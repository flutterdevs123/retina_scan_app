import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/custom_button.dart';
import 'package:retina_scan_app/res/components/metric_card.dart';
import 'package:retina_scan_app/res/components/screening_card.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/res/services/responsive_service.dart';
import 'package:retina_scan_app/res/services/retina_sync_service.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

class PatientDashboardView extends StatelessWidget {
  const PatientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = Get.find<AuthViewModel>();
    final ScreeningViewModel screeningVm = Get.find<ScreeningViewModel>();
    final RetinaSyncService syncService = Get.find<RetinaSyncService>();
    final double hPad = ResponsiveService.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Patient Screening Portal',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
              ),
              Text(
                auth.currentUser.value?.fullName ?? 'Patient',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Obx(
            () => TextButton.icon(
              onPressed: syncService.isSyncing.value
                  ? null
                  : () async {
                      await syncService.syncNow();
                      screeningVm.loadScreenings();
                    },
              icon: Icon(
                syncService.isSyncing.value
                    ? Icons.sync_rounded
                    : Icons.cloud_done_outlined,
                color: AppColors.accentMint,
                size: 18,
              ),
              label: Text(
                syncService.isSyncing.value
                    ? 'Syncing'
                    : syncService.pendingCount.value > 0
                        ? 'Sync (${syncService.pendingCount.value})'
                        : 'Synced',
                style: const TextStyle(
                  color: AppColors.surfaceWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final List<ScreeningModel> records =
              screeningVm.filteredPatientScreenings;
          final int columns = ResponsiveService.gridCrossAxisCount(context);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricCard(
                        title: 'Total Scans',
                        value: screeningVm.patientTotalCount.toString(),
                        icon: Icons.analytics_outlined,
                        accentColor: AppColors.infoSky,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'Pending',
                        value: screeningVm.patientPendingCount.toString(),
                        icon: Icons.hourglass_top_rounded,
                        accentColor: AppColors.warningAmber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'Reviewed',
                        value: screeningVm.patientReviewedCount.toString(),
                        icon: Icons.verified_rounded,
                        accentColor: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: 'Submit New Retinal Fundus Scan',
                  icon: Icons.add_a_photo_outlined,
                  onPressed: () => Get.toNamed(AppRoutes.newScan),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <String>['All', 'Pending', 'Reviewed', 'Rejected']
                        .map((String filter) {
                      final bool selected =
                          screeningVm.selectedPatientFilter.value == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          selectedColor: AppColors.primaryTeal.withAlpha(45),
                          onSelected: (_) =>
                              screeningVm.selectedPatientFilter.value = filter,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                if (records.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Column(
                      children: <Widget>[
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No retinal screenings match this filter.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (columns == 1)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final ScreeningModel item = records[index];
                      return ScreeningCard(
                        screening: item,
                        onTap: () {
                          screeningVm.openScreening(item);
                          Get.toNamed(AppRoutes.screeningDetail);
                        },
                      );
                    },
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 175,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final ScreeningModel item = records[index];
                      return ScreeningCard(
                        screening: item,
                        onTap: () {
                          screeningVm.openScreening(item);
                          Get.toNamed(AppRoutes.screeningDetail);
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}