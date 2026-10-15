import 'package:peerbridge/routes_management/app_router.dart';
// import 'dart:html' as html;
import 'package:peerbridge/supporting_file/flyy_web_sdk.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/app_state_provider.dart';
import '../../../supporting_file/LocalAuth.dart';
import '../../../supporting_file/appsFlyerSdk.dart';
import '../../../utils/constants.dart';
// import 'package:universal_html/html.dart';

class WelcomeWylthScreen extends StatefulWidget {
  const WelcomeWylthScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeWylthScreen> createState() => _WelcomeWylthScreenState();
}

class _WelcomeWylthScreenState extends State<WelcomeWylthScreen> {
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWylthReferalData();
  }
  Future<void> getWylthReferalData() async {
    await context.read<AppStateProvider>().getWylthReferData();
    final wylthReferData = context.read<AppStateProvider>().wylthReferalData;
    //
    // final storage = window.sessionStorage;
    // storage['customerId'] = wylthReferData?.customerId ?? '';
    // storage['flyyUrl'] = wylthReferData?.flyyUrl ?? '';
    // storage['referCode'] = wylthReferData?.referCode ?? '';
  }


  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: PeerBridgeLoader(
          isLoading: isLoading,
          child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Column(
                //mobile UI
                children: [mainWidgets(context)],
              )
                  : Row(
                // Web UI
                children: [
                  Container(
                    width: screenSize.width * .56,
                    child: ConstrainedBox(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * .04),
                        child: mainWidgets(context),
                      ),
                      // child: Container(color: Colors.red),
                      constraints: BoxConstraints(
                        maxWidth: 500,
                      ),
                    ),
                  ),
                  Container(
                    width: screenSize.width * .44,
                    // color: ColorsUtil.greenColor,
                    child: Stack(
                      children: [
                        Image(
                          width: screenSize.width * .44,
                          height: screenSize.height,
                          fit: BoxFit.cover,
                          image: AssetImage(LocalImages.girl),
                        ),
                        Container(
                          color: ColorsUtil.blueColor,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Image(
  width: 200,
  height: 33,
  image: AssetImage(LocalImages.peerbridge_logo_white),
),
                                        SizedBox(height: 50),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: ColorsUtil.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('RBI Registered NBFC',
                                                style: TextStyle(
                                                    fontFamily:
                                                    CustomFonts
                                                        .nunito,
                                                    fontSize: 16,
                                                    color:
                                                    ColorsUtil.white,
                                                    fontWeight:
                                                    FontWeight.w700)),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                            'Delivering Financial Happiness!',
                                            style: TextStyle(
                                                fontFamily:
                                                CustomFonts.nunito,
                                                fontSize: 25,
                                                color: ColorsUtil.white,
                                                fontWeight:
                                                FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 140,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  33.0),
                                              child: Image(
                                                image: AssetImage(
                                                    LocalImages.rama),
                                                width: 66,
                                                height: 66,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              '“ Monexo is the Uber of Finance —\n'
                                                  'Solid returns, robust risk mitigation & great team ”',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                CustomFonts.nunito,
                                                fontWeight:
                                                FontWeight.w400,
                                                fontSize: 14,
                                                color: ColorsUtil.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text('— Ramanathan, Mumbai',
                                                textAlign:
                                                TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                  CustomFonts.nunito,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                  fontSize: 13,
                                                  color: ColorsUtil.white,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center(
                  //   child: Image(
                  //     height: MediaQuery.of(context).size.height * 0.35,
                  //     width: ResponsiveWidget.isSmallScreen(context)
                  //         ? MediaQuery.of(context).size.width * 0.55
                  //         : MediaQuery.of(context).size.width * 0.25,
                  //     fit: BoxFit.cover,
                  //     image: AssetImage(LocalImages.landingScreenIcon),
                  //   ),
                  // ),

                  SizedBox(height: 25),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18,),
                    child: Text(
                      'Welcome to ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w700,
                          color: ColorsUtil.blueColor),
                    ),
                  ),
                  Center(
                    child: Image(
  width: 220,
  height: 36,
  fit: BoxFit.contain,
  image: AssetImage(LocalImages.peerbridge_logo),
),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You are referred through',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: CustomFonts.nunito,
                              fontWeight: FontWeight.w700,
                              color: ColorsUtil.blueColor),
                        ),
                        Image(
                          height: 30,
                          fit: BoxFit.cover,
                          image: AssetImage(
                            LocalImages.wylth_icon,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SizedBox(height: Utils.isWeb ? 0 : 20),
                ],
              ),
            ),
          ),
        ),
        Container(
          child: Column(
            children: [

              CustomButton(
                titleStr: 'Continue',
                onPress: () {
                  // final wylthReferData = context.read<AppStateProvider>().wylthReferalData?.flyyUrl;
                  // html.window.open( "$wylthReferData","_self");
                  context.pushNamed(RoutesName.LandingScreen);
                }, //submitBtnTap,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}