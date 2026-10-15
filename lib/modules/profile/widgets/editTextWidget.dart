import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';

class EditableTextWidget extends StatelessWidget {
  final bool isEdit, isHeading;
  final TextInputType keyboardType;
  final String value;
  final void Function(String finish) onChanged;
  final int maxLength;

  EditableTextWidget({
    Key? key,
    required this.value,
    required this.isEdit,
    required this.onChanged,
    this.isHeading = false,
    this.maxLength = 100,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autocorrect: false,
      enableSuggestions: false,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: keyboardType,
      maxLines: 6,
      minLines: 1,
      decoration: InputDecoration(
          border: null,
          disabledBorder: null,
          filled: true,
          fillColor: Colors.transparent,
          counter: Offstage(),
          contentPadding: EdgeInsets.zero),
      initialValue: value,
      maxLength: maxLength,
      onChanged: onChanged,
      enabled: isEdit,
      style: isHeading
          ? TextStyle(
              color: ColorsUtil.lighterGrey,
              fontFamily: CustomFonts.nunito,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            )
          : TextStyle(
              color: ColorsUtil.dividerColor,
              fontFamily: CustomFonts.nunito,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
    );
  }
}
