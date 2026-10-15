import 'package:peerbridge/modules/marketplace/models/popup_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/outlined_popup_container.dart';
import 'package:peerbridge/modules/profile/widgets/logoWidget.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'custom_tooltip_for_detail.dart';

class WebViewDetailWidget extends StatelessWidget {
  GlobalKey _toolTipKey = GlobalKey();
  GlobalKey _toolTipKey1 = GlobalKey();
  GlobalKey _toolTipKey2 = GlobalKey();
  GlobalKey _toolTipKey3 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    var userDetails = provider.userDetails!;
    var fundDetails = provider.userFundTransferDetails;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: ListTile(
              leading: LogoWidget(
                size: 80,
                url: userDetails.profileDetails!.profileUrl,
              ),
              title: Text(
                userDetails.profileDetails!.fullName,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 25.0,
                  fontFamily: CustomFonts.nunito,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: InkWell(
                onTap: () {
                  context.pushNamed(RoutesName.ProfileDetail);
                },
                child: Row(
                  children: [
                    Text(
                      'Profile ${provider.getProfilePercentage()}% complete',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: CustomFonts.nunito,
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.greenText,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: ColorsUtil.greenText,
                      size: 21,
                    )
                  ],
                ),
              )),
        ),

        Expanded(
          flex: 2,
          child: GridView.count(
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            crossAxisCount: 2,
            padding: EdgeInsets.symmetric(horizontal: 8),
            children: [
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Total Funds Transferred',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '₹${fundDetails?.totalFundsTransferred?.transactionAmount.commaAddedValue() ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: CustomTooltipForDetail(
                  popupData: fundDetails?.totalFundsTransferred?.statement
                          .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                              "${e.amount.round()}"))
                          .toList() ??
                      [],
                  message: 'Date : 12 Aug 2021\nAmount : ₹ 12,580.34',
                  key: _toolTipKey,
                  child: Icon(
                    Icons.info_outline,
                    color: ColorsUtil.lighterGrey,
                  ),
                ),
              ),
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Total Funds Withdrawn',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '₹${fundDetails?.totalFundsWithdrawn?.transactionAmount.commaAddedValue() ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: CustomTooltipForDetail(
                  popupData: fundDetails?.totalFundsWithdrawn?.statement
                          .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                              "${e.amount.round()}"))
                          .toList() ??
                      [],
                  message: '',
                  key: _toolTipKey1,
                  child: Icon(
                    Icons.info_outline,
                    color: ColorsUtil.lighterGrey,
                  ),
                ),
              ),
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Income Since Inception',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '₹${fundDetails?.totalIncome?.income.commaAddedValue() ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: CustomTooltipForDetail(
                  popupData: fundDetails?.totalIncome?.statement
                          .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                              "${e.amount.round()}"))
                          .toList() ??
                      [],
                  message: '',
                  key: _toolTipKey2,
                  child: Icon(
                    Icons.info_outline,
                    color: ColorsUtil.lighterGrey,
                  ),
                ),
              ),
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Net Yield',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '${fundDetails?.totalNetYeild?.netYeild ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: CustomTooltipForDetail(
                  popupData: fundDetails?.totalNetYeild?.statement
                          .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                              "${e.amount.round()}"))
                          .toList() ??
                      [],
                  message: '',
                  key: _toolTipKey3,
                  child: Icon(
                    Icons.info_outline,
                    color: ColorsUtil.lighterGrey,
                  ),
                ),
              ),
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Live loans',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '${fundDetails?.liveLoans ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // trailing: CustomTooltipForDetail(
                //   popupData: fundDetails?.totalIncome?.statement
                //           .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                //               "${e.amount.round()}"))
                //           .toList() ??
                //       [],
                //   message: '',
                //   key: _toolTipKey2,
                //   child: Icon(
                //     Icons.info_outline,
                //     color: ColorsUtil.lighterGrey,
                //   ),
                // ),
              ),
              ListTile(
                tileColor: ColorsUtil.lightestGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                  side: BorderSide(color: ColorsUtil.lighterGrey),
                ),
                title: Text(
                  'Loans fully collected',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  '${fundDetails?.LoansFullyCompleted ?? " 0"}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // trailing: CustomTooltipForDetail(
                //   popupData: fundDetails?.totalNetYeild?.statement
                //           .map((e) => PopupData(Utils.getFormattedDate(e.tDate),
                //               "${e.amount.round()}"))
                //           .toList() ??
                //       [],
                //   message: '',
                //   key: _toolTipKey3,
                //   child: Icon(
                //     Icons.info_outline,
                //     color: ColorsUtil.lighterGrey,
                //   ),
                // ),
              )
            ],
          ),
        ),

        Container(
          width: 204,
          padding: EdgeInsets.all(15),
          height: 209,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: ColorsUtil.white,
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: CustomFonts.nunito,
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.white),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    '₹${fundDetails?.totalAvailableBalance?.availableBalance.commaAddedValue() ?? " 0"}',
                    style: TextStyle(
                      color: ColorsUtil.white,
                      fontSize: 20.0,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 28,
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed(RoutesName.NewFundTransferScreen);
                    },
                    child: Container(
                        width: 125,
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: ColorsUtil.greenText,
                            ),
                            Text(
                              'Add',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsUtil.greenText),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            border: Border.all(color: ColorsUtil.lighterGrey),
                            color: ColorsUtil.white)),
                  ),
                ],
              ),
            ],
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: ColorsUtil.lighterGrey),
              color: ColorsUtil.greenText),
        ),
        SizedBox(
          width: 10,
        ),

        // Expanded(
        //   flex: 2,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //           Column(
        //             children: [
        //               Container(
        //                 padding: EdgeInsets.all(20),
        //                 height: 97,
        //                 width: MediaQuery.of(context).size.width / 4.5,
        //                 child: SingleChildScrollView(
        //                   padding: EdgeInsets.all(0),
        //                   scrollDirection: Axis.horizontal,
        //                   child: SingleChildScrollView(
        //                     padding: EdgeInsets.all(0),
        //                     scrollDirection: Axis.vertical,
        //                     child: ConstrainedBox(
        //                       constraints: BoxConstraints(
        //                         maxWidth: MediaQuery.of(context).size.width / 4.1,
        //                       ),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Column(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             children: [
        //                               Text(
        //                                 'Total Funds Transferred',
        //                                 style: TextStyle(
        //                                   fontSize: 16.0,
        //                                   fontFamily: CustomFonts.nunito,
        //                                   fontWeight: FontWeight.w400,
        //                                 ),
        //                               ),
        //                               SizedBox(
        //                                 height: 4,
        //                               ),
        //                               Text(
        //                                 '₹${fundDetails?.totalFundsTransferred?.transactionAmount.commaAddedValue() ?? " 0"}',
        //                                 overflow: TextOverflow.ellipsis,
        //                                 style: TextStyle(
        //                                   fontSize: 20.0,
        //                                   fontFamily: CustomFonts.nunito,
        //                                   fontWeight: FontWeight.w800,
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Padding(
        //                             padding: EdgeInsets.only(
        //                               bottom: 40,
        //                             ),
        //                             child: CustomTooltipForDetail(
        //                               popupData: [
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                               ],
        //                               message:
        //                                   'Date : 12 Aug 2021\nAmount : ₹ 12,580.34',
        //                               key: _toolTipKey,
        //                               child: Icon(
        //                                 Icons.info_outline,
        //                                 color: ColorsUtil.lighterGrey,
        //                               ),
        //                             ),
        //                           ),
        //                           Container()
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     border: Border.all(color: ColorsUtil.lighterGrey),
        //                     color: ColorsUtil.lightestGrey),
        //               ),
        //               SizedBox(
        //                 height: 10,
        //               ),
        //               Container(
        //                 width: MediaQuery.of(context).size.width / 4.5,
        //                 padding: EdgeInsets.all(20),
        //                 height: 97,
        //                 child: SingleChildScrollView(
        //                   padding: EdgeInsets.all(0),
        //                   scrollDirection: Axis.horizontal,
        //                   child: SingleChildScrollView(
        //                       padding: EdgeInsets.all(0),
        //                       scrollDirection: Axis.vertical,
        //                       child: ConstrainedBox(
        //                         constraints: BoxConstraints(
        //                           maxWidth:
        //                               MediaQuery.of(context).size.width / 4.1,
        //                         ),
        //                         child: Row(
        //                           mainAxisAlignment:
        //                               MainAxisAlignment.spaceBetween,
        //                           children: [
        //                             Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               mainAxisAlignment: MainAxisAlignment.center,
        //                               children: [
        //                                 Text(
        //                                   'Total Funds Withdrawn',
        //                                   style: TextStyle(
        //                                     fontSize: 16.0,
        //                                     fontFamily: CustomFonts.nunito,
        //                                     fontWeight: FontWeight.w400,
        //                                   ),
        //                                 ),
        //                                 SizedBox(
        //                                   height: 4,
        //                                 ),
        //                                 Text(
        //                                   '₹${fundDetails?.totalFundsWithdrawn?.transactionAmount.commaAddedValue() ?? " 0"}',
        //                                   style: TextStyle(
        //                                     fontSize: 20.0,
        //                                     fontFamily: CustomFonts.nunito,
        //                                     fontWeight: FontWeight.w800,
        //                                   ),
        //                                 ),
        //                               ],
        //                             ),
        //                             Padding(
        //                               padding: EdgeInsets.only(
        //                                 bottom: 40,
        //                               ),
        //                               child: CustomTooltipForDetail(
        //                                 popupData: [
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 ],
        //                                 message:
        //                                     'Date : 12 Aug 2021\nAmount : ₹ 12,580.34',
        //                                 key: _toolTipKey1,
        //                                 child: Icon(
        //                                   Icons.info_outline,
        //                                   color: ColorsUtil.lighterGrey,
        //                                 ),
        //                               ),
        //                             ),
        //                             Container()
        //                           ],
        //                         ),
        //                       )),
        //                 ),
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     border: Border.all(color: ColorsUtil.lighterGrey),
        //                     color: ColorsUtil.lightestGrey),
        //               )
        //             ],
        //           ),
        //           SizedBox(
        //             width: 10,
        //           ),
        //           Column(
        //             children: [
        //               Container(
        //                 width: MediaQuery.of(context).size.width / 4.5,
        //                 padding: EdgeInsets.all(20),
        //                 height: 97,
        //                 child: SingleChildScrollView(
        //                   scrollDirection: Axis.horizontal,
        //                   padding: EdgeInsets.all(0),
        //                   child: SingleChildScrollView(
        //                     scrollDirection: Axis.vertical,
        //                     padding: EdgeInsets.all(0),
        //                     child: ConstrainedBox(
        //                       constraints: BoxConstraints(
        //                         maxWidth: MediaQuery.of(context).size.width / 4.2,
        //                       ),
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Column(
        //                             crossAxisAlignment: CrossAxisAlignment.start,
        //                             mainAxisAlignment: MainAxisAlignment.center,
        //                             children: [
        //                               Text(
        //                                 'Income Since Inception',
        //                                 style: TextStyle(
        //                                   fontSize: 16.0,
        //                                   fontFamily: CustomFonts.nunito,
        //                                   fontWeight: FontWeight.w400,
        //                                 ),
        //                               ),
        //                               SizedBox(
        //                                 height: 4,
        //                               ),
        //                               Text(
        //                                 '₹${fundDetails?.totalIncome?.income?.commaAddedValue() ?? " 0"}',
        //                                 style: TextStyle(
        //                                   fontSize: 20.0,
        //                                   fontFamily: CustomFonts.nunito,
        //                                   fontWeight: FontWeight.w800,
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Padding(
        //                             padding: EdgeInsets.only(
        //                               bottom: 40,
        //                             ),
        //                             child: CustomTooltipForDetail(
        //                               popupData: [
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 PopupData("20/12/2020", "₹ 12,580.34"),
        //                               ],
        //                               message:
        //                                   'Date : 12 Aug 2021\nAmount : ₹ 12,580.34',
        //                               key: _toolTipKey2,
        //                               child: Icon(
        //                                 Icons.info_outline,
        //                                 color: ColorsUtil.lighterGrey,
        //                               ),
        //                             ),
        //                           ),
        //                           Container()
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     border: Border.all(color: ColorsUtil.lighterGrey),
        //                     color: ColorsUtil.lightestGrey),
        //               ),
        //               SizedBox(
        //                 height: 10,
        //               ),
        //               Container(
        //                 width: MediaQuery.of(context).size.width / 4.5,
        //                 padding: EdgeInsets.all(20),
        //                 height: 97,
        //                 child: SingleChildScrollView(
        //                   scrollDirection: Axis.horizontal,
        //                   padding: EdgeInsets.all(0),
        //                   child: SingleChildScrollView(
        //                       scrollDirection: Axis.vertical,
        //                       padding: EdgeInsets.all(0),
        //                       child: ConstrainedBox(
        //                         constraints: BoxConstraints(
        //                           maxWidth:
        //                               MediaQuery.of(context).size.width / 5.5,
        //                         ),
        //                         child: Row(
        //                           mainAxisAlignment:
        //                               MainAxisAlignment.spaceBetween,
        //                           children: [
        //                             Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               mainAxisAlignment: MainAxisAlignment.center,
        //                               children: [
        //                                 Text(
        //                                   'Net Yield',
        //                                   style: TextStyle(
        //                                     fontSize: 16.0,
        //                                     fontFamily: CustomFonts.nunito,
        //                                     fontWeight: FontWeight.w400,
        //                                   ),
        //                                 ),
        //                                 SizedBox(
        //                                   height: 4,
        //                                 ),
        //                                 Text(
        //                                   '${fundDetails?.totalNetYeild?.netYeild ?? " 0"}',
        //                                   style: TextStyle(
        //                                     fontSize: 20.0,
        //                                     fontFamily: CustomFonts.nunito,
        //                                     fontWeight: FontWeight.w800,
        //                                   ),
        //                                 ),
        //                               ],
        //                             ),
        //                             Padding(
        //                               padding: EdgeInsets.only(
        //                                 bottom: 40,
        //                               ),
        //                               child: CustomTooltipForDetail(
        //                                 popupData: [
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                   PopupData("20/12/2020", "₹ 12,580.34"),
        //                                 ],
        //                                 message:
        //                                     'Date : 12 Aug 2021\nAmount : ₹ 12,580.34',
        //                                 key: _toolTipKey3,
        //                                 child: Icon(
        //                                   Icons.info_outline,
        //                                   color: ColorsUtil.lighterGrey,
        //                                 ),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       )),
        //                 ),
        //                 decoration: BoxDecoration(
        //                     borderRadius: BorderRadius.circular(7.0),
        //                     border: Border.all(color: ColorsUtil.lighterGrey),
        //                     color: ColorsUtil.lightestGrey),
        //               )
        //             ],
        //           ),
        //         ],
        //       ),
        //       SizedBox(
        //         width: 15,
        //       ),
        //       Container(
        //         width: 204,
        //         padding: EdgeInsets.all(15),
        //         height: 209,
        //         child: Column(
        //           children: [
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.end,
        //               children: [
        //                 Icon(
        //                   Icons.info_outline_rounded,
        //                   color: ColorsUtil.white,
        //                 )
        //               ],
        //             ),
        //             SizedBox(
        //               height: 20,
        //             ),
        //             Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               crossAxisAlignment: CrossAxisAlignment.center,
        //               children: [
        //                 Text(
        //                   'Available Balance',
        //                   style: TextStyle(
        //                       fontSize: 16.0,
        //                       fontFamily: CustomFonts.nunito,
        //                       fontWeight: FontWeight.w400,
        //                       color: ColorsUtil.white),
        //                 ),
        //                 SizedBox(
        //                   height: 8,
        //                 ),
        //                 Text(
        //                   '₹${fundDetails?.totalAvailableBalance?.availableBalance.commaAddedValue() ?? " 0"}',
        //                   style: TextStyle(
        //                     color: ColorsUtil.white,
        //                     fontSize: 20.0,
        //                     fontFamily: CustomFonts.nunito,
        //                     fontWeight: FontWeight.w800,
        //                   ),
        //                 ),
        //                 SizedBox(
        //                   height: 28,
        //                 ),
        //                 Container(
        //                     width: 125,
        //                     height: 44,
        //                     child: Row(
        //                       mainAxisAlignment: MainAxisAlignment.center,
        //                       children: [
        //                         Icon(
        //                           Icons.add,
        //                           color: ColorsUtil.greenText,
        //                         ),
        //                         Text(
        //                           'Add',
        //                           style: TextStyle(
        //                               fontSize: 18.0,
        //                               fontFamily: CustomFonts.nunito,
        //                               fontWeight: FontWeight.w700,
        //                               color: ColorsUtil.greenText),
        //                         ),
        //                       ],
        //                     ),
        //                     decoration: BoxDecoration(
        //                         borderRadius: BorderRadius.circular(7.0),
        //                         border: Border.all(color: ColorsUtil.lighterGrey),
        //                         color: ColorsUtil.white)),
        //               ],
        //             ),
        //           ],
        //         ),
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(7.0),
        //             border: Border.all(color: ColorsUtil.lighterGrey),
        //             color: ColorsUtil.greenText),
        //       ),
        //       SizedBox(
        //         width: 30,
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }
}

