import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputWidget extends StatelessWidget {
  String heading;
  FocusNode? focusNode;
  String hintStr;
  String alertStr;
  Widget? leftIcon;
  Widget? rightIcon;
  bool isValid;
  bool isError;
  int maxLength;
  Color titleColor;
  Color textColor;
  String? initialValue;
  bool isEditable;
  bool autoCaps;
  bool isEnable;
  Color alertColor;
  TextCapitalization textCapitalization;
  double horizontalMargin;
  void Function(String)? onChange;
  TextEditingController? controller;
  TextInputType keyboardType;
  bool? isFocused;
  bool? isUPI;
  String? prefixText;
  String? suffixText;

  InputWidget(
      {Key? key,
      this.heading = "",
      this.hintStr = "",
      this.leftIcon,
      this.focusNode,
      this.autoCaps = false,
      this.rightIcon,
      this.alertStr = "",
      this.isValid = false,
      this.isError = false,
      this.controller,
      this.maxLength = 100,
      this.titleColor = ColorsUtil.blackish,
      this.textColor = Colors.black,
      this.isEditable = true,
      this.isEnable = true,
      this.onChange,
      this.alertColor = Colors.black,
      this.textCapitalization = TextCapitalization.none,
      this.keyboardType = TextInputType.text,
      this.horizontalMargin = 15,
      this.initialValue,
      this.isFocused,
      this.isUPI,
      this.prefixText = '',
      this.suffixText = ''})
      : super(key: key);

  Color getDeviderColor() {
    if (isValid) {
      return ColorsUtil.blueColor;
    } else if (isError) {
      return ColorsUtil.redColor;
    } else if (isEditable) {
      return Colors.grey;
    } else {
      return Colors.grey.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Column(
        children: [
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: 15),

            decoration: BoxDecoration(
                border: Border.all(
                    width: (isFocused ?? false) ? 1.4 : 1,
                    color: (isValid && (isFocused ?? false))
                        ? AppColors.green
                        : isValid
                            ? AppColors.line
                            : (isError
                                ? ColorsUtil.redColor
                                : isFocused ?? false
                                    ? AppColors.green
                                    : AppColors.line)),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: ((isUPI ?? false) && (isFocused ?? false))
                    ? ColorsUtil.white
                    : (isUPI ?? false)
                        ? ColorsUtil.lightestGrey
                        : ColorsUtil.white
                // isValid
                //     ? ColorsUtil.blueColor.withAlpha(30)
                //     : (isError
                //     ? ColorsUtil.redColor.withAlpha(20)
                //     : ColorsUtil.inputBG),
                ),
            // BoxDecoration(
            //
            //   borderRadius: BorderRadius.only(
            //     topLeft: Radius.circular(8),
            //     topRight: Radius.circular(8),
            //   ),
            //   color: isValid
            //       ? ColorsUtil.blueColor.withAlpha(30)
            //       : (isError
            //           ? ColorsUtil.redColor.withAlpha(20)
            //           : ColorsUtil.inputBG),
            // ),
            child: Row(
              children: [
                // leftIcon == null ? SizedBox() : leftIcon!,
                // Visibility(
                //   visible: leftIcon != null,
                //   child: SizedBox(width: 15),
                // ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visibility(
                      //   visible: heading != "",
                      //   child: Text(
                      //     " $heading",
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       fontFamily: CustomFonts.nunito,
                      //       color: isValid
                      //           ? ColorsUtil.blueColor
                      //           : (isError ? ColorsUtil.redColor : titleColor),
                      //     ),
                      //   ),
                      // ),
                      TextFormField(
                        readOnly: false,
                        focusNode: focusNode,
                        enableSuggestions: false,
                        onFieldSubmitted: (val) {},
                        autocorrect: false,
                        inputFormatters: autoCaps
                            ? [UpperCaseTextFormatter()]
                            : keyboardType == TextInputType.number
                                ? [FilteringTextInputFormatter.digitsOnly]
                                : [],
                        // initialValue: initialValue,
                        controller: controller,
                        maxLength: maxLength,
                        enabled: isEditable && isEnable,
                        keyboardType: keyboardType,
                        textCapitalization: textCapitalization,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixText: prefixText,
                          suffixText: suffixText,
                          prefixStyle: AppTextStyles.medium(15,
                              color: AppColors.greenDeep),
                          labelText: heading,
                          labelStyle: AppTextStyles.regular(14,
                              color: isError
                                  ? ColorsUtil.redColor
                                  : AppColors.muted),
                          floatingLabelStyle: AppTextStyles.medium(12,
                              color: isError
                                  ? ColorsUtil.redColor
                                  : (isFocused ?? false)
                                      ? AppColors.green
                                      : AppColors.muted),
                          // hintText: hintStr,
                          isDense: true,
                          filled: false,
                          contentPadding: EdgeInsets.all(2),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          counterText: '',
                          counterStyle: TextStyle(fontSize: 0),
                        ),
                        style: AppTextStyles.medium(15,
                            color: AppColors.ink),
                        onChanged: onChange,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: rightIcon != null,
                  child: SizedBox(width: 15),
                ),
                rightIcon == null ? SizedBox() : rightIcon!,
              ],
            ),
          ),
          // Divider(
          //   color: getDeviderColor(),
          //   thickness: 2,
          //   height: 2,
          // ),
          Visibility(
            visible: alertStr != "",
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
              child: Text(
                alertStr,
                style: AppTextStyles.regular(11.5,
                    color: isError ? ColorsUtil.redColor : alertColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
