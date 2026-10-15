import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BankAccountDetailsCard extends StatelessWidget {
  String detailHeading3;

  BankAccountDetailsCard({
    required this.detailHeading3,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    var bankDetails = provider.userDetails!.bankAccountDetails!;
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
              Text(detailHeading3,
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
                    context.pushNamed(RoutesName.BankDetail);
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
                  )),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Table(
            defaultColumnWidth: FixedColumnWidth(150.0),
            children: [
              TableRow(children: [
                Text(
                  'Bank Name',
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
                    bankDetails.bankName,
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
                  'Branch Name',
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
                    bankDetails.branchName,
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
                  'Account Type',
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
                    bankDetails.accountType,
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
                  'Door No./ Street Name/ Building',
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
                    bankDetails.address,
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
                  'IFSC Code',
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
                    bankDetails.ifscCode,
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
                  'MICR Code',
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
                    bankDetails.micrCode,
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
                  'Bank Account Number',
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
                    bankDetails.accountNumber,
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
            ],
          ),
        ],
      ),
    );
  }
}
