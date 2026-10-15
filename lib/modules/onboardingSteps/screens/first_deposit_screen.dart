import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstDepositScreen extends StatefulWidget {
  final bool fromOtp;
  const FirstDepositScreen({Key? key, required this.fromOtp}) : super(key: key);

  @override
  _FirstDepositScreenState createState() => _FirstDepositScreenState();
}

class _FirstDepositScreenState extends State<FirstDepositScreen> {
  bool _isLoading = false;
  bool loading = false;
  setLoader(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  void initState() {
    super.initState();

    resetOnbaordingScreenStatus();
    if (widget.fromOtp == false) {
      //get  AutoInvestCategoryDetails only before fund transfer screen
      getAutoInvestCategoryDetails();
    }
  }

  Future<void> resetOnbaordingScreenStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('show_onboarding', false);
  }

  getAutoInvestCategoryDetails() async {
    await context.read<AppStateProvider>().getAutoInvestCategoryDetails();
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    if (provider.autoInvestCategoryDetailList.isNotEmpty) {
      if (provider.autoInvestCategoryDetailList[0].autoInvestmentEnable ==
          true) {
        saveandModifyAutoInvestments();
      }
    }
  }

  Future<void> saveandModifyAutoInvestments() async {
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    var autoInvestDetail = provider.autoInvestCategoryDetailList
        .where((element) => element.categoryType == 'First Time')
        .toSet()
        .toList();
    setLoader(true);
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.totalAmount] = autoInvestDetail[0].amount;
    param[ApiParams.conservetiveRisk] = autoInvestDetail[0].conservativeRisk;
    param[ApiParams.moderateRisk] = autoInvestDetail[0].moderateRisk;
    param[ApiParams.highRisk] = autoInvestDetail[0].highRisk;
    var saveandModifyAutoInvestments = await context
        .read<AppStateProvider>()
        .saveandModifyAutoInvestments(param);
    setLoader(false);

    if (saveandModifyAutoInvestments) {
      print('saveandModifyAutoInvestments$saveandModifyAutoInvestments');
    } else {
      print('saveandModifyAutoInvestments$saveandModifyAutoInvestments');
    }
  }

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
    var provider = Provider.of<AppStateProvider>(context, listen: false);
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
                          widget.fromOtp
                              ? content[0].titleText
                              : content[1].titleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 22,
                              color: ColorsUtil.blueColor,
                              fontWeight: FontWeight.w700)),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                          widget.fromOtp
                              ? content[0].subTitleText
                              : content[1].subTitleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 15,
                              color: ColorsUtil.blueColor,
                              fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        color: ColorsUtil.lighterGrey,
                        thickness: .5,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Visibility(
                        visible: widget.fromOtp
                            ? content[0].showActionText
                            : content[1].showActionText,
                        child: Text(
                            widget.fromOtp
                                ? content[0].actionText
                                : content[1].actionText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 20,
                                color: ColorsUtil.blueColor,
                                fontWeight: FontWeight.w700)),
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
              Visibility(
                visible: widget.fromOtp
                    ? content[0].showDescriptionText
                    : content[1].showDescriptionText,
                child: Text(
                    widget.fromOtp
                        ? content[0].descriptionText
                        : content[1].descriptionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: CustomFonts.nunito,
                        fontSize: 15,
                        color: ColorsUtil.blueColor,
                        fontWeight: FontWeight.w400)),
              ),
              Visibility(
                visible: provider.autoInvestCategoryDetailList.isNotEmpty
                    ? provider.autoInvestCategoryDetailList[0]
                            .autoInvestmentEnable ??
                        false
                    : false,
                child: Column(children: [
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
              ),
              CustomButton(
                titleStr: widget.fromOtp
                    ? content[0].btnText
                    : content[1].btnText,
                onPress: () {
                  if (widget.fromOtp) {
                    context.pushNamed(RoutesName.SelfieCapture);
                  } else {
                    context.pushNamed(RoutesName.NewFundTransferScreen);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// FirstDeposit Screen Content Data Model Class
class FirstDepositScreenContent {
  String titleText;
  String subTitleText;
  String actionText;
  String descriptionText;
  String btnText;
  bool showShieldText;
  bool showActionText;
  bool showDescriptionText;

  FirstDepositScreenContent({
    required this.titleText,
    required this.subTitleText,
    required this.actionText,
    required this.descriptionText,
    required this.btnText,
    required this.showShieldText,
    required this.showActionText,
    required this.showDescriptionText,
  });
}

/// First Deposit Screen Content Data List
List<FirstDepositScreenContent> content = [
  //after otp screen content
  FirstDepositScreenContent(
    titleText: 'Welcome to PeerBridge',
    subTitleText:
        'You are now a step closer to making your\nfirst investment with PeerBridge',
    actionText: 'Now lets verify your\nbank account',
    btnText: 'Start Verification',
    descriptionText: '',
    showShieldText: false,
    showActionText: true,
    showDescriptionText: false,
  ),

  //after bank detail screen content

  FirstDepositScreenContent(
    titleText: 'Your Bank Account is Verified!',
    subTitleText:
        'You are just a step away to making your first\ninvestment with PeerBridge',
    actionText: 'Make your First Fund Transfer',
    btnText: 'Deposit Money',
    showShieldText: true,
    descriptionText: '',
    showActionText: true,
    showDescriptionText: false,
  ), //before mip screen content

  FirstDepositScreenContent(
    titleText: 'Setup you MIP',
    subTitleText:
        'Transfer your montly interest earnings back to your\nbank account',
    actionText: 'Make your First Fund Transfer',
    btnText: 'Setup MIP',
    descriptionText:
        'Automate what to do with your interest earned\nevery month',
    showShieldText: false,
    showActionText: false,
    showDescriptionText: true,
  ),
  //befor sip screen content

  FirstDepositScreenContent(
    titleText: 'Your Bank Account is Verified!',
    subTitleText:
        'You are just a step away to making your first\ninvestment with PeerBridge',
    actionText: 'Make your First Fund Transfer',
    btnText: 'Deposit Money',
    descriptionText:
        'Automate adding funds to your PeerBridge account\nwith our SIP Feature',
    showShieldText: true,
    showActionText: false,
    showDescriptionText: true,
  )
];
