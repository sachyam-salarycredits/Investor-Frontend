import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PbNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const PbNavItem(this.label, this.icon, this.activeIcon);
}

const pbNavItems = [
  PbNavItem('Home', Icons.home_outlined, Icons.home_rounded),
  PbNavItem('Explore', Icons.explore_outlined, Icons.explore),
  PbNavItem('Portfolio', Icons.work_outline_rounded, Icons.work_rounded),
  PbNavItem('Profile', Icons.person_outline_rounded, Icons.person_rounded),
];

class PbBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PbNavItem> items;

  const PbBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items = pbNavItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottomInset > 0 ? bottomInset : 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: Border(
          top: BorderSide(color: AppColors.line.withOpacity(0.85)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.07),
            blurRadius: 35,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++) _item(items[i], i),
        ],
      ),
    );
  }

  Widget _item(PbNavItem item, int index) {
    final active = index == currentIndex;
    final color = active ? AppColors.green : AppColors.navInactive;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        label: item.label,
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(active ? item.activeIcon : item.icon,
                    size: 23, color: color),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: active
                      ? AppTextStyles.bold(10.5, color: color)
                      : AppTextStyles.medium(10.5, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