class MobileViewDetailWidget extends StatelessWidget {
  bool? isExpended;
  MobileViewDetailWidget({
    Key? key,
    this.isExpended = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    var userDetails = provider.userDetails!;
    var fundDetails = provider.userFundTransferDetails;
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        textColor: Colors.black,
        iconColor: ColorsUtil.dividerColor,
        initiallyExpanded: isExpended ?? false,
        title: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LogoWidget(
            size: 42,
            url: userDetails.profileDetails!.profileUrl,
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                child: Text(
                  userDetails.profileDetails!.fullName,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                child: Text(
                  userDetails.profileDetails!.email,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w400,
                      color: ColorsUtil.lighterGrey),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(RoutesName.ProfileDetail);
                },
                child: Row(
                  children: [
                    Text(
                      'Profile ${provider.getProfilePercentage()}% complete',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: CustomFonts.nunito,
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.greenText,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: ColorsUtil.greenText,
                      size: 21,
                    )
                  ],
                ),
              ),
            ]),
          ),
          SizedBox(
            width: 1.0,
          ),
        ]),
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            children: [
              OutlinePopupContainer(
                title: 'Total Funds Transferred',
                subtitle:
                    '₹${fundDetails?.totalFundsTransferred?.transactionAmount.commaAddedValue() ?? " 0"}',
                statement: fundDetails?.totalFundsTransferred?.statement ?? [],
              ),
              OutlinePopupContainer(
                title: 'Income Since Inception',
                subtitle:
                    '₹${fundDetails?.totalIncome?.income.commaAddedValue() ?? " 0"}',
                statement: fundDetails?.totalIncome?.statement ?? [],
              ),
              OutlinePopupContainer(
                title: 'Total Funds Withdrawn',
                subtitle:
                    '₹${fundDetails?.totalFundsWithdrawn?.transactionAmount.commaAddedValue() ?? " 0"}',
                statement: fundDetails?.totalFundsWithdrawn?.statement ?? [],
              ),
              OutlinePopupContainer(
                title: 'Net Yield',
                subtitle: '${fundDetails?.totalNetYeild?.netYeild ?? " 0"}',
              ),
              OutlinePopupContainer(
                title: 'Live loans',
                description: 'Higher diversification is better',
                subtitle: '${fundDetails?.liveLoans ?? " 0"}',
              ),
              OutlinePopupContainer(
                title: 'Loans fully collected',
                description: 'Loans closed ',
                subtitle: '${fundDetails?.LoansFullyCompleted ?? " 0"}',
              ),
            ],
            childAspectRatio: 2.2 / 1,
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 2.28,
            padding: EdgeInsets.only(left: 15, right: 10),
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.white),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '₹${fundDetails?.totalAvailableBalance?.availableBalance.commaAddedValue() ?? " 0"}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ColorsUtil.white,
                        fontSize: 20.0,
                        fontFamily: CustomFonts.nunito,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                    padding: EdgeInsets.only(left: 10, right: 16),
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        context.pushNamed(RoutesName.NewFundTransferScreen);
                      },
                      label: Text(
                        'Add',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w700,
                            color: ColorsUtil.greenText),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: ColorsUtil.greenText,
                      ),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7.0),
                        border: Border.all(color: ColorsUtil.lighterGrey),
                        color: ColorsUtil.white))
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                border: Border.all(color: ColorsUtil.lighterGrey),
                color: ColorsUtil.greenText),
          ),
        ],
      ),
    );
  }
}
