import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const canvas = Color(0xffE8EEE9);
  static const surface = Color(0xffFBFCF9);
  static const white = Color(0xffFFFFFF);
  static const ink = Color(0xff15251E);
  static const muted = Color(0xff708078);
  static const navInactive = Color(0xff8A9690);

  static const green = Color(0xff006B4C);
  static const greenDeep = Color(0xff004936);
  static const greenLink = Color(0xff72D8B8);
  static const forest = Color(0xff234D3C);
  static const mint = Color(0xffE5F2EC);
  static const mintSurface = Color(0xffF1F7F3);
  static const sage = Color(0xffDBE9DF);
  static const line = Color(0xffE7ECE8);
  static const handle = Color(0xffD5DDD8);
  static const dashedBorder = Color(0xffCFDAD3);
  static const metricSurface = Color(0xffF8FAF8);

  static const gold = Color(0xffD7A91E);
  static const goldDark = Color(0xff94720B);
  static const goldLight = Color(0xffF6D878);
  static const goldBright = Color(0xffF4D164);
  static const goldSoft = Color(0xffF8EDCA);

  static const riskConservativeText = Color(0xff116248);
  static const riskConservativeBg = Color(0xffDCF7E9);
  static const riskBalancedText = Color(0xff006071);
  static const riskBalancedBg = Color(0xffD8F4FA);
  static const riskGrowthText = Color(0xff795C05);
  static const riskGrowthBg = goldSoft;

  static const error = Color(0xffD64545);
  static const shadow = Color(0xff123025);
  static const scrim = Color(0xff071610);

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [green, greenDeep],
    stops: [0.0, 0.8],
  );

  static const screenTop = Color(0xffF4F1E6);
  static const screenBottom = Color(0xffF8F9F4);

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [screenTop, screenBottom],
    stops: [0.0, 0.45],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBright, goldLight],
  );

  static List<BoxShadow> softShadow([double opacity = 0.05]) => [
        BoxShadow(
          color: shadow.withOpacity(opacity),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
