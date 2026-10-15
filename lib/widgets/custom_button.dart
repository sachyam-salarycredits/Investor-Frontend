import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  String titleStr;
  Color bgColor;
  Color borderColor;
  Widget? leftIcon;
  VoidCallback? onPress;
  Color textColor;
  double textSize;
  bool isLoader;
  bool isDisable;
  double horizontalMargin;

  CustomButton({
    Key? key,
    this.titleStr = "",
    this.leftIcon,
    this.onPress,
    this.bgColor = ColorsUtil.blueColor,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.isLoader = false,
    this.isDisable = false,
    this.horizontalMargin = 15,
    this.textSize = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFilled = bgColor != Colors.transparent;
    final hasBorder = borderColor != Colors.transparent;
    return Container(
      height: 54,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: hasBorder
              ? borderColor
              : isFilled
                  ? Colors.transparent
                  : AppColors.line,
        ),
        borderRadius: BorderRadius.circular(14),
        color: isFilled ? bgColor.withOpacity(isDisable ? 0.4 : 1) : bgColor,
        boxShadow: isFilled && !isDisable
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: isLoader,
              child: Row(
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(
                      color: textColor,
                      backgroundColor: textColor.withOpacity(0.25),
                      strokeWidth: 2,
                    ),
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            leftIcon == null ? SizedBox() : leftIcon!,
            Visibility(
              visible: leftIcon != null,
              child: SizedBox(width: 10),
            ),
            Flexible(
              child: Text(
                titleStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiBold(textSize, color: textColor),
              ),
            ),
          ],
        ),
        onPressed: isDisable ? null : onPress,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
