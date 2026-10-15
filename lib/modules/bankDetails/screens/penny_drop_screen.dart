import 'dart:async';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/modules/bankDetails/screens/welcome_screen.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/user_preferences.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/src/provider.dart';

class PennyDropScreen extends StatefulWidget {
  const PennyDropScreen({Key? key}) : super(key: key);

  @override
  _PennyDropScreenState createState() => _PennyDropScreenState();
}

class _PennyDropScreenState extends State<PennyDropScreen> {
  bool visibleUser = true;
  bool visibleLoader = true;
  bool visibleLoaderText = true;

  @override
  void initState() {
    super.initState();
    startAccountVerification();
    Future.delayed(Duration(seconds: 2), () {
      if (this.mounted) {
        setState(() {
          visibleUser = false;
        });
      }
    });
  }

  void screenChange() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreen(),
        ),
      );
    });
  }

  /// Initiate Penny drop varification
  Future<void> startAccountVerification() async {
    final userDetail = context.read<AppStateProvider>().userDetails;
    final bankDetail = context.read<AppStateProvider>().userBankDetail;
    var param = Map<String, String>();
    param[ApiParams.cid] = userDetail?.profileDetails?.customerId ?? '';
    param[ApiParams.accountNum] = bankDetail?.acountNumber ?? '';
    param[ApiParams.fullName] = userDetail?.profileDetails?.fullName ?? '';
    param[ApiParams.ifscCode] = bankDetail?.ifscCode ?? '';
    param[ApiParams.bankName] = bankDetail?.bankName ?? '';
    param[ApiParams.branchName] = bankDetail?.branchnName ?? '';
    var pennyDropRes =
        await context.read<AppStateProvider>().pennyDropVarification(param);
    if (pennyDropRes.isSuccess) {
      AFSdk.logEvent(AFSdk.af_validateAccount, null);

      setState(() {
        visibleLoader = false;
        visibleLoaderText = false;
      });
      if ((userDetail?.userStage ?? 1) > 3) {
        Utils.showToast(msg: LanguageHelper.textBankDetailsUpdated);
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(pennyDropRes);
        });
      } else {
        screenChange();
      }
    } else {
      Navigator.of(context).pop(pennyDropRes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Header(
                backOnPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    // color: ColorsUtil.redColor,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: visibleLoader == true
                                  ? SpinKitRing(
                                      duration: Duration(milliseconds: 1200),
                                      color: ColorsUtil.blueColor,
                                      size: 60.0,
                                    )
                                  : Image.asset(
                                      LocalImages.green_sheild_tick,
                                      color: ColorsUtil.blueColor,
                                    )),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            visibleLoaderText == true
                                ? 'We’re verifying your details. Please wait ...'
                                : 'Verified Successfully! Redirecting ...',
                            maxLines: 1,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.black,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              visibleUser == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20, left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(33.0),
                            child: Image(
                              image: AssetImage(LocalImages.rama),
                              width: 66,
                              height: 66,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            ' Monexo is the Uber of Finance —Solid returns, robust risk migration & great team ',
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.lighterGrey,
                                fontSize: 14),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            ' — Ramanathan, Mumbai ',
                            maxLines: 1,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.black,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image(
                            image: AssetImage(LocalImages.question_check),
                            width: 60,
                            height: 60,
                          ),

                          // Stack(
                          //   children: [
                          //     FractionalTranslation(
                          //         translation: Offset(-0.2, -0.4),
                          //         child: Image(
                          //           image: AssetImage(
                          //               LocalImages.auto_invest1),
                          //           width: 66,
                          //           height: 66,
                          //         )),
                          //     FractionalTranslation(
                          //         translation: Offset(0.3, 0.0),
                          //         child: Image(
                          //           image: AssetImage(
                          //               LocalImages.auto_invest2),
                          //           width: 63,
                          //           height: 62,
                          //         )),
                          //   ],
                          // ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Auto-Invest allows you to find and fund loans automatically without logging into the platform!',
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Learn more about Auto Invest',
                                maxLines: 1,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    color: ColorsUtil.lighterGrey,
                                    fontSize: 14),
                              ),
                              Icon(
                                Icons.launch,
                                color: ColorsUtil.lighterGrey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
