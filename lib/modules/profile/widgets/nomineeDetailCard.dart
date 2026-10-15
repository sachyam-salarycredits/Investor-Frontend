import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NomineeDetailsCard extends StatelessWidget {
  String detailHeading5;

  NomineeDetailsCard({
    required this.detailHeading5,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    var nomineeDetails = provider.userDetails!.nomineeDetails!;
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
              Text(detailHeading5,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: ColorsUtil.black,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
              TextButton.icon(
                onPressed: () {
                  context.pushNamed(RoutesName.NomineeDetail);
                },
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18.0,
                  color: ColorsUtil.greenText,
                ),
                label: Text(
                  'Edit',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0,
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.greenText),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Table(defaultColumnWidth: FixedColumnWidth(150.0), children: [
            TableRow(children: [
              Text(
                'Nominee Name',
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
                  nomineeDetails.nomineeFullName,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee DOB',
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
                  nomineeDetails.dob.getSimpleDateStr(),
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Pan Number',
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
                  nomineeDetails.panNumber == ''
                      ? '-'
                      : nomineeDetails.panNumber,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee Address',
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
                  nomineeDetails.address,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee Relationship',
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
                  nomineeDetails.relationship,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee Pincode',
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
                  nomineeDetails.pincode,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee City',
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
                  nomineeDetails.city,
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
            TableRow(children: [
              Text(
                'Nominee State',
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
                  Utils.getTextForDataTable(nomineeDetails.state),
                  style: TextStyle(
                      color: ColorsUtil.dividerColor,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.8),
                ),
              ),
            ]),
            rowSpacer,
          ])
        ],
      ),
    );
  }
}
