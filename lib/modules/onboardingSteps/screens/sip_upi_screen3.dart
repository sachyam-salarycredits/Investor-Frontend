import 'dart:async';

import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../utils/images.dart';

class UPIScreenThird extends StatefulWidget {
  const UPIScreenThird({Key? key}) : super(key: key);

  @override
  _UPIScreenThirdState createState() => _UPIScreenThirdState();
}

class _UPIScreenThirdState extends State<UPIScreenThird> {
  bool _isLoading = false;

  //
  FocusNode _focus = FocusNode();
  bool isFocused = false;
  bool isUpiValid = false;
  bool isUpiError = false;
  Timer? mytimer;

  var upiController = TextEditingController();
  @override
  void initState() {
    super.initState();
    mytimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _pollMandateStatus();
    });
  }

  Future<void> _pollMandateStatus() async {
    final provider = context.read<AppStateProvider>();
    await provider.checkSipUpiMandateStatus({
      ApiParams.customerId: provider.customerId,
    });
    final sip = await provider.getPreviousSip();
    if (sip?.sipEnable == true) {
      mytimer?.cancel();
      if (!mounted) return;
      await provider.getCustomerDetails();
      context.pushNamed(
        RoutesName.UPISuccessScreen,
        params: {Constants.paymentMethod: 'UPI E-Nach'},
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    mytimer?.cancel();
    // Clean up the controller when the widget is disposed.
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
                  'UPI E-Nach',
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
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      mainWidgets(context),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                            titleStr: 'UPI E-Nach',
                                            desStr: '',
                                          ),
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
                      ),
                      Container(
                        width: screenSize.width * .44,
                        color: ColorsUtil.blueColor,
                      )
                    ],
                  ),
          ),
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
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage(LocalImages.upi_icon),
                            width: 200,
                            height: 100,
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Please go to your app and\n approve the request',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.blueColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            '₹1 rupee debit is required to\n ensure subsequent amount can\n be auto collected',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: ColorsUtil.blueColor),
                          ),
                        ],
                      ))),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'This screen will proceed automatically when you accept the mandate request from your partner UPI app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.greyPlaceHolder,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'If you wish to cancel this mandate, press go back',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.greyPlaceHolder,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              CustomButton(
                titleStr: 'Go Back',
                onPress: () {
                  mytimer?.cancel();
                  context.pop();
                },
              ),
              SizedBox(
                height: 25,
              )
            ],
          )
        ],
      ),
    );
  }
}
