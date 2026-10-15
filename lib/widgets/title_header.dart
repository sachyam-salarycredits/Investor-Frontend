import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
// import 'package:peerbridge/routes_management/app_router.dart';
// import 'package:peerbridge/routes_management/routes_list.dart';

class TitleHeader extends StatelessWidget {
  Color bgColor;
  String titleStr;
  String desStr;
  bool? isVisibleSwitch;
  bool? switchValue;
  Function(bool)? onChange;

  TitleHeader({
    Key? key,
    this.bgColor = Colors.white,
    this.titleStr = '',
    this.desStr = '',
    this.onChange,
    this.switchValue = false,
    this.isVisibleSwitch = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titleStr,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.headline,
                ),
              ),
              if (isVisibleSwitch ?? false)
                FlutterSwitch(
                  activeColor: ColorsUtil.blueColor,
                  width: 50.0,
                  height: 25.0,
                  // valueFontSize: 25.0,
                  toggleSize: 20.0,
                  value: switchValue ?? false,
                  borderRadius: 30.0,
                  // padding: 8.0,
                  // showOnOff: true,
                  onToggle: (val) {
                    if (onChange != null) {
                      onChange!(val);
                    }
                  },
                )
            ],
          ),
          SizedBox(height: 10),
          Text(
            desStr,
            style: AppTextStyles.regular(13.5, color: AppColors.muted)
                .copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
