import 'dart:math';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'package:peerbridge/utils/extensions.dart';

import '../../../supporting_file/appsFlyerSdk.dart';
import '../../home/screens/home_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  bool isLoading = false;
  double availableAmount = 0.0;
  String amountError = "";
  bool isAmountValid = false;
  bool isAmountError = false;
  var amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getFunfDetails();
    // setLoader(true);
    //
    // context.read<AppStateProvider>().getUserFundDetails();
    // final fundDetails =
    //     context.read<AppStateProvider>().userFundTransferDetails;
    //
    // print(
    //     'fund details====${fundDetails?.totalAvailableBalance?.availableBalance}');
    // availableAmount =
    //     ((fundDetails?.totalAvailableBalance?.availableBalance) ?? 0.0);
    // availableAmount = availableAmount != 0.0
    //     ? (fundDetails?.totalAvailableBalance?.availableBalance ?? 0.0) - 0.01
    //     : 0.0;
    //
    // print(availableAmount);
    //
    // setLoader(false);
  }

  void getFunfDetails() async {
    setLoader(true);

    await context.read<AppStateProvider>().getUserFundDetails();
    final fundDetails =
        context.read<AppStateProvider>().userFundTransferDetails;

    print(
        'fund details====${fundDetails?.withdrawableBalance ?? fundDetails?.totalAvailableBalance?.availableBalance}');
    availableAmount =
        ((fundDetails?.withdrawableBalance ??
                fundDetails?.totalAvailableBalance?.availableBalance) ??
            0.0);

    print(availableAmount);

    setLoader(false);
  }

  bool checkAmountValidation() {
    if (amountController.text.doubleValue() == 0) {
      setState(() {
        isAmountValid = false;
        isAmountError = false;
      });
    }

    if (amountController.text.doubleValue() > 0 &&
        amountController.text.doubleValue() <= availableAmount) {
      setState(() {
        isAmountValid = true;
      });
    } else {
      setState(() {
        // Utils.showToast(msg: 'Please enter a valid amount',);

        isAmountValid = false;
      });
    }

    if (amountController.text.doubleValue() > availableAmount) {
      setState(() {
        // Utils.showToast(msg: 'Your current withdrawable balance is zero',);
        // amountError =
        //     "You can only withdraw upto your available balance, Please enter revise amount";
        isAmountError = true;
      });
      return false;
    }

    setState(() {
      amountError = "";
    });

    return true;
  }

  setLoader(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> withdrawAmountTap() async {
    var param = Map<String, String>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.amount] = amountController.text;

    setLoader(true);
    var status = await context.read<AppStateProvider>().withdrawAmount(param);
    setLoader(false);
    if (status) {
      var value = Map<String, dynamic>();
      value["af_revenue"] = amountController.text;
      value["af_currency"] = "INR";
      // AFSdk.logEvent(AFSdk.af_withdrawal, value);
      Utils.showAlert(
          context: context,
          msg:
              "Withdrawal initiated. Funds will be credited to your bank account shortly.",
          onTap: () {
            context.pop();
          });
    }
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification() async {
    if (checkAmountValidation()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OtpVerificationWidget(
          // mobileNumber: "9119389854",
          onFailed: () {},
          onVerified: () {
            withdrawAmountTap();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final provider = Provider.of<AppStateProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorsUtil.white,
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Withdraw Funds',
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
        body: PeerBridgeLoader(
          isLoading: isLoading,
          child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          child: RichText(
                            text: TextSpan(
                              text: "Available Balance : ",
                              style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                // fontWeight: FontWeight.bold,
                                color: ColorsUtil.black,
                                fontSize: 18,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      '₹${availableAmount.commaAddedValue(digit: 2)}',
                                  style: TextStyle(
                                    color: ColorsUtil.blueColorText,
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        mainWidgets(context),
                      ],
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
                                            titleStr: 'Withdraw Funds',
                                            desStr:
                                                'Available Balance : ₹ ${availableAmount.commaAddedValue(digit: 2)}',
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
                    )

              //   ?Container(
              // child:                                           mainWidgets(context),
              //               )
              //   : Row(
              //       children: [
              //         Container(
              //           width: screenSize.width * .56,
              //           color: ColorsUtil.white,
              //           child: Column(
              //             children: [
              //               Header(
              //                 backOnPressed: () {
              //                   context.pop();
              //                 },
              //               ),
              //               SizedBox(height: 50),
              //               Expanded(
              //                 child: Container(
              //                     width: screenSize.width * .4,
              //                     constraints:
              //                     BoxConstraints(maxWidth: 500),
              //
              //                     child: mainWidgets(context)),
              //               )
              //               // Expanded(
              //               //   child: Container(
              //               //     child: Center(
              //               //       child: Container(
              //               //         width: screenSize.width * .4,
              //               //         constraints:
              //               //             BoxConstraints(maxWidth: 500),
              //               //         child: Column(
              //               //           children: [
              //                           TitleHeader(
              //                             titleStr: 'Withdraw Funds',
              //                             desStr:
              //                                 'Available Balance : ₹ ${availableAmount.commaAddedValue(digit: 2)}',
              //                           ),
              //               //             // SizedBox(height: 30),
              //               //             // mainWidgets(context),
              //               //           ],
              //               //         ),
              //               //       ),
              //               //     ),
              //               //   ),
              //               // ),
              //             ],
              //           ),
              //         ),
              //         Container(
              //           width: screenSize.width * .44,
              //           color: ColorsUtil.blueColor,
              //         )
              //       ],
              //     ),
              ),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Expanded(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TitleHeader(
          //   titleStr: 'Withdraw Funds',
          //   desStr:
          //       'Available Balance : ₹${availableAmount.commaAddedValue(digit: 2)}', //100,000',
          // ),

          // Padding(
          //   padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
          //   child: RichText(
          //     text: TextSpan(
          //       text: "Available Balance : ",
          //       style: TextStyle(
          //         fontFamily: CustomFonts.nunito,
          //         // fontWeight: FontWeight.bold,
          //         color: ColorsUtil.black,
          //         fontSize: 18,
          //       ),
          //       children: <TextSpan>[
          //         TextSpan(
          //           text: '₹${availableAmount.commaAddedValue(digit: 2)}',
          //           style: TextStyle(
          //             color: ColorsUtil.blueColorText,
          //             fontFamily: CustomFonts.nunito,
          //             fontSize: 18,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InputWidget(
                      prefixText: '₹ ',
                      leftIcon: Image.asset(LocalImages.rupee_sign),
                      controller: amountController,
                      rightIcon: amountController.text != '' &&
                              (availableAmount == 0.0 ||
                                  amountController.text.doubleValue() >
                                      availableAmount)
                          ? Image.asset(
                              LocalImages.caution_icon,
                              width: 40,
                              height: 23,
                              color: ColorsUtil.redColor,
                            )
                          : Container(),

                      hintStr: "Enter withdrawal amount",
                      heading: "Enter withdrawal amount",

                      // amountController.text == ''
                      //     ? ''
                      //     : "Please enter withdrawal amount",
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      isValid: isAmountValid,
                      isError: isAmountError,
                      alertColor: ColorsUtil.redColor,
                      alertStr: amountError,
                      horizontalMargin: 0,
                      onChange: (String input) {
                        setState(() {
                          checkAmountValidation();
                        });
                      },

                      // amountWidget(),
                      // SizedBox(height: 165),
                      // (availableAmount == 0.0)
                      //     ? Container(
                      //         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      //         child: Text(
                      //           'Your current withdrawal balance is zero',
                      //           style: TextStyle(
                      //               fontFamily: CustomFonts.nunito,
                      //               fontSize: 12,
                      //               color: ColorsUtil.redColor),
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: ColorsUtil.redColor.withOpacity(.2),
                      //           borderRadius: BorderRadius.circular(10),
                      //         ),
                      //       )
                      //     : Container(),
                      // SizedBox(height: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          amountController.text != '' && (availableAmount == 0.0)
              ? Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Text(
                      'Your current withdrawal balance is zero',
                      style: TextStyle(
                          fontFamily: CustomFonts.nunito,
                          fontSize: 12,
                          color: ColorsUtil.white),
                    ),
                    decoration: BoxDecoration(
                      color: ColorsUtil.toastRedColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
              : amountController.text != '' &&
                      amountController.text.doubleValue() > availableAmount
                  ? Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        child: Text(
                          'Please enter a valid amount',
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 12,
                              color: ColorsUtil.white),
                        ),
                        decoration: BoxDecoration(
                          color: ColorsUtil.toastRedColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  : Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
            child: CustomButton(
                isDisable: availableAmount == 0.0 ||
                    amountController.text.doubleValue() > availableAmount ||
                    amountController.text.doubleValue() <= 0,
                horizontalMargin: 0,
                titleStr: 'Withdraw',
                // onPress: startOtpVerification,
                onPress: () {
                  amountController.text == ''
                      ? setState(() {
                          amountError = 'Please enter some amount';
                        })
                      : showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            // <-- SEE HERE
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15.0),
                            ),
                          ),
                          builder: (BuildContext context) =>
                              WithdrawPopupDialog(
                                  context, amountController.text),
                        );
                }),
          ),
        ],
      ),
    );
  }

  Widget WithdrawPopupDialog(BuildContext context, String amount) {
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
                                    text: 'in earnings by withdrawing now',
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
                        titleStr: 'Withdraw later',
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
