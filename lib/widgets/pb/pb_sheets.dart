import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'pb_buttons.dart';

/// Shows [child] in a rounded bottom sheet with a drag handle.
Future<T?> showPbBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  double maxHeightFactor = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim.withOpacity(0.56),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: media.size.height * maxHeightFactor,
          ),
          child: PbSheetContainer(child: builder(sheetContext)),
        ),
      );
    },
  );
}

class PbSheetContainer extends StatelessWidget {
  final Widget child;
  final bool showHandle;

  const PbSheetContainer({
    Key? key,
    required this.child,
    this.showHandle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.scrim.withOpacity(0.22),
            blurRadius: 60,
            offset: const Offset(0, -24),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 11, bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.handle,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Title row used at the top of sheets, with a close button.
class PbSheetTitle extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final VoidCallback? onClose;

  const PbSheetTitle({
    Key? key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: AppTextStyles.semiBold(11, color: AppColors.green)
                      .copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 4),
              ],
              Text(title, style: AppTextStyles.semiBold(20)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: onClose ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          tooltip: 'Close',
        ),
      ],
    );
  }
}

/// Minus / amount / plus stepper.
class AmountStepper extends StatelessWidget {
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final double height;
  final bool compact;

  const AmountStepper({
    Key? key,
    required this.value,
    this.onDecrease,
    this.onIncrease,
    this.height = 46,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonWidth = compact ? 36.0 : 44.0;
    Widget button(IconData icon, VoidCallback? onTap) => SizedBox(
          width: buttonWidth,
          height: height,
          child: InkWell(
            onTap: onTap,
            child: Icon(
              icon,
              size: 17,
              color: onTap == null ? AppColors.muted : AppColors.green,
            ),
          ),
        );

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Material(
        color: Colors.white,
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            button(Icons.remove_rounded, onDecrease),
            Container(width: 1, color: AppColors.line),
            Flexible(
              fit: compact ? FlexFit.loose : FlexFit.tight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 0),
                child: Center(
                  child: Text(
                    value,
                    maxLines: 1,
                    style: AppTextStyles.semiBold(compact ? 12 : 13.5),
                  ),
                ),
              ),
            ),
            Container(width: 1, color: AppColors.line),
            button(Icons.add_rounded, onIncrease),
          ],
        ),
      ),
    );
  }
}

/// Label/value line used in summary sections; [total] renders emphasised.
class SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final bool total;

  const SummaryLine({
    Key? key,
    required this.label,
    required this.value,
    this.total = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: total ? 10 : 6, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: total
                  ? AppTextStyles.semiBold(14)
                  : AppTextStyles.regular(12, color: AppColors.muted),
            ),
          ),
          Text(
            value,
            style: total
                ? AppTextStyles.semiBold(16, color: AppColors.green)
                : AppTextStyles.semiBold(12),
          ),
        ],
      ),
    );
  }
}

/// Centered success state with a green check, title, message and CTA.
class SuccessSheet extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onDone;

  const SuccessSheet({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 30, 32, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center, style: AppTextStyles.semiBold(22)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.regular(13, color: AppColors.muted)
                .copyWith(height: 1.7),
          ),
          const SizedBox(height: 24),
          PbPrimaryButton(label: buttonLabel, onPressed: onDone),
        ],
      ),
    );
  }
}
