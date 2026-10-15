import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'pb_cards.dart';

/// Marketplace loan card: category, title, risk tag, three metrics, funding
/// ring and a dark footer with a details link and a trailing action.
class LoanCard extends StatelessWidget {
  final String category;
  final String title;
  final Widget? riskTag;
  final List<PbMetric> metrics;
  final double? fundedPercent;
  final String detailLabel;
  final VoidCallback? onDetails;
  final Widget? action;
  final bool dimmed;

  const LoanCard({
    Key? key,
    required this.category,
    required this.title,
    required this.metrics,
    this.riskTag,
    this.fundedPercent,
    this.detailLabel = 'View loan details',
    this.onDetails,
    this.action,
    this.dimmed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.line),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(10.5,
                                color: AppColors.green)
                            .copyWith(letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(15),
                      ),
                    ],
                  ),
                ),
                if (riskTag != null) ...[
                  const SizedBox(width: 12),
                  riskTag!,
                ],
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Divider(height: 1, thickness: 1, color: AppColors.line),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                for (final metric in metrics)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: metric,
                    ),
                  ),
                if (fundedPercent != null) ProgressRing(percent: fundedPercent!),
              ],
            ),
          ),
          Container(
            color: dimmed ? AppColors.sage : AppColors.greenDeep,
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onDetails,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        detailLabel,
                        style: AppTextStyles.semiBold(
                          11,
                          color: dimmed
                              ? AppColors.greenDeep
                              : AppColors.greenLink,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
