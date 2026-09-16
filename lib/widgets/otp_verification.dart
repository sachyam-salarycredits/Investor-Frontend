import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/supporting_file/otp_auto_detect.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'custom_button.dart';

class OtpVerificationWidget extends StatefulWidget {
  final String? mobileNumber;
  final void Function() onFailed;
  final void Function() onVerified;
  bool isSipOTP;

  OtpVerificationWidget(
      {Key? key,
      required this.onFailed,
      required this.onVerified,
      this.mobileNumber,
      this.isSipOTP = false})
      : super(key: key);

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  bool isLoading = false;
  String otp = "";
  String mobileNo = '';

  int endTime = DateTime.now().add(Duration(minutes: 2)).millisecondsSinceEpoch;
  bool isTimerFinished = false;
  bool isValid() => otp.length == 6;

  late OTPTextEditController otpController;
  late OTPInteractor _otpInteractor;

  initAutoDetectOtp() {
    // otpController = AutoDetectOtp().getOtpController();
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
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userDetails = context.read<AppStateProvider>().userDetails;
      setState(() {
        if (widget.mobileNumber == null || widget.mobileNumber == '') {
          mobileNo = userDetails?.profileDetails?.phoneNumber ?? '';
        } else {
          mobileNo = widget.mobileNumber ?? '';
        }
        initTimer();
      });
      sendOTP();

      initAutoDetectOtp();
    });
  }

  @override
  void dispose() async {
    await otpController.stopListen();
    super.dispose();
  }

  Future<void> sendOTP() async {
    if (widget.mobileNumber == null || widget.mobileNumber == '') {
      await context.read<AppStateProvider>().authSendOTP(mobileNo);
    } else {
      await context.read<AppStateProvider>().loginSendOTP(mobileNo, true);
    }
  }

  initTimer() {
    isTimerFinished = false;
    endTime = DateTime.now()
        .add(Duration(minutes: 2, seconds: 0))
        .millisecondsSinceEpoch;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 220,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(8),
          //  mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage(LocalImages.monexo_m),
              width: 30,
              height: 40,
            ),
            SizedBox(height: 20),
            Text(
              'OTP Verification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'A verification OTP code will be sent to',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '(+91) $mobileNo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.all(4),
              child: PinCodeTextField(
                controller: otpController,
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                length: 6,
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                validator: (v) {
                  return null;
                  // if (v!.length !=6) {
                  //   return "enter valid otp";
                  // } else {
                  //   return null;
                  // }
                },
                obscureText: false,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  inactiveColor: Colors.grey.shade200,
                  inactiveFillColor: Colors.grey.shade200,
                  selectedFillColor: Colors.grey.shade200,
                  disabledColor: Colors.grey.shade200,
                  activeFillColor: ColorsUtil.blueContainerColor,
                  borderRadius: BorderRadius.circular(5),
                  activeColor: ColorsUtil.blueColor,
                  fieldHeight: 50,
                  fieldWidth: 40,
                ),
                autoFocus: true,
                cursorColor: Colors.black,
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                //  controller: otpTextController,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                  verifyOtp();
                },

                // onTap: () {
                //   print("Pressed");
                // },
                // onChanged: (value) {
                //   print(value);
                //   setState(() {
                //     currentText = value;
                //   });
                // },
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
            CountdownTimer(
              widgetBuilder: (ctx, time) {
                if (time != null) {
                  return Container(
                      child: Text(
                    "${(time.min ?? 0)}:${time.sec ?? "00"}",
                    textAlign: TextAlign.center,
                  ));
                } else {
                  return TextButton(
                      onPressed: () {
                        sendOTP();
                      },
                      child: Text("RESEND OTP"));
                }
              },
              key: UniqueKey(),
              endTime: endTime,
            ),
            SizedBox(height: 5),
            CustomButton(
              bgColor:
                  isValid() ? ColorsUtil.blueColor : ColorsUtil.lighterGrey,
              titleStr: isLoading ? "Checking OTP" : "Verify OTP",
              isLoader: isLoading,
              onPress: verifyOtp,
            ),
            SizedBox(
              height: 8,
            ),
            widget.isSipOTP
                ? Container()
                : CustomButton(
                    bgColor: ColorsUtil.transparent,
                    textColor: ColorsUtil.black,
                    titleStr: "Cancel",
                    onPress: () {
                      Navigator.pop(context);
                      widget.onFailed();
                    },
                  )
          ],
        ),
      ),
    );
  }

  void verifyOtp() async {
    if (!isValid() || isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var result = false;
      if (widget.mobileNumber == null || widget.mobileNumber == '') {
        result =
            await context.read<AppStateProvider>().authVerifyOTP(mobileNo, otp);
      } else {
        result = await context
            .read<AppStateProvider>()
            .loginVerifyOTP(mobileNo, otp, true);
      }
      if (result) {
        if (widget.isSipOTP) {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
        widget.onVerified();
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
