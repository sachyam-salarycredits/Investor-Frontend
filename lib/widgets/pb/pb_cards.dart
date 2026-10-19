import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'pb_buttons.dart';

/// White rounded card with a hairline border and soft shadow.
class PbCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  const PbCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.color = Colors.white,
    this.borderColor = AppColors.line,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: AppColors.softShadow(0.045),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

/// "Available to invest" strip with an Add funds action.
class BalanceStrip extends StatelessWidget {
  final String amount;
  final String label;
  final String? note;
  final String actionLabel;
  final VoidCallback? onAdd;

  const BalanceStrip({
    Key? key,
    required this.amount,
    this.label = 'AVAILABLE TO INVEST',
    this.note,
    this.actionLabel = 'Add funds',
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xffE5EEE8)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xffF2F8F4)],
        ),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.eyebrow),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: AppTextStyles.semiBold(24)
                        .copyWith(letterSpacing: -0.4),
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          size: 12, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(note!,
                            style: AppTextStyles.regular(10,
                                color: AppColors.muted)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          PbDarkButton(
            label: actionLabel,
            icon: Icons.add_rounded,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

/// Green gradient hero card with the total value, change badge and growth chart.
class PortfolioValueCard extends StatelessWidget {
  final String title;
  final String value;
  final String? changeBadge;
  final String? changeNote;
  final String? periodLabel;
  final List<double> chartPoints;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  const PortfolioValueCard({
    Key? key,
    required this.value,
    this.title = 'Total portfolio value',
    this.changeBadge,
    this.changeNote,
    this.periodLabel,
    this.chartPoints = const [],
    this.primaryLabel = 'Explore investments',
    this.onPrimary,
    this.secondaryLabel = 'Add funds',
    this.onSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.greenGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.20),
            blurRadius: 42,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -110,
            bottom: -110,
            child: _Rings(),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.medium(13,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    if (periodLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          periodLabel!,
                          style: AppTextStyles.regular(11,
                              color: Colors.white.withOpacity(0.76)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.display.copyWith(color: Colors.white),
                  ),
                ),
                if (changeBadge != null || changeNote != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (changeBadge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward_rounded,
                                  size: 12, color: AppColors.goldLight),
                              const SizedBox(width: 3),
                              Text(
                                changeBadge!,
                                style: AppTextStyles.semiBold(11.5,
                                    color: AppColors.goldLight),
                              ),
                            ],
                          ),
                        ),
                      if (changeNote != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            changeNote!,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.regular(11.5,
                                color: Colors.white.withOpacity(0.6)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 76,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: GrowthChartPainter(points: chartPoints),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PbGoldButton(
                        label: primaryLabel,
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    PbGhostIconButton(
                      icon: Icons.account_balance_wallet_outlined,
                      semanticLabel: secondaryLabel,
                      onPressed: onSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Rings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget ring(double size, double opacity) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(opacity)),
          ),
        );
    return SizedBox(
      width: 304,
      height: 304,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ring(304, 0.03),
          ring(248, 0.04),
          ring(192, 0.12),
        ],
      ),
    );
  }
}

/// Smooth gold growth line with a fading fill and an end dot.
class GrowthChartPainter extends CustomPainter {
  final List<double> points;

  GrowthChartPainter({required this.points});

  static const _fallback = [
    70.0, 60.0, 64.0, 50.0, 45.0, 42.0, 31.0, 25.0, 18.0, 8.0
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final values = _normalised();
    if (values.length < 2) return;

    final step = size.width / (values.length - 1);
    final offsets = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(i * step, 6 + values[i] * (size.height - 12)),
    ];

    final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      line.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.goldLight.withOpacity(0.28),
            AppColors.goldLight.withOpacity(0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.goldLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    final end = offsets.last;
    canvas.drawCircle(end, 4.5, Paint()..color = AppColors.greenDeep);
    canvas.drawCircle(end, 3.5, Paint()..color = AppColors.goldLight);
  }

  /// Returns values in 0..1 where 0 is the top of the chart.
  List<double> _normalised() {
    if (points.length < 2) {
      return _fallback.map((v) => v / 84).toList();
    }
    final maxV = points.reduce(math.max);
    final minV = points.reduce(math.min);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : maxV - minV;
    return points.map((v) => 1 - (v - minV) / range).toList();
  }

