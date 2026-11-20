import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:retina_scan_app/models/screening_model.dart';
import 'package:retina_scan_app/res/components/status_badge.dart';
import 'package:retina_scan_app/res/constants/app_colors.dart';

class ScreeningCard extends StatelessWidget {
  final ScreeningModel screening;
  final VoidCallback onTap;
  final bool showPatientName;

  const ScreeningCard({
    super.key,
    required this.screening,
    required this.onTap,
    this.showPatientName = false,
  });

  String _formatDate(String iso) {
    final DateTime? parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat('MMM d, yyyy â€¢ HH:mm').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final String confidencePct = '${(screening.confidenceScore * 100).toStringAsFixed(1)}%';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: screening.severity.isHighRisk &&
                    screening.status == ScreeningStatus.pending
                ? AppColors.dangerCrimson.withAlpha(110)
                : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: AppColors.accentMint,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        showPatientName
                            ? '${screening.patientName} (${screening.id})'
                            : '${screening.id} â€¢ ${screening.eyeSide}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        showPatientName
                            ? '${screening.eyeSide} â€¢ ${_formatDate(screening.createdAt)}'
                            : _formatDate(screening.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: screening.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              screening.aiSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SeverityBadge(severity: screening.severity),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Conf: $confidencePct',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}