import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/images.dart';

/// Logo on the left, square notification button on the right.
class PbBrandHeader extends StatelessWidget {
  final VoidCallback? onBellTap;
  final bool showBadge;
  final Widget? trailing;

  const PbBrandHeader({
    Key? key,
    this.onBellTap,
    this.showBadge = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          LocalImages.peerbridge_logo,
          height: 30,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
        const Spacer(),
        trailing ??
            PbIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: onBellTap,
              showBadge: showBadge,
            ),
      ],
    );
  }
}

class PbIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;

  const PbIconButton({
    Key? key,
    required this.icon,
    this.onTap,
    this.showBadge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.82),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      shadowColor: AppColors.shadow.withOpacity(0.06),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.greenDeep),
              if (showBadge)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green gradient page header with rounded bottom corners.
class PbPageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;

  const PbPageHeader({
    Key? key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.actions = const [],
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(8, topInset + 12, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(21)),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.13),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: 'Go back',
            )
          else
            const SizedBox(width: 12),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiBold(20, color: Colors.white),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Section title with optional subtitle and trailing text action.
class PbSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PbSectionTitle({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                actionLabel!,
                style: AppTextStyles.semiBold(12, color: AppColors.green),
              ),
            ),
          ),
      ],
    );
  }
}
