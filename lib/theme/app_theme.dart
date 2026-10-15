import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      onPrimary: AppColors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.greenDeep,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      background: AppColors.surface,
      onBackground: AppColors.ink,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      primaryColor: AppColors.greenDeep,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTextStyles.fontFamily,
      visualDensity: VisualDensity.compact,
      dividerColor: AppColors.line,
      textTheme: const TextTheme().apply(
        fontFamily: AppTextStyles.fontFamily,
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.semiBold(19, color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.greenDeep,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.line,
          disabledForegroundColor: AppColors.muted,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenDeep,
          side: const BorderSide(color: AppColors.line),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.green,
          textStyle: AppTextStyles.semiBold(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.regular(13, color: AppColors.muted),
        labelStyle: AppTextStyles.medium(13, color: AppColors.muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        modalBackgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.semiBold(17),
        contentTextStyle: AppTextStyles.regular(13, color: AppColors.muted),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? AppColors.green
              : AppColors.white,
        ),
        side: const BorderSide(color: AppColors.muted, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.green),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.green,
        unselectedLabelColor: AppColors.muted,
        labelStyle: AppTextStyles.semiBold(13),
        unselectedLabelStyle: AppTextStyles.medium(13),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.green, width: 2.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.greenDeep,
        contentTextStyle: AppTextStyles.medium(13, color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
