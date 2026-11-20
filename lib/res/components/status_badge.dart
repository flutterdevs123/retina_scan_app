import 'package:flutter/material.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final ScreeningStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ScreeningStatus.pending:
        color = AppColors.warningAmber;
      case ScreeningStatus.reviewed:
        color = AppColors.successGreen;
      case ScreeningStatus.rejected:
        color = AppColors.dangerCrimson;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class SeverityBadge extends StatelessWidget {
  final DrSeverity severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity) {
      case DrSeverity.noDr:
        color = AppColors.successGreen;
      case DrSeverity.mildNpdr:
        color = AppColors.infoSky;
      case DrSeverity.moderateNpdr:
        color = AppColors.warningAmber;
      case DrSeverity.severeNpdr:
      case DrSeverity.proliferativeDr:
        color = AppColors.dangerCrimson;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        severity.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}