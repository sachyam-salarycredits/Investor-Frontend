import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const fontFamily = 'Poppins';

  static const _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.ink,
    height: 1.3,
  );

  static TextStyle regular(double size, {Color? color}) =>
      _base.copyWith(fontSize: size, fontWeight: FontWeight.w400, color: color);

  static TextStyle medium(double size, {Color? color}) =>
      _base.copyWith(fontSize: size, fontWeight: FontWeight.w500, color: color);

  static TextStyle semiBold(double size, {Color? color}) =>
      _base.copyWith(fontSize: size, fontWeight: FontWeight.w600, color: color);

  static TextStyle bold(double size, {Color? color}) =>
      _base.copyWith(fontSize: size, fontWeight: FontWeight.w700, color: color);

  static TextStyle extraBold(double size, {Color? color}) =>
      _base.copyWith(fontSize: size, fontWeight: FontWeight.w800, color: color);

  static final display = semiBold(34).copyWith(letterSpacing: -1.2, height: 1.1);
  static final headline = semiBold(26).copyWith(letterSpacing: -0.5, height: 1.2);
  static final title = semiBold(22).copyWith(letterSpacing: -0.3);
  static final sectionTitle = semiBold(18).copyWith(letterSpacing: -0.2);
  static final cardTitle = semiBold(15);
  static final body = regular(14);
  static final bodyMuted = regular(14, color: AppColors.muted);
  static final caption = regular(12, color: AppColors.muted);
  static final small = regular(10.5, color: AppColors.muted);
  static final eyebrow = medium(11, color: AppColors.muted)
      .copyWith(letterSpacing: 0.7);
  static final button = semiBold(13);
}
