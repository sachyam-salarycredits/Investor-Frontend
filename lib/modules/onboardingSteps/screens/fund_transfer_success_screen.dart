import 'dart:io';

import 'package:peerbridge/modules/home/screens/home_screen.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_state_provider.dart';
import '../../../routes_management/routes_list.dart';
import '../../../utils/colours_util.dart';
import '../../../utils/fonts.dart';
import '../../../utils/images.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loader.dart';

class FundTransferSuccessScreen extends StatefulWidget {
  String amount;
  String cashFreeText;

  FundTransferSuccessScreen(
      {Key? key, required this.amount, required this.cashFreeText})
      : super(key: key);

  @override
  _FundTransferSuccessScreenState createState() =>
      _FundTransferSuccessScreenState();
}

class _FundTransferSuccessScreenState extends State<FundTransferSuccessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // context.read<AppStateProvider>().context = context;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        //mobile UI
                        children: [
                          mainWidgets(context),
                        ],
                      ),
                    )
                  : Row(
                      // Web UI
                      children: [
                        Container(
                          width: screenSize.width * .56,
                          height: screenSize.height,
                          color: ColorsUtil.white,
                          child: Column(
                            children: [
                              // Header(
                              //   isDownloadBarVisible: true,
                              //   backOnPressed: () {
                              //     context.pop();
                              //   },
                              // ),
                              // SizedBox(
                              //   height: 50,
                              // ),
                              SizedBox(height: 50),
                              Expanded(
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      width: screenSize.width * .4,
                                      constraints:
                                          BoxConstraints(maxWidth: 500),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 30),
                                          mainWidgets(context)
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
                    )),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(LocalImages.first_deposit_icon),
                        width: 45,
                        height: 50,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.cashFreeText == 'pending'
                            ? 'Fund Transfer Pending'
                            : 'Fund Transfer Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      widget.cashFreeText == 'pending'
                          ? Container()
                          : Column(
                              children: [
                                Text(
                                  'We have recieved your deposit of',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  '₹${widget.amount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32.0,
                                    color: ColorsUtil.greenDepositScreenText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                      // Text(
                      //   'We have recieved your deposit of',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w500,
                      //     fontSize: 12.0,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      // Text(
                      //   '₹${widget.amount}',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w700,
                      //     fontSize: 32.0,
                      //     color: ColorsUtil.greenDepositScreenText,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      Divider(
                        color: ColorsUtil.lighterGrey,
                        thickness: .5,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Image(
                        image: AssetImage(LocalImages.fund_success_img),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Now sit back and relax\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 20,
                            color: ColorsUtil.blueColor,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'while PeerBridge automatically allocates your funds in the best possible opportunities for you',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: ColorsUtil.blueColor,
                          fontFamily: CustomFonts.nunito,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(children: [
                Image(
                  image: AssetImage(LocalImages.sheild_tick),
                  height: 30,
                  color: ColorsUtil.greenDepositScreenText,
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Capital Protection is Enabled \n with Auto Diversify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: CustomFonts.nunito,
                        fontSize: 14,
                        color: ColorsUtil.greenDepositScreenText,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 20),
              ]),
              CustomButton(
                titleStr: 'Continue to Home',
                onPress: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
