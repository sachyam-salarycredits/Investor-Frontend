import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:otp_autofill/otp_autofill.dart';




class AutoDetectOtp{
  OTPTextEditController getOtpController(){

    if(Utils.isAndroid)
      {
        OTPInteractor().getAppSignature()
            .then((value) => print('signature - $value'));

        //demo signature
        //zaqs5D1fqUR
        var otpController = OTPTextEditController(
            codeLength: 6,
            onCodeReceive: (code) => print('Your Application receive code - $code'),
            errorHandler: (e)=>print(e),
            onTimeOutException: (){
              print("timeout for otp reading");
            }
        )..startListenRetriever((code){
          final exp = RegExp(r'(\d{6})');
          return exp.stringMatch(code ?? '') ?? '';

        });

        return otpController;
      }
    return OTPTextEditController(codeLength: 6);
  }
}
