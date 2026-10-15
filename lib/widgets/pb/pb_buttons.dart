import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Full-width dark green call to action used at the bottom of sheets and forms.
class PbPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool expand;

  const PbPrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final child = Container(
      height: 54,
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: enabled ? AppColors.greenDeep : AppColors.line,
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.greenDeep.withOpacity(0.17),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          else ...[
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiBold(
                  13.5,
                  color: enabled ? Colors.white : AppColors.muted,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                size: 18,
                color: enabled ? Colors.white : AppColors.muted,
              ),
            ],
          ],
        ],
      ),
    );

    return Opacity(
      opacity: onPressed == null ? 0.8 : 1,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

/// Gold gradient action used on dark green cards.
class PbGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  const PbGoldButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff14231D).withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiBold(12.5, color: AppColors.greenDeep),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, size: 17, color: AppColors.greenDeep),
            ],
          ],
        ),
      ),
    );
  }
}

/// Translucent white action used next to [PbGoldButton] on dark cards.
class PbGhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const PbGhostButton({
    Key? key,
    required this.label,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.semiBold(12.5, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Compact dark green button, e.g. "Add funds" in the balance strip.
class PbDarkButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PbDarkButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.greenDeep,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(label, style: AppTextStyles.semiBold(11.5, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// White pill button used in the dark footer of loan cards.
class PbLightButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PbLightButton({
    Key? key,
    required this.label,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: AppColors.greenDeep),
              const SizedBox(width: 5),
            ],
            Text(label, style: AppTextStyles.bold(11, color: AppColors.greenDeep)),
          ],
        ),
      ),
    );
  }
}
