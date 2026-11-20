import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/metric_card.dart';
import 'package:retina_scan_app/res/components/screening_card.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';
import 'package:retina_scan_app/res/routes/app_routes.dart';
import 'package:retina_scan_app/res/services/responsive_service.dart';
import 'package:retina_scan_app/res/services/retina_sync_service.dart';
import 'package:retina_scan_app/view_models/auth_view_model.dart';
import 'package:retina_scan_app/view_models/screening_view_model.dart';

class DoctorDashboardView extends StatelessWidget {
  const DoctorDashboardView({super.key});

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
                'Ophthalmology Triage Console',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
              ),
              Text(
                '${auth.currentUser.value?.fullName ?? 'Doctor'} â€¢ ${auth.currentUser.value?.medicalLicenseId ?? ''}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Obx(
            () => IconButton(
              tooltip: 'Sync Clinical Queue',
              onPressed: syncService.isSyncing.value
                  ? null
                  : () async {
                      await syncService.syncNow();
                      screeningVm.loadScreenings();
                    },
              icon: const Icon(Icons.sync_rounded, color: AppColors.accentMint),
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
          final List<ScreeningModel> queue =
              screeningVm.doctorFilteredScreenings;
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
                        title: 'Pending Queue',
                        value: screeningVm.doctorPendingCount.toString(),
                        icon: Icons.pending_actions_rounded,
                        accentColor: AppColors.warningAmber,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'Reviewed',
                        value: screeningVm.doctorReviewedCount.toString(),
                        icon: Icons.task_alt_rounded,
                        accentColor: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        title: 'High-Risk Alerts',
                        value: screeningVm.doctorHighRiskCount.toString(),
                        icon: Icons.warning_amber_rounded,
                        accentColor: AppColors.dangerCrimson,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (String value) =>
                      screeningVm.searchQuery.value = value,
                  decoration: const InputDecoration(
                    hintText: 'Search by patient name, scan ID, or DR grade...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <String>['Pending', 'Reviewed', 'All']
                      .map((String tab) {
                    final bool selected =
                        screeningVm.selectedDoctorFilter.value == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: selected,
                        selectedColor: AppColors.primaryTeal.withAlpha(45),
                        onSelected: (_) =>
                            screeningVm.selectedDoctorFilter.value = tab,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                if (queue.isEmpty)
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
                          Icons.inbox_outlined,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No patient scans in this queue.',
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
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final ScreeningModel item = queue[index];
                      return ScreeningCard(
                        screening: item,
                        showPatientName: true,
                        onTap: () {
                          screeningVm.openScreening(item);
                          Get.toNamed(AppRoutes.doctorReview);
                        },
                      );
                    },
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 175,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final ScreeningModel item = queue[index];
                      return ScreeningCard(
                        screening: item,
                        showPatientName: true,
                        onTap: () {
                          screeningVm.openScreening(item);
                          Get.toNamed(AppRoutes.doctorReview);
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