import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SIPMIPIntroScreen extends StatefulWidget {
  final bool forSIP;
  const SIPMIPIntroScreen({Key? key, required this.forSIP}) : super(key: key);

  @override
  _SIPMIPIntroScreen createState() => _SIPMIPIntroScreen();
}

class _SIPMIPIntroScreen extends State<SIPMIPIntroScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return true;
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
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        icon: Icon(Icons.keyboard_backspace,size: 30,),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ),
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
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                            icon: Icon(Icons.keyboard_backspace,size: 30,),
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
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
                      Text(
                          widget.forSIP
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
                          widget.forSIP
                              ? content[0].subTitleText
                              : content[1].subTitleText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                              color: ColorsUtil.blueColor,
                              fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
                widget.forSIP
                    ? content[0].descriptionText
                    : content[1].descriptionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    fontSize: 14,
                    color: ColorsUtil.blueColor,
                    fontWeight: FontWeight.w400)),
          ),
          const SizedBox(height: 20),
          CustomButton(
            titleStr: widget.forSIP
                ? content[0].btnText
                : content[1].btnText,
            onPress: () {
              if (widget.forSIP) {
                context.pushNamed(RoutesName.SIP);
              } else {
                context.pushNamed(RoutesName.MIPSetUp);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// FirstDeposit Screen Content Data Model Class
class SIPMIPIntroScreenContent {
  String titleText;
  String subTitleText;
  String descriptionText;
  String btnText;

  SIPMIPIntroScreenContent({
    required this.titleText,
    required this.subTitleText,
    required this.descriptionText,
    required this.btnText,
  });
}

/// First Deposit Screen Content Data List
List<SIPMIPIntroScreenContent> content = [
  //before SIP screen content
  SIPMIPIntroScreenContent(
    titleText: 'Setup you SIP',
    subTitleText:
    'Don’t miss out on investment opportunities and make the most out to compound your returns',
    btnText: 'Setup SIP',
    descriptionText: 'Automate adding funds to your PeerBridge account with our SIP Feature',
  ),
 //before mip screen content
  SIPMIPIntroScreenContent(
    titleText: 'Setup you MIP',
    subTitleText:
    'Transfer your montly interest earnings back to your\nbank account',
    btnText: 'Setup MIP',
    descriptionText:
    'Automate what to do with your interest earned every month',
  ),
];
