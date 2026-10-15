import 'dart:async';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/steps_data.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/aadhaar_verification.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/auto_investment.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/fund_transfer_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/market_place_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/sip_screen.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/steps_widget.dart';
import 'package:peerbridge/modules/onboardingSteps/widgets/whats_next_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../supporting_file/appsFlyerSdk.dart';
import '../../../utils/constants.dart';
import 'authorized_signatory_screen.dart';
import 'mip_set_up.dart';
import 'nominee_detail_screen.dart';

class WhatsNextScreen extends StatefulWidget {
  const WhatsNextScreen({Key? key}) : super(key: key);

  @override
  _WhatsNextScreenState createState() => _WhatsNextScreenState();
}

class _WhatsNextScreenState extends State<WhatsNextScreen> {
  bool marketChecked = false;
  bool loading = false;
  bool switchValue = false;

  setLoader(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setLoader(true);
      if (Constants.registration) {
        context.pushNamed(RoutesName.FirstDepositScreen, params: {
          Constants.fromOtp: "false",
        });
      }
      context.read<AppStateProvider>().getCustomerDetails();
      await context.read<AppStateProvider>().getStepsStatus();
      print(' String appFlyId ${AFSdk.appFlyId}');
      setAppsFlyId();
    });
  }

  setAppsFlyId() async {
    context.read<AppStateProvider>().setappsFlyIdUpdate(AFSdk.appFlyId);
    setLoader(false);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: PeerBridgeLoader(
        isLoading: loading,
        child: Scaffold(
          body: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Header(
                        isBackBtnVisible: false,
                      ),
                      Container(
                        width: double.infinity,
                        height: 60,
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'What’s Next',
                            style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      mainWidgets(context)
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        height: screenSize.height,
                        color: ColorsUtil.white,
                        child: Column(
                          children: [
                            Header(
                              isBackBtnVisible: false,
                            ),
                            SizedBox(height: 50),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: screenSize.width * .4,
                                  constraints: BoxConstraints(maxWidth: 500),
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 30),
                                      mainWidgets(context)
                                    ],
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
          ),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    final stateProvider = Provider.of<AppStateProvider>(context);

    final statusData = stateProvider.stepsData ?? StepsData();

    final stepsList = StepsContent.getStepsList(
        statusData, stateProvider.userDetails?.panDetails?.gender);
    final advanceStepsList = StepsContent.getAdvanceStepsList(
        statusData, stateProvider.userDetails?.panDetails?.gender);

    bool isAllCompleted() {
      if (statusData.fundTransfer == '1' &&
          statusData.authorizedSignatory == '1' &&
          statusData.kyc == '1' &&
          statusData.autoInvestment == '1' &&
          statusData.mip == '1' &&
          statusData.sip == '1' &&
          statusData.nominee == '1') {
        return true;
      }
      return false;
    }

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(
              child: Image(
                image: AssetImage(LocalImages.green_sheild_tick),
                width: 45,
                height: 55,
                color: ColorsUtil.blueColor,
              ),
            ),
            SizedBox(height: 23),
            Visibility(
              visible: true,
              child: Text(
                'Almost there!',
                maxLines: 1,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w700,
                    color: ColorsUtil.black,
                    fontSize: 25),
              ),
            ),
            Visibility(
              visible: false,
              child: Text(
                'Ready to Earn 13% p.a.',
                maxLines: 1,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w700,
                    color: ColorsUtil.black,
                    fontSize: 25),
              ),
            ),
            SizedBox(height: 10),
            Visibility(
              visible: true,
              child: Text(
                'Please take a moment to complete the \n few remaining steps.',
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.lightGrey,
                    fontSize: 16),
              ),
            ),
            SizedBox(height: 40),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return WhatsNextWidget(
                  headingText: stepsList[index].title,
                  status: stepsList[index].status,
                  onPress: () {
                    if (stepsList[index].screenName ==
                        RoutesName.AadharVerification) {
                      if (stepsList[index].status == '0') {
                        context.pushNamed(stepsList[index].screenName);
                      }
                    } else {
                      context.pushNamed(stepsList[index].screenName);
                    }
                  },
                );
              },
              itemCount: stepsList.length,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Advanced Settings',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  FlutterSwitch(
                    activeColor: ColorsUtil.blueColor,
                    width: 50.0,
                    height: 25.0,
                    // valueFontSize: 25.0,
                    toggleSize: 20.0,
                    value: switchValue,
                    borderRadius: 30.0,
                    // padding: 8.0,
                    // showOnOff: true,
                    onToggle: (val) {
                      setState(() {
                        switchValue = val;
                      });
                    },
                  )
                ],
              ),
            ),
            switchValue
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return WhatsNextWidget(
                        headingText: advanceStepsList[index].title,
                        status: advanceStepsList[index].status,
                        onPress: () {
                          context.pushNamed(advanceStepsList[index].screenName);
                          // if (advanceStepsList[index].screenName ==
                          //     RoutesName.AadharVerification) {
                          //   if (stepsList[index].status == '0') {
                          //     context.pushNamed(stepsList[index].screenName);
                          //   }
                          // } else {
                          //   context.pushNamed(stepsList[index].screenName);
                          // }
                        },
                      );
                    },
                    itemCount: advanceStepsList.length,
                  )
                : Container(),
            SizedBox(height: 20.0),
            CustomButton(
              titleStr: 'Go to Home',
              onPress: () {
                showDialog(
                  context: context,
                  builder: (_) => _whatsNextPopUpPopupDialog(context),
                );
              },
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _whatsNextPopUpPopupDialog(BuildContext context) {
    return StatefulBuilder(builder: (_, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        title: Container(
          constraints: BoxConstraints(maxWidth: 320),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: ColorsUtil.blueColor,
                      value: marketChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          marketChecked = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    text: "By checking the details, you agree with our ",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: CustomFonts.nunito,
                      fontSize: 15.0,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'terms & conditions',
                        style: TextStyle(
                          color: ColorsUtil.blueColor,
                          fontFamily: CustomFonts.nunito,
                          decoration: TextDecoration.underline,
                          fontSize: 15.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (Utils.isWeb) {
                              Utils.launchURL(APIUrls.termsCondition);
                            } else {
                              context.pushNamed(RoutesName.TermsWebView);
                            }
                            // context.pushNamed(RoutesName.TermsWebView);
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CustomButton(
              titleStr: 'Proceed to Home',
              onPress: () {
                if (marketChecked) {
                  Constants.registration = false;
                  context.pushNamed(RoutesName.HomeScreen, queryParams: {
                    "data": Utils.buildTokenJson(
                        context.read<AppStateProvider>().token ?? "",
                        context.read<AppStateProvider>().customerId)
                  });
                } else {
                  Utils.showAlert(
                      context: context, msg: LanguageHelper.textTermsCondAgree);
                }
              },
            ),
          )
        ],
      );
    });
  }
}

