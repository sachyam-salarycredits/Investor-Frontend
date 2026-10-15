import 'package:peerbridge/routes_management/app_router.dart';

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

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocalAuth();
    SetRegistrationStatus();

    Constants.registration = false;

    if (!Utils.isWeb) {
      resetOnbaordingScreenStatus();
    } else {
      initStartReferalTracking();
    }
  }

  Future<void> resetOnbaordingScreenStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('show_onboarding', false);
  }

  Future<void> SetRegistrationStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('set_registrationStatus', false);
  }

  Future<void> checkLocalAuth() async {
    if (!Utils.isWeb) {
      await context.read<AppStateProvider>().getUserState();
      final cid = context.read<AppStateProvider>().customerId;
      if (cid != "") {
        localAuthentication();
      }
    }
  }

  Future<void> localAuthentication() async {
    final cid = context.read<AppStateProvider>().customerId;
    final mobile = context.read<AppStateProvider>().mobileNo;
    if (cid == "" || mobile == "") {
      Utils.showAlert(
          context: context,
          msg: "You have to Login with your mobile number for the first time");
      return;
    }
    final auth = await LocalAuth.authenticate();
    if (auth) {
      setState(() {
        isLoading = true;
      });
      getNewToken();
    }
  }

  Future<void> getNewToken() async {
    final status = await context.read<AppStateProvider>().autoLoginByUser();
    if (status) {
      final mobilNo = context.read<AppStateProvider>().mobileNo;
      final cidList =
          await context.read<AppStateProvider>().getCustomerList(mobilNo);
      if (cidList?.length == 1) {
        await context.read<AppStateProvider>().getStepsStatus();
        //Mark: ApssFlyer login event trigger
        AFSdk.setUser(cidList?.first.customerId ?? "");
        AFSdk.logEvent(AFSdk.af_login, null);
        //
        context.moveInitialPage();
      } else {
        context.pushNamed(RoutesName.WelcomeBack);
      }
    } else {
      Utils.showAlert(
          context: context,
          msg: "You have to Login with your mobile number for the first time");
    }
    setState(() {
      isLoading = false;
    });
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
                      children: [Expanded(child: mainWidgets(context))],
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
                                color: ColorsUtil.blueColor.withAlpha(200),
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
      // mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                  Center(
                    child: Image(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        LocalImages.preRegisterScreenIcon,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Text(
                      'Please keep the following for smooth account opening:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w700,
                          color: ColorsUtil.blueColor),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    color: ColorsUtil.inputBG,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 8, top: 3, bottom: 5),
                                  child: Image(
                                    // height: 18,
                                    width: 25,
                                    // fit: BoxFit.cover,
                                    image: AssetImage(LocalImages.pan_icon),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    'PAN card number',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.normal,
                                        color: ColorsUtil.blueColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 8, top: 3, bottom: 5),
                                  child: Image(
                                    width: 25,
                                    // fit: BoxFit.cover,
                                    image: AssetImage(LocalImages.aadhar_icon),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    'Aadhar card number ( you will need to take a picture of front and back)',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.normal,
                                        color: ColorsUtil.blueColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: 8, top: 3, bottom: 5),
                                  child: Image(
                                    width: 25,
                                    // height: 15,
                                    // fit: BoxFit.cover,
                                    image: AssetImage(LocalImages.bank_icon),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    'Bank ifsc code and account number from where you want to transfer.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.normal,
                                        color: ColorsUtil.blueColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(
                            color: ColorsUtil.greyTabColor,
                            thickness: .5,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                Text(
                                  'Please note',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.blueColor),
                                ),
                                Text(
                                  'NO document will be required to upload',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w500,
                                      color: ColorsUtil.blueColor),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
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
                titleStr: 'Register Now',
                onPress: () {
                  context.pushNamed(RoutesName.PanVerification);
                }, //submitBtnTap,
              ),
              SizedBox(height: 15),
              Center(
                  child: Column(
                children: [
                  Text(
                    'Already have an account ?',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: CustomFonts.nunito,
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.black),
                  ),
                  InkWell(
                    onTap: () {
                      context.pushNamed(RoutesName.Login);
                    },
                    child: Text(
                      'Login here',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: CustomFonts.nunito,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: ColorsUtil.blueColor),
                    ),
                  ),
                ],
              )),
              SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}
