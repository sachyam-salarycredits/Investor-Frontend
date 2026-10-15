import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/marketplace/models/redemption_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/redemption_slider.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import '../../../supporting_file/appsFlyerSdk.dart';
import 'dart:math';

import '../../home/screens/home_screen.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  _RedemptionScreenState createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen> {
  double min = 0;
  double max = 10;
  var label = ['1 Loan', '10 Loan'];
  bool isChecked = false;
  double sliderValue = 0;
  RedemptionData? redemptionData;
  bool isLoader = false;
  double totalAmount = 0.0;
  TextEditingController totalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRedemptionData();
    });
  }

  setLoader(bool value) {
    setState(() {
      isLoader = value;
    });
  }

  getRedemptionData() async {
    setLoader(true);
    redemptionData = await context.read<AppStateProvider>().getRedemptionData();
    setLoader(false);

    if (redemptionData != null) {
      final loanList = redemptionData!.loanList;
      if (loanList.isNotEmpty) {
        max = redemptionData!.loanList.length.toDouble();
        label = ['${min.toInt()} Loan', '${max.toInt()} Loan'];
        sliderValue = ((min + max) / 2).floor().toDouble();
        calAmount();
      } else {
        Utils.showAlert(
            context: context,
            msg: LanguageHelper.textNoLoans,
            onTap: () {
              context.pop();
            });
        //no loans for redemption
      }
    }
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationWidget(
        // mobileNumber: "9119389854",
        onFailed: () {},
        onVerified: () {
          submitRedemptionData();
        },
      ),
    );
  }

  void submitRedemptionData() async {
    var ip = await Utils.getIpAddress();

    var loanList =
        redemptionData!.loanList.sublist(0, sliderValue.toInt()).map((e) {
      e.ip = ip;
      return e;
    }).toList();
    if (loanList.length > 20) {
      Utils.showAlert(
          context: context,
          msg: LanguageHelper.redeemMaxLoan,
          onTap: () {
            context.pop();
          });
      return;
    }
    setLoader(true);
    var result =
        await context.read<AppStateProvider>().submitRedemption(loanList);
    setLoader(false);
    if (result) {
      AFSdk.logEvent(AFSdk.af_redemption, null);
      await Future.delayed(Duration(seconds: 1));
      context.pop();
    }
  }

  calAmount() {
    totalAmount = 0.0;
    redemptionData!.loanList.sublist(0, sliderValue.toInt()).forEach((element) {
      totalAmount += element.totalAmount;
    });

    totalAmountController.text = "Total Amount: Rs ${totalAmount.toInt()}";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          appBar: ResponsiveWidget.isSmallScreen(context)
              ? AppBar(
                  title: Text(
                    'Redemption',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  toolbarHeight: 70,
                  backgroundColor: ColorsUtil.blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  leading: BackButton(
                    onPressed: () {
                      context.pop();
                    },
                  ),
                )
              : null,
          // floatingActionButton: FloatingActionButton(
          //   onPressed: (){
          //     getRedemptionData();
          //   },
          // ),
          body: PeerBridgeLoader(
            isLoading: isLoader,
            child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Container(
                      color: ColorsUtil.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Text(
                              'Number of Loans to Redeem',
                              style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          mainWidgets(context),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Container(
                          width: screenSize.width * .56,
                          color: ColorsUtil.white,
                          child: Column(
                            children: [
                              Header(
                                backOnPressed: () {
                                  context.pop();
                                },
                              ),
                              SizedBox(height: 50),
                              Expanded(
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      width: screenSize.width * .4,
                                      constraints:
                                          BoxConstraints(maxWidth: 500),
                                      child: Column(
                                        children: [
                                          TitleHeader(
                                            titleStr: 'Redemption',
                                            desStr: 'Number of Loans to Redeem',
                                          ),
                                          SizedBox(height: 30),
                                          mainWidgets(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenSize.width * .44,
                          color: ColorsUtil.blueColor,
                        )
                      ],
                    ),

              // Column(
              //   children: [
              //     Header(
              //       backOnPressed: () {
              //         context.pop();
              //       },
              //     ),
              //     // TitleHeader(
              //     //   titleStr: 'Redemption',
              //     //   desStr: 'Number of Loans to Redeem',
              //     // ),
              //     // SizedBox(height: 30),
              //     Expanded(
              //       child: ListView(
              //         physics: const NeverScrollableScrollPhysics(),
              //         children: [
              //           Center(
              //             child: Container(
              //                 constraints: BoxConstraints(
              //                     maxWidth:
              //                         ResponsiveWidget.isSmallScreen(context)
              //                             ? screenSize.width
              //                             : 450),
              //                 margin: EdgeInsets.only(top: 18, bottom: 18),
              //                 child: Card(
              //                   color: ResponsiveWidget.isSmallScreen(context)
              //                       ? Colors.transparent
              //                       : null,
              //                   elevation: ResponsiveWidget.isSmallScreen(context)
              //                       ? 0
              //                       : 3,
              //                   child: Container(
              //                       margin:
              //                           ResponsiveWidget.isSmallScreen(context)
              //                               ? EdgeInsets.all(0)
              //                               : EdgeInsets.all(30),
              //                       child: Align(
              //                         alignment: Alignment.topRight,
              //                         child: ListView(
              //                           shrinkWrap: true,
              //                           physics:
              //                               const NeverScrollableScrollPhysics(),
              //                           children: [
              //                             TitleHeader(
              //                               titleStr: 'Redemption',
              //                               desStr: 'Number of Loans to Redeem',
              //                             ),
              //                             SizedBox(height: 40),
              //                             mainWidgets(context)
              //                           ],
              //                         ),
              //                       )),
              //                 )),
              //           ),
              //         ],
              //       ),
              //     ),
              //     // Expanded(
              //     //   child: SingleChildScrollView(
              //     //     child: mainWidgets(context),
              //     //   ),
              //     // ),
              //   ],
              // ),
            ),
          ),
        ));
  }

  Widget mainWidgets(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: label
                            .map((e) => Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                              fontFamily: CustomFonts.nunito,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ))
                            .toList()),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      inactiveTrackColor: ColorsUtil.greyTabColor,
                      activeTrackColor: ColorsUtil.blueColor,
                      overlayColor: Colors.transparent,
                      thumbColor: ColorsUtil.thumbSliderColor,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                      valueIndicatorColor: ColorsUtil.circleGrey,
                      valueIndicatorTextStyle: TextStyle(
                        color: ColorsUtil.greenText,
                        fontFamily: CustomFonts.nunito,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      showValueIndicator: ShowValueIndicator.always,
                      thumbShape: const ThumbShape(),
                    ),
                    child: Slider(
                        value: sliderValue,
                        min: 0,
                        max: max,
                        divisions: max.toInt(),
                        label: sliderValue.round().toString(),
                        onChanged: (value) {
                          this.sliderValue = value;
                          calAmount();
                        }),
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    hintStr: "Total Amount : Rs. 0.10 Lakhs",
                    heading: 'Amount',
                    isEditable: false,
                    controller: totalAmountController,
                  ),
                  SizedBox(height: 35),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CustomButton(
                isDisable: totalAmount == 0,
                // isDisable: false,
                titleStr: 'Submit',
                onPress: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      // <-- SEE HERE
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15.0),
                      ),
                    ),
                    builder: (BuildContext context) =>
                        RedemptionPopupDialog(
                            context, totalAmount.toString()),
                  );
                  // startOtpVerification();
                },
              ),
              SizedBox(
                height: 25,
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget RedemptionPopupDialog(BuildContext context, String amount) {
    var screenSize = MediaQuery.of(context).size;
    var amountEarned = double.parse(amount) * pow((1 + (13 / 100)), 5);
    var compoundInterest = amountEarned - double.parse(amount);
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
            topLeft: Radius.circular(40.0),
            bottomLeft: Radius.circular(40.0)),
      ),
      child: Container(
        child: Container(
          //290,
          width: ResponsiveWidget.isSmallScreen(context)
              ? screenSize.width * .8
              : screenSize.width * .35, //320,//
          // height: 800,
          // width: 320,
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                text:
                                '${context.read<AppStateProvider>().userDetails?.panDetails?.firstName ?? ''}, you’ll lose  ',
                                style: TextStyle(
                                    color: ColorsUtil.black,
                                    fontFamily: CustomFonts.nunito,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                    '₹${compoundInterest.toStringAsFixed(2)} ',
                                    style: TextStyle(
                                      color: ColorsUtil.redColor,
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 18,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'in earnings by redeeming now',
                                    style: TextStyle(
                                        color: ColorsUtil.black,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image(
                                image: AssetImage(LocalImages.close),
                                width: 15,
                                height: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Stack(
                        children: [
                          Container(
                            width: screenSize.width / 1.4,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Projected Earnings\nwhen invested*',
                                  softWrap: true,
                                  style: TextStyle(
                                      color: ColorsUtil.greyPlaceHolder,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Container(
                                    width: 90,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border:
                                        Border.all(color: ColorsUtil.grey)),
                                    padding: EdgeInsets.all(5),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          '₹${amountEarned.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '${DateFormat('dd MMM yyyy').format(DateTime(DateTime.now().year + 5, DateTime.now().month, DateTime.now().day)).toString()}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Image(
                            image: AssetImage(LocalImages.withdraw_graph),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'if you let your investment continue to compound for another 5 years, you could easily grow your wealth to ₹${amountEarned.toStringAsFixed(2)}',
                        softWrap: true,
                        style: TextStyle(
                            color: ColorsUtil.greyPlaceHolder,
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: CustomButton(
                        borderColor: ColorsUtil.blueColor,
                        titleStr: 'Redeem later',
                        bgColor: ColorsUtil.white,
                        textColor: ColorsUtil.blueColor,
                        onPress: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        },
                      ),
                    ),
                    Flexible(
                      child: CustomButton(
                        borderColor: ColorsUtil.blueColor,
                        titleStr: 'Continue',
                        bgColor: ColorsUtil.blueColor,
                        textColor: ColorsUtil.white,
                        onPress: startOtpVerification,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    //   AlertDialog(
    //   shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(5.0),
    //       side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
    //   title: Container(
    //     //290,
    //     width: ResponsiveWidget.isSmallScreen(context)
    //         ? screenSize.width * .8
    //         : screenSize.width * .35, //320,// height: 290,
    //     // width: 320,
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         SizedBox(
    //           height: 15.0,
    //         ),
    //         Image.asset(
    //           LocalImages.red_alert,
    //           width: 44,
    //           height: 38,
    //         ),
    //         SizedBox(
    //           height: 16.0,
    //         ),
    //         Text(
    //           'Penny Drop process was Unsuccessful!',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //               color: Colors.black,
    //               fontFamily: CustomFonts.nunito,
    //               fontSize: 16.0,
    //               fontWeight: FontWeight.w700),
    //         ),
    //         SizedBox(
    //           height: 10.0,
    //         ),
    //         Text(
    //           '${name},${pennyDropRes.message}',
    //           maxLines: 4,
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //               color: Colors.black,
    //               fontFamily: CustomFonts.nunito,
    //               fontSize: 14.0,
    //               fontWeight: FontWeight.w400,
    //               height: 1.4),
    //         ),
    //         SizedBox(
    //           height: 10.0,
    //         ),
    //         CustomButton(
    //           leftIcon: Icon(
    //             Icons.support_agent,
    //             color: ColorsUtil.blueColor,
    //           ),
    //           //   borderColor: ColorsUtil.greenColor,
    //           titleStr: 'Call Helpline',
    //           bgColor: ColorsUtil.white,
    //           textColor: ColorsUtil.blueColor,
    //           onPress: () {
    //             Utils.launchSupportCall();
    //           },
    //         ),
    //         SizedBox(
    //           height: 10.0,
    //         ),
    //         CustomButton(
    //           borderColor: ColorsUtil.blueColor,
    //           titleStr: 'Dismiss',
    //           bgColor: ColorsUtil.white,
    //           textColor: ColorsUtil.blueColor,
    //           onPress: () {
    //             Navigator.pop(context);
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    //   actions: <Widget>[],
    // );
  }

}
