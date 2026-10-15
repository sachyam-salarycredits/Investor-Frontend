import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MIPDetailsCard extends StatelessWidget {
  String detailHeading4;

  MIPDetailsCard({
    required this.detailHeading4,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    bool isEnabled = provider.userDetails?.mip ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: ColorsUtil.circleGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(detailHeading4,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: ColorsUtil.black,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
              // FlutterSwitch(
              //   height: 22.0,
              //   width: 45.0,
              //   toggleSize: 21.0,
              //   borderRadius: 10.5,
              //   activeColor: ColorsUtil.greenColor,
              //   value: isEnabled,
              //   onToggle: (value) {
              //     if (value) {
              //       context.pushNamed(RoutesName.MIPSetUp);
              //     } else {}
              //     // setState(() {
              //     //   isDisabled = value;
              //     // });
              //   },
              // ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Table(defaultColumnWidth: FixedColumnWidth(150.0), children: [
            TableRow(children: [
              Text(
                'MIP is',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: ColorsUtil.lighterGrey,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.8),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  isEnabled ? "Enabled" : 'Disabled',
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              )
            ]),
            rowSpacer,
          ]),
        ],
      ),
    );
  }
}