  @override
  bool shouldRepaint(covariant GrowthChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

/// Small rounded tile with a tinted icon, value and label.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconBg = AppColors.mint,
    this.iconColor = AppColors.green,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PbCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      radius: 18,
      color: Colors.white.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PbIconTile(icon: icon, background: iconBg, color: iconColor),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.semiBold(16)),
          Text(label, style: AppTextStyles.regular(11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class PbIconTile extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final double size;

  const PbIconTile({
    Key? key,
    required this.icon,
    this.background = AppColors.mint,
    this.color = AppColors.green,
    this.size = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Icon(icon, size: size * 0.55, color: color),
    );
  }
}

/// Green gradient "Refer & earn" banner.
class ReferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ReferCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.green, AppColors.greenDeep],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.card_giftcard_rounded,
                  color: AppColors.goldLight, size: 24),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.semiBold(13, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.regular(10.5,
                        color: Colors.white.withOpacity(0.68)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

enum PbRisk { conservative, balanced, growth }

class RiskTag extends StatelessWidget {
  final String label;
  final PbRisk risk;

  const RiskTag({Key? key, required this.label, required this.risk})
      : super(key: key);

  /// Maps the API category codes (C, M, H) used by the marketplace.
  factory RiskTag.fromCategory(String category) {
    switch (category) {
      case 'C':
        return const RiskTag(label: 'Conservative', risk: PbRisk.conservative);
      case 'M':
        return const RiskTag(label: 'Moderate', risk: PbRisk.balanced);
      default:
        return const RiskTag(label: 'High', risk: PbRisk.growth);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (risk) {
      case PbRisk.conservative:
        bg = AppColors.riskConservativeBg;
        fg = AppColors.riskConservativeText;
        break;
      case PbRisk.balanced:
        bg = AppColors.riskBalancedBg;
        fg = AppColors.riskBalancedText;
        break;
      case PbRisk.growth:
        bg = AppColors.riskGrowthBg;
        fg = AppColors.riskGrowthText;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AppTextStyles.medium(10, color: fg)),
    );
  }
}

/// Uppercase status pill, e.g. ACTIVE / CLOSED.
class StatusPill extends StatelessWidget {
  final String label;
  final bool active;

  const StatusPill({Key? key, required this.label, this.active = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.mint : AppColors.line,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.semiBold(9.5,
            color: active ? AppColors.green : AppColors.muted),
      ),
    );
  }
}

/// Funding progress ring with the percentage in the centre.
class ProgressRing extends StatelessWidget {
  final double percent;
  final double size;

  const ProgressRing({Key? key, required this.percent, this.size = 52})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(clamped),
        child: Center(
          child: Text(
            '${(clamped * 100).round()}%',
            style: AppTextStyles.extraBold(9.5, color: AppColors.green),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;

  _RingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.125;
    final rect = Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..color = AppColors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value;
}

/// Label/value metric used inside cards.
class PbMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double valueSize;
  final CrossAxisAlignment alignment;

  const PbMetric({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueSize = 12,
    this.alignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular(9.5, color: AppColors.muted)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.semiBold(valueSize, color: valueColor),
          ),
        ),
      ],
    );
  }
}

/// Bordered card with a title and label/value rows.
class DetailListCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> rows;
  final Widget? footer;

  const DetailListCard({
    Key? key,
    required this.title,
    required this.rows,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PbCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.semiBold(15, color: AppColors.greenDeep)),
          const SizedBox(height: 8),
          ...rows.map((row) => DetailRow(label: row.key, value: row.value)),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: AppTextStyles.regular(12, color: AppColors.muted)),
          ),
          const SizedBox(width: 24),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.medium(12, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid tile showing a label and a large value, used in summary grids.
class SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;
  final bool highlight;

  const SummaryTile({
    Key? key,
    required this.label,
    required this.value,
    this.positive = false,
    this.highlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.goldSoft : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.gold.withOpacity(0.38) : AppColors.line,
        ),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.regular(11, color: AppColors.muted)),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.semiBold(
                17,
                color: positive ? AppColors.green : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PbEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const PbEmptyState({
    Key? key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dashedBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.muted, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.regular(12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
