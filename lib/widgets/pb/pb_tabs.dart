import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SegmentedTab {
  final String label;
  final int? count;

  const SegmentedTab(this.label, {this.count});
}

/// Pill-style segmented control (Active / Closed).
class SegmentedTabs extends StatelessWidget {
  final List<SegmentedTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(child: _tab(i)),
          ],
        ],
      ),
    );
  }

  Widget _tab(int index) {
    final tab = tabs[index];
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 43,
        decoration: BoxDecoration(
          color: selected ? AppColors.greenDeep : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.greenDeep.withOpacity(0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tab.label,
              style: AppTextStyles.medium(
                12,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
            if (tab.count != null) ...[
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${tab.count}',
                  style: AppTextStyles.medium(
                    9.5,
                    color: selected ? AppColors.greenDeep : AppColors.muted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Labelled dropdown matching the marketplace filter fields.
class PbSelectField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const PbSelectField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.medium(10, color: AppColors.muted)),
        const SizedBox(height: 6),
        Container(
          height: 45,
          padding: const EdgeInsets.only(left: 12, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.green, size: 20),
              style: AppTextStyles.medium(11.5),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          itemLabel(item),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
