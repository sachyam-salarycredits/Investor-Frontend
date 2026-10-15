import 'dart:async';
import 'dart:io';

import 'package:peerbridge/modules/home/screens/home_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/first_deposit_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/whats_next_screen.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';

import 'package:peerbridge/widgets/header.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    getCustomerDetail();
  }

  Future<void> getCustomerDetail() async {
    await context.read<AppStateProvider>().getCustomerDetails();
    Future.delayed(Duration(seconds: 2), () async{
      var pref = await SharedPreferences.getInstance();
      var getRegistrationStatus = await pref.getBool('set_registrationStatus') ?? true;
      if (getRegistrationStatus) {
        print('fromWelcome');
        Navigator.push(context, MaterialPageRoute(builder: (context) => FirstDepositScreen(fromOtp: false)));
      } else {
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context)
  {
    // return helpPanelPopupDialog(context);
    final bankDetail = context.read<AppStateProvider>().userBankDetail;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Header(
                backOnPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    // color: ColorsUtil.redColor,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: SpinKitRing(
                              duration: Duration(milliseconds: 1200),
                              color: ColorsUtil.blueColor,
                              size: 60.0,
                            ),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Welcome to PeerBridge',
                            maxLines: 1,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.black,
                                fontSize: 20),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Start earning 13% p.a.',
                            maxLines: 1,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.black,
                                fontSize: 16),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Container(
                            height: 49,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 223,
                            decoration: BoxDecoration(
                                color: ColorsUtil.welcomeScreenContainer,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SizedBox(
                                //   width: 10.0,
                                // ),
                                Image(
                                  image:
                                      AssetImage(LocalImages.green_sheild_tick),
                                  width: 22,
                                  height: 26.5,
                                  color: ColorsUtil.blueColor,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'Ac - ${bankDetail?.acountNumber ?? ''}',
                                  maxLines: 1,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      color: ColorsUtil.blueColor,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                focusColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        helpPanelPopupDialog(context),
                  );
                },
                child: Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 133,
                  decoration: BoxDecoration(
                      color: ColorsUtil.lightestGrey,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   width: 10.0,
                      // ),

                      Text(
                        'Get help',
                        maxLines: 1,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.lightGrey,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(Icons.keyboard_arrow_up)
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   child: Container(
              //     margin: EdgeInsets.fromLTRB(15, 60, 15, 0),
              //     child: Container(
              //       child: Column(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Spacer(),
              //           Center(
              //             child: SpinKitRing(
              //               duration: Duration(milliseconds: 1200),
              //               color: ColorsUtil.greenColor,
              //               size: 60.0,
              //             ),
              //           ),
              //           SizedBox(
              //             height: 30.0,
              //           ),
              //           Text(
              //             'Welcome to PeerBridge',
              //             maxLines: 1,
              //             softWrap: true,
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //                 fontFamily: CustomFonts.roboto,
              //                 color: ColorsUtil.black,
              //                 fontSize: 20),
              //           ),
              //           SizedBox(
              //             height: 10.0,
              //           ),
              //           Text(
              //             'Start earning 13% p.a.',
              //             maxLines: 1,
              //             softWrap: true,
              //             textAlign: TextAlign.center,
              //             style: TextStyle(
              //                 fontFamily: CustomFonts.roboto,
              //                 color: ColorsUtil.black,
              //                 fontSize: 16),
              //           ),
              //           SizedBox(
              //             height: 20.0,
              //           ),
              //           Container(
              //             height: 49,
              //             margin: EdgeInsets.symmetric(horizontal: 4),
              //             width: 223,
              //             decoration: BoxDecoration(
              //                 color: ColorsUtil.lightestGrey,
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(20))),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 // SizedBox(
              //                 //   width: 10.0,
              //                 // ),
              //                 Image(
              //                   image: AssetImage(LocalImages.green_sheild_tick),
              //                   width: 22,
              //                   height: 26.5,
              //                 ),
              //                 SizedBox(
              //                   width: 10.0,
              //                 ),
              //                 Text(
              //                   'Ac - 805744142154',
              //                   maxLines: 1,
              //                   softWrap: true,
              //                   textAlign: TextAlign.center,
              //                   style: TextStyle(
              //                       fontFamily: CustomFonts.roboto,
              //                       color: ColorsUtil.greenColor,
              //                       fontSize: 16),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           Spacer(),
              //           InkWell(
              //             focusColor: Colors.transparent,
              //             splashColor: Colors.transparent,
              //             highlightColor: Colors.transparent,
              //             hoverColor: Colors.transparent,
              //             onTap: () {
              //               showDialog(
              //                 context: context,
              //                 builder: (BuildContext context) =>
              //                     helpPanelPopupDialog(context),
              //               );
              //             },
              //             child: Container(
              //               height: 40,
              //               margin: EdgeInsets.symmetric(horizontal: 4),
              //               width: 133,
              //               decoration: BoxDecoration(
              //                   color: ColorsUtil.lightestGrey,
              //                   borderRadius:
              //                       BorderRadius.all(Radius.circular(15))),
              //               child: Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   // SizedBox(
              //                   //   width: 10.0,
              //                   // ),
              //
              //                   Text(
              //                     'Get help',
              //                     maxLines: 1,
              //                     softWrap: true,
              //                     textAlign: TextAlign.center,
              //                     style: TextStyle(
              //                         fontFamily: CustomFonts.roboto,
              //                         color: ColorsUtil.lightGrey,
              //                         fontWeight: FontWeight.w500,
              //                         fontSize: 16),
              //                   ),
              //                   SizedBox(
              //                     width: 10.0,
              //                   ),
              //                   Icon(Icons.keyboard_arrow_up)
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget helpPanelPopupDialog(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Dialog(
        insetPadding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
        // title: Container(
        //   // padding: EdgeInsets.only(top: 20, left: 40, right: 20.0),
        //   height: MediaQuery.of(context).size.height * .58,
        //   width: MediaQuery.of(context).size.height * .48,
        //   constraints: BoxConstraints(minWidth: 370),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Help with Fund Transfer',
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: CustomFonts.nunito,
                      fontSize: 22.0,
                      fontWeight: FontWeight.w700),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      size: 30.0,
                    )),
              ],
            ),

            //no of headers
            buildSingleExpansion("How does PeerBridge work?",
                "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),
            buildSingleExpansion(
                "Why is it safe to lend or borrow money online at PeerBridge's marketplace?",
                "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),
            buildSingleExpansion(
                "is my personal/financial information safe with PeerBridge?",
                "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),

            SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 1.0,
              height: 1.0,
              color: ColorsUtil.lighterGrey,
            ),
            SizedBox(
              height: 10.0,
            ),
            Center(
              child:
              RichText(
                text: TextSpan(
                  text:
                      "Can’t find what you’re looking for?\nGive us a call at : ",
                  style: TextStyle(
                    color: ColorsUtil.lightGrey,
                    fontWeight: FontWeight.w700,
                    fontFamily: CustomFonts.nunito,
                    fontSize: 15.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: Constants.callSupportNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.blueColor,
                        fontFamily: CustomFonts.nunito,
                        fontSize: 15.0,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          launch('tel://${Constants.callSupportNumber}');
                        },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSingleExpansion(String heading, String body) {
    return ExpansionTile(
      tilePadding: EdgeInsets.all(0),
      trailing: Icon(
        Icons.check,
        size: 0.0,
        color: ColorsUtil.white,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(
          top: 5.5,
        ),
        child: Icon(
          Icons.arrow_forward_ios_outlined,
          color: ColorsUtil.arrowColor,
          size: 14.0,
        ),
      ),
      textColor: Colors.black54,
      collapsedIconColor: ColorsUtil.white,
      iconColor: Colors.white,
      title: Text(
        heading,
        style: TextStyle(
            color: Colors.black,
            fontFamily: CustomFonts.nunito,
            fontSize: 18.0,
            fontWeight: FontWeight.w700),
      ),
      children: [
        VerticalDivider(
          thickness: 5.0,
          color: Colors.black,
          width: 2.0,
        ),
        Padding(
            padding: const EdgeInsets.only(
                top: 4.0, bottom: 4.0, left: 25.0, right: 25.0),
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Image.asset(LocalImages.line),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          body,
                          maxLines: 7,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w400,
                            color: ColorsUtil.lighterGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ))),
      ],
    );
  }
}