// ignore: must_be_immutable

class StepsContent {
  static final fundTransfer = "Fund Transfer";
  static final authorizedSignatory = "Authorized Signatory";
  static final kyc = "e-KYC";
  static final autoInvest = "Set-up Auto Diversify";
  static final mip = "Monthly Income Plan (MIP)";
  static final sip = "Systematic Investment Plan (SIP)";
  static final nominee = "Nominee";

  String title;
  String status;
  String screenName;

  StepsContent({
    required this.title,
    required this.status,
    required this.screenName,
  });

  static List<StepsContent> getStepsList(StepsData stepsData, gender) {
    var stepsList = <StepsContent>[];
    stepsList.add(StepsContent(
        title: fundTransfer,
        status: stepsData.fundTransfer,
        screenName: RoutesName.NewFundTransferScreen));
    if (gender == null || gender == '') {
      stepsList.add(StepsContent(
          title: authorizedSignatory,
          status: stepsData.authorizedSignatory,
          screenName: RoutesName.AuthorizedSignatory));
    }
    stepsList.add(StepsContent(
        title: kyc,
        status: stepsData.kyc,
        screenName: RoutesName.AadharVerification));
    // stepsList.add(StepsContent(
    //     title: autoInvest,
    //     status: stepsData.autoInvestment,
    //     screenName: RoutesName.AutoInvestment));
    // stepsList.add(StepsContent(
    //     title: mip, status: stepsData.mip, screenName: RoutesName.MIPSetUp));
    // stepsList.add(StepsContent(
    //     title: sip, status: stepsData.sip, screenName: RoutesName.SIP));
    // stepsList.add(StepsContent(
    //     title: nominee,
    //     status: stepsData.nominee,
    //     screenName: RoutesName.NomineeDetail));

    return stepsList;
  }

  static List<StepsContent> getAdvanceStepsList(StepsData stepsData, gender) {
    var advanceStepsList = <StepsContent>[];
    advanceStepsList.add(StepsContent(
        title: autoInvest,
        status: stepsData.autoInvestment,
        screenName: RoutesName.AutoInvestment));
    advanceStepsList.add(StepsContent(
        title: mip, status: stepsData.mip, screenName: RoutesName.MIPSetUp));
    advanceStepsList.add(StepsContent(
        title: sip, status: stepsData.sip, screenName: RoutesName.SIP));
    advanceStepsList.add(StepsContent(
        title: nominee,
        status: stepsData.nominee,
        screenName: RoutesName.NomineeDetail));

    return advanceStepsList;
  }
}
