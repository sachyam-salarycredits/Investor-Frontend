import 'dart:async';

import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/app_router.dart';
import 'package:Monexo/routes_management/routes_list.dart';

import 'package:Monexo/modules/authentication/screens/personal_detail.dart';
import 'package:Monexo/modules/profile/screens/profile_detail_screen.dart';
import 'package:Monexo/supporting_file/appsFlyerSdk.dart';
import 'package:Monexo/supporting_file/otp_auto_detect.dart';
import 'package:Monexo/utils/api_constant.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OTPVarificationScreen extends StatefulWidget {
  final bool fromLogin;
  final String mobileNumber;

  OTPVarificationScreen({
    Key? key,
    required this.fromLogin,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _OTPVarificationScreenState createState() => _OTPVarificationScreenState();
}

class _OTPVarificationScreenState extends State<OTPVarificationScreen> {
  static const timerSec = 120;
  bool isVerified = false;
  bool isInvalid = false;
  int seconds = timerSec;
  Timer? _timer;
  int currentIndex = 0;
  PageController? _controller;
  bool _isLoading = false;
  String otp = "";
  bool isResendOtp = false;
  bool autoFocus = true;

  final otpKey = UniqueKey();

  //used textediting controller to detect otp
  late OTPTextEditController otpController;
  // late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;

  initAutoDetectOtp() async {
    _otpInteractor = OTPInteractor();
    _otpInteractor
        .getAppSignature()
        //ignore: avoid_print
        .then((value) => print('signature - $value'));

    otpController = OTPTextEditController(
      codeLength: 6,
      //ignore: avoid_print
      onCodeReceive: (code) => print('Your Application receive code - $code'),
      otpInteractor: _otpInteractor,
    )..startListenUserConsent(
        (code) {
          final exp = RegExp(r'(\d{6})');
          return exp.stringMatch(code ?? '') ?? '';
        },
      );
    setState(() {});
  }

  @override
  void initState() {
    // initAutoDetectOtp();
    // _otpInteractor = OTPInteractor();
    // _otpInteractor
    //     .getAppSignature()
    //     //ignore: avoid_print
    //     .then((value) => print('signature - $value'));
    //
    // otpController = OTPTextEditController(
    //   codeLength: 6,
    //   //ignore: avoid_print
    //   onCodeReceive: (code) => print('Your Application receive code - $code'),
    //   otpInteractor: _otpInteractor,
    // )..startListenUserConsent(
    //     (code) {
    //       final exp = RegExp(r'(\d{6})');
    //       return exp.stringMatch(code ?? '') ?? '';
    //     },
    //   );
    super.initState();

    _controller = PageController(initialPage: 0);
    initAutoDetectOtp();
    // listenOtp();
    startTimer();
  }

  // @override
  // void dispose() {
  //   // otpController.dispose();
  //   otpController.stopListen();
  //
  //   super.dispose();
  //   // Clean up the controller when the widget is disposed.
  //   _timer?.cancel();
  // }
  // @override
  // void dispose() {
  //   super.dispose();
  //   _timer?.cancel();
  // }

  @override
  void dispose() async {
    super.dispose();
    _timer?.cancel();
    await otpController.stopListen();
  }

  // Start time for OTP receiver
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (seconds == 0) {
          if (this.mounted) {
            setState(() {
              timer.cancel();
              isResendOtp = true;
            });
          }
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  /// Resend OTP button tap
  void resendOtpTap() async {
    setState(() {
      _isLoading = true;
    });
    var otpStatus = false;
    if (widget.fromLogin) {
      otpStatus = await context
          .read<AppStateProvider>()
          .loginSendOTP(widget.mobileNumber);
    } else {
      var personalDetail = context.read<AppStateProvider>().personalDetail;
      var param = Map<String, String>();
      param[ApiParams.pan] =
          context.read<AppStateProvider>().panDetails?.pan ?? '';
      param[ApiParams.fullName] = personalDetail?.fullName ?? "";
      param[ApiParams.email] = personalDetail?.email ?? "";
      param[ApiParams.phoneNo] = widget.mobileNumber;
      setState(() {
        _isLoading = true;
      });
      otpStatus = await context.read<AppStateProvider>().signupSendOTP(param);
    }

    setState(() {
      _isLoading = false;
    });
    if (otpStatus) {
      setState(() {
        isResendOtp = false;
        seconds = timerSec;
        initAutoDetectOtp();
      });
      startTimer();
    }
  }

  void submitButtonTap() async {
    setState(() {
      autoFocus = false;
      isInvalid = false;
      isVerified = false;
    });

    if (widget.fromLogin) {
      var result = await context
          .read<AppStateProvider>()
          .loginVerifyOTP(widget.mobileNumber, otp);
      if (result) {
        isVerified = true;
        getCustomerIdList();
      } else {
        otpController.text = "";
        setState(() {
          otp = "";
        });
      }
    } else {
      var cid = await context
          .read<AppStateProvider>()
          .signupVerifyOTP(widget.mobileNumber, otp);
      if (cid != null) {
        isVerified = true;

        await getCustomerDetails();
        await addUserToSegment();
      } else {
        otpController.text = "";
        setState(() {
          otp = "";
        });
      }
    }

    setLoading(false);
  }

  /// get customer Id's List For Login process
  Future<void> getCustomerIdList() async {
    setLoading(true);
    var cidListRes = await context
        .read<AppStateProvider>()
        .getCustomerList(widget.mobileNumber);
    setLoading(false);
    if (cidListRes != null && cidListRes.length > 0) {
      if (cidListRes.length == 1) {
        ///Skip welcome page
        getCustomerDetails();
        //Mark: ApssFlyer login event trigger
        AFSdk.logEvent(AFSdk.af_login, null);
        AFSdk.setUser(cidListRes.first.customerId ?? "");
        //
      } else {
        // Show welcome page
        context.pushNamed(RoutesName.WelcomeBack);
      }
    }
  }

  /// Get Customer Details
  Future<void> getCustomerDetails() async {
    setLoading(true);
    await context.read<AppStateProvider>().getCustomerDetails();
    setLoading(false);
    context.moveInitialPage();
  }

  /// Get Customer Details
  Future<void> addUserToSegment() async {
    setLoading(true);
    await context.read<AppStateProvider>().addUserToSegment();
    setLoading(false);
    context.moveInitialPage();
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
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
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'OTP Verification',
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
        body: MonexoLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Column(
                      children: [
                        mainWidgets(context, screenSize),
                        // Expanded(
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.vertical,
                        //     child: Column(
                        //       children: [
                        //         SizedBox(height: 30),
                        //         mainWidgets(context, screenSize),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                : Container(
                    child: Row(
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
                              Expanded(
                                child: Container(
                                  width: screenSize.width * .4,
                                  constraints: BoxConstraints(maxWidth: 500),
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    children: [
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       horizontal: 15),
                                      //   child: Align(
                                      //     alignment: Alignment.centerLeft,
                                      //     child: Text(
                                      //       'OTP Verification',
                                      //       style: TextStyle(
                                      //         fontFamily:
                                      //         CustomFonts.nunito,
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: 20,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // SizedBox(height: 20),
                                      mainWidgets(context, screenSize),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SideImageWidget(
                          screenSize: screenSize,
                          currentIndex: currentIndex,
                          controller: _controller!,
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Padding buildDot(int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Image(
        width: 10,
        height: 10,
        color: ColorsUtil.white,
        image: AssetImage(1 == index
            ? LocalImages.selected_circle
            : LocalImages.page_unselected),
      ),
    );
  }

  Widget mainWidgets(BuildContext context, screenSize) {
    return Expanded(
      child: Column(
        children: [
          // Image(
          //   image: AssetImage(LocalImages.monexo_m),
          //   width: 50,
          //   height: 50,
          // ),
          // SizedBox(height: 30),
          // Text(
          //   'OTP Verification',
          //   style: TextStyle(
          //     fontFamily: CustomFonts.nunito,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black,
          //     fontSize: 24,
          //   ),
          // ),
          // SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  RichText(
                    text: new TextSpan(
                      text: 'A six digit OTP code has been sent to ',
                      style: TextStyle(
                          fontFamily: CustomFonts.nunito,
                          fontSize: 13,
                          color: Colors.black),
                      children: <TextSpan>[
                        new TextSpan(
                            text: '+91-${widget.mobileNumber}',
                            style: new TextStyle(
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.greenText,
                            )),
                      ],
                    ),
                  ),
                  // Text(
                  //   'A verification OTP code will be sent to',
                  //   style: TextStyle(
                  //     fontFamily: CustomFonts.nunito,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  // SizedBox(height: 5),
                  // Text(
                  //   '(+91) ${widget.mobileNumber}',
                  //   style: TextStyle(
                  //     fontFamily: CustomFonts.nunito,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 16,
                  //   ),
                  // ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    width: screenSize.width,
                    child: PinCodeTextField(
                      autoDisposeControllers: false,
                      key: otpKey,
                      controller: otpController,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textStyle: TextStyle(
                          color: ColorsUtil.greyPlaceHolder,
                          fontWeight: FontWeight.normal,
                          fontSize: 18),
                      length: 6,
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      // validator: (v) {
                      //   return null;
                      //   // if (v!.length !=6) {
                      //   //   return "enter valid otp";
                      //   // } else {
                      //   //   return null;
                      //   // }
                      // },
                      obscureText: false,
                      pinTheme: PinTheme(
                        borderWidth: 1,
                        shape: PinCodeFieldShape.box,
                        inactiveColor: ColorsUtil.lighterGrey,
                        inactiveFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        disabledColor: Colors.grey.shade200,
                        activeFillColor: ColorsUtil.white,
                        activeColor: ColorsUtil.lighterGrey,
                        errorBorderColor: ColorsUtil.redColor,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        fieldHeight: 50,
                        fieldWidth: 40,
                      ),
                      autoFocus: autoFocus,
                      cursorColor: ColorsUtil.blueColor,
                      animationDuration: Duration(milliseconds: 300),
                      enableActiveFill: true,
                      //  controller: otpTextController,
                      keyboardType: TextInputType.number,
                      onCompleted: (v) {
                        FocusScope.of(context).unfocus();
                        submitButtonTap();
                      },
                      //  controller: otpController,
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                      onChanged: (String value) {
                        otp = value;
                        setState(() {});
                      },
                    ),
                  ),
                  Visibility(
                    visible: otp.length != 6,
                    child: Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.vertical,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 20,
                                    color: ColorsUtil.blueColor,
                                  ),
                                  SizedBox(width: 5),
                                  RichText(
                                    text: TextSpan(
                                      text:
                                          "${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')} Sec ",
                                      style: TextStyle(
                                        color: ColorsUtil.lightBlack,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'left to receive your OTP',
                                          style: TextStyle(
                                            color: ColorsUtil.lightBlack,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.autorenew,
                                    size: 20,
                                    color: ColorsUtil.greenText,
                                  ),
                                  SizedBox(
                                    width: 1,
                                  ),
                                  TextButton(
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero)),
                                      onPressed: () {
                                        if (isResendOtp) resendOtpTap();
                                      },
                                      child: Text(
                                        'Resend OTP',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                            color: isResendOtp
                                                ? ColorsUtil.greenText
                                                : ColorsUtil.dividerColor),
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // SizedBox(height: 10),
                        // Divider(),
                        // SizedBox(height: 20),
                        // Text(
                        //   'If you entered the incorrect mobile number',
                        //   style: TextStyle(
                        //       fontFamily: CustomFonts.nunito,
                        //       fontWeight: FontWeight.bold,
                        //       fontSize: 14),
                        // ),
                        // SizedBox(height: 10),
                        // OutlinedButton(
                        //   onPressed: () {
                        //     context.pop();
                        //   },
                        //   child: Text(
                        //     'CHANGE PHONE NUMBER',
                        //     style: TextStyle(
                        //       fontFamily: CustomFonts.nunito,
                        //       fontWeight: FontWeight.bold,
                        //       color: ColorsUtil.blueColor,
                        //       fontSize: 14,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Visibility(
            visible: otp.length == 6,
            child: CustomButton(
              bgColor: isInvalid ? ColorsUtil.errorColor : ColorsUtil.blueColor,
              titleStr: isInvalid
                  ? 'Wrong OTP'
                  : (isVerified ? 'Verified Successfully' : 'Checking OTP'),
              isLoader: otp.length == 6 && !isVerified && !isInvalid,
              leftIcon: isInvalid
                  ? Icon(Icons.close)
                  : (isVerified
                      ? Image(
                          image: AssetImage(LocalImages.sheild_tick),
                          width: 20,
                          height: 20,
                        )
                      : null),
            ),
          )
        ],
      ),
    );
  }
}
