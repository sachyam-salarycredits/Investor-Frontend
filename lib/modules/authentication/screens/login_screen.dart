import 'dart:async';
import 'package:peerbridge/modules/authentication/screens/personal_detail.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/app_router.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../supporting_file/LocalAuth.dart';
import '../../../supporting_file/appsFlyerSdk.dart';
import '../../../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var phoneController = TextEditingController();
  bool isPhoneValid = false;
  bool isPhoneError = false;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getYoutubeVideos();
  }

  Future<void> getYoutubeVideos() async {
    await context.read<AppStateProvider>().getVideosData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    phoneController.dispose();
    super.dispose();
  }

  bool checkValidation() {
    if (!phoneController.text.isMobileNumberValid) {
      setState(() {
        isPhoneError = true;
      });
      return false;
    }

    return true;
  }

  bool isLoading = false;

  void getOTPButtonTap() async {
    if (checkValidation()) {
      setState(() {
        _isLoading = true;
      });
      var otpStatus = await context
          .read<AppStateProvider>()
          .loginSendOTP(phoneController.text);
      setState(() {
        _isLoading = false;
      });
      if (otpStatus) {
        context.pushNamed(RoutesName.OTPVerification, params: {
          Constants.fromLogin: "true",
          Constants.mobileNumber: phoneController.text
        });
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
        _isLoading = true;
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
      _isLoading = false;
    });
  }

  PageController _controller = PageController();
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: PeerBridgeLoader(
            isLoading: _isLoading,
            child: ResponsiveWidget.isSmallScreen(context)
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(child: mainWidgets(context))],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        padding: EdgeInsets.symmetric(vertical: 20),
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
                        // Column(
                        //   children: [
                        //     Header(
                        //       backOnPressed: () {
                        //         context.pop();
                        //       },
                        //     ),
                        //     SizedBox(height: 50),
                        //     Expanded(
                        //       child: Container(
                        //         width: screenSize.width * .4,
                        //         constraints: BoxConstraints(maxWidth: 500),
                        //         child: Center(
                        //           child: Container(
                        //             margin: EdgeInsets.symmetric(vertical: 20),
                        //             child: mainWidgets(context),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ),
                      SideImageWidget(
                        screenSize: screenSize,
                        currentIndex: 0,
                        controller: _controller,
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Image(
  image: AssetImage(LocalImages.peerbridge_logo),
  height: 40,
  width: 240,
),
                Image(
                  image: AssetImage(LocalImages.welcome_login_icon),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome, back',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.blueColor),
                ),
                SizedBox(height: Utils.isWeb ? 0 : 10),
                Utils.isWeb
                    ? Container()
                    : Center(
                        child: InkWell(
                          onTap: () {
                            localAuthentication();
                          },
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image(
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                image: AssetImage(LocalImages.faceId),
                              ),
                              Text(
                                'Login with Face Id.',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    fontFamily: CustomFonts.nunito,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                Text(
                  'or',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.blueColor),
                ),
              ],
            ),
          ),
        ),
        // SizedBox(
        //   height: 60,
        // ),
        // Image(
        //   image: AssetImage(LocalImages.peerbridge_mark),
        //   width: 39.29,
        //   height: 29,
        // ),
        // SizedBox(height: 70),
        // Text(
        //   'Sign up /  Login',
        //   style: TextStyle(
        //     fontFamily: CustomFonts.nunito,
        //     fontWeight: FontWeight.w700,
        //     color: Colors.black,
        //     fontSize: 24,
        //   ),
        // ),
        // SizedBox(height: 5),
        // Text(
        //   'Sign up / Login with your phone number',
        //   style: TextStyle(
        //     fontWeight: FontWeight.w400,
        //     fontFamily: CustomFonts.nunito,
        //     fontSize: 14,
        //   ),
        // ),
        // SizedBox(height: 32),

        InputWidget(
          rightIcon: Icon(
            Icons.check_sharp,
            color: isPhoneValid ? ColorsUtil.blueColor : Colors.transparent,
          ),
          horizontalMargin: 0,
          keyboardType: TextInputType.numberWithOptions(),
          controller: phoneController,
          // heading: phoneController.text == '' ? '' : "Phone Number",
          hintStr: 'Phone Number',
          heading: 'Phone Number',
          isValid: isPhoneValid,
          isError: isPhoneError,
          leftIcon: Icon(
            Icons.phone_android_outlined,
            color: isPhoneValid ? ColorsUtil.blueColor : ColorsUtil.lightBlack,
          ),
          maxLength: 10,
          onChange: (String input) {
            setState(() {
              isPhoneValid = input.isMobileNumberValid;
              isPhoneError = false;
            });
          },
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: RichText(
            text: TextSpan(
              text: "Once you click ",
              style: TextStyle(
                color: ColorsUtil.lightBlack,
                fontFamily: CustomFonts.nunito,
                fontSize: 11,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: 'Login, ',
                    style: TextStyle(
                      color: ColorsUtil.lightBlack,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            'you will receive a 6 digit OTP to this mobile number.',
                        style: TextStyle(
                          color: ColorsUtil.lightBlack,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                      )
                    ]),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        CustomButton(
          horizontalMargin: 0,
          titleStr: 'Login',
          onPress: getOTPButtonTap,
        ),
        SizedBox(
          height: 15,
        ),
        Center(
          child: RichText(
            text: new TextSpan(
              text: 'Don\'t have an account?',
              style: TextStyle(
                  fontFamily: CustomFonts.nunito,
                  fontSize: 16,
                  color: Colors.black),
              children: <TextSpan>[
                new TextSpan(
                    text: ' Register here',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // context.pop();
                        // context.goNamed(RoutesName.PanVerification);
                        context.pushNamed(RoutesName.PanVerification);
                      },
                    style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      color: ColorsUtil.greenText,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
