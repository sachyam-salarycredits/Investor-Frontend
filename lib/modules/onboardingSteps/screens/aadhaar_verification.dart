import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/supporting_file/cashfree_kyc_api.dart';
import 'package:peerbridge/supporting_file/digilocker_kyc_api.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/user_preferences.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routes_management/routes_list.dart';
import '../../home/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AadhaarVerificationScreen extends StatefulWidget {
  const AadhaarVerificationScreen({Key? key}) : super(key: key);

  @override
  _AadhaarVerificationScreenState createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  bool isOcrDone = false;
  bool _isLoading = false;
  CashfreeKycData? cashfreeKycData;
  Map? aadharFrontDetail;
  Map? aadharBackDetail;
  int faceMatchScore = 0;
  var ip = "";

  @override
  void initState() {
    super.initState();
    Utils.getUserLocation(context).catchError((e) {
      print(e);
    });
    getIp();
  }

  Future<void> getIp() async {
    ip = await Utils.getIpAddress();
  }

  _sendEmail() {
    final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: 'lend@monexo.co');
    launchUrlString(_emailLaunchUri.toString());
  }

  void submitBtnAction() async {
    if (isOcrDone) {
      submitAadharDetails();
    } else {
      startDigilockerProcess();
    }
  }

  /// Primary path: consent-based Aadhaar verification via DigiLocker.
  Future<void> startDigilockerProcess() async {
    setLoading(true);
    final result = await DigilockerKycSession.runFlow(context, ip: ip);

    if (result == null) {
      setLoading(false);
      Utils.showToast(
          msg:
              'Unable to start DigiLocker verification. Please upload your Aadhaar photos instead.');
      return;
    }

    if (!result.success) {
      setLoading(false);
      Utils.showToast(
          msg: result.message.isNotEmpty
              ? result.message
              : LanguageHelper.textSomethingWentWrong);
      return;
    }

    AFSdk.logEvent(AFSdk.af_ekyc, null);
    final provider = context.read<AppStateProvider>();
    await provider.getStepsStatus();
    await provider.getCustomerDetails();
    setLoading(false);
    Utils.showAlert(
        context: context,
        msg: LanguageHelper.textEkycDone,
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
  }

  Future<void> startCashfreeKycProcess() async {
    final front = await FilePicker.platform.pickFiles(type: FileType.image);
    if (front == null || front.files.single.path == null) return;
    final back = await FilePicker.platform.pickFiles(type: FileType.image);
    if (back == null || back.files.single.path == null) return;
    final selfie = await FilePicker.platform.pickFiles(type: FileType.image);
    if (selfie == null || selfie.files.single.path == null) return;

    setLoading(true);
    final result = await CashfreeKycSession.runKycFlow(
      context,
      frontPath: front.files.single.path!,
      backPath: back.files.single.path!,
      selfiePath: selfie.files.single.path!,
    );
    setLoading(false);

    if (result == null) {
      Utils.showToast(msg: LanguageHelper.textSomethingWentWrong);
      return;
    }

    cashfreeKycData = result;
    aadharFrontDetail = result.frontFields;
    aadharBackDetail = result.backFields;
    faceMatchScore = result.faceMatchScore;

    if (faceMatchScore == 0) {
      Utils.showToast(msg: LanguageHelper.textNeedToScanFaceAgain);
      return;
    }

    setState(() {
      isOcrDone = true;
    });
    submitAadharDetails();
  }

  /// Submit Aadhar details
  Future<void> submitAadharDetails() async {
    setLoading(true);
    var locationData = await Utils.getUserLocation(context);

    var param = Map<String, String>();
    param[ApiParams.customerId] = (context.read<AppStateProvider>().customerId);

    if (locationData != null) {
      param[ApiParams.latitute] = "${locationData.latitude ?? 0.0}";
      param[ApiParams.longitute] = "${locationData.longitude ?? 0.0}";
    }
    param[ApiParams.customerId] = (context.read<AppStateProvider>().customerId);
    param[ApiParams.fullName] = aadharFrontDetail?[CashfreeKycSession.name];
    param[ApiParams.dateOfBirth] = aadharFrontDetail?[CashfreeKycSession.dob];
    param[ApiParams.gender] = aadharFrontDetail?[CashfreeKycSession.gender];
    param[ApiParams.aadharCardNumber] =
        aadharFrontDetail?[CashfreeKycSession.aadhaar];
    param[ApiParams.address] = aadharBackDetail?[CashfreeKycSession.address];
    param[ApiParams.faceMatch] =
        (cashfreeKycData?.live ?? false).toString();
    param[ApiParams.faceMatchScore] = faceMatchScore.toString();
    param[ApiParams.livenessScore] = cashfreeKycData?.livenessScore ?? '';
    param[ApiParams.ip] = ip;
    var files = Map<String, PlatformFile>();

    files[ApiParams.profileImage] =
        Utils.getPlatformFile(cashfreeKycData?.selfieUri ?? '')!;
    files[ApiParams.aadharFrontImage] =
        Utils.getPlatformFile(cashfreeKycData?.frontUri ?? '')!;
    files[ApiParams.aadharBackImage] =
        Utils.getPlatformFile(cashfreeKycData?.backUri ?? '')!;

    var submitRes =
        await context.read<AppStateProvider>().aadharSubmit(param, files);
    setLoading(false);
    // if (submitRes) {
    //   AFSdk.logEvent(AFSdk.af_ekyc, null);
    //   // context.pop();
    //   // Utils.showToast(msg: LanguageHelper.textEkycDone);
    //   Utils.showAlert(
    //       context: context,
    //       msg: LanguageHelper.textEkycDone,
    //       onTap: () {
    //         Navigator.push(
    //             context, MaterialPageRoute(builder: (context) => HomeScreen()));
    //       });
    // }
    if (submitRes) {
      AFSdk.logEvent(AFSdk.af_ekyc, null);
      // context.pop();
      // Utils.showToast(msg: LanguageHelper.textEkycDone);
      if (faceMatchScore < 75) {
        showDialog<void>(
          context: context,
          useRootNavigator: true,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'PeerBridge',
                style: TextStyle(
                  fontSize: 22,
                  color: ColorsUtil.blueColor,
                ),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    RichText(
                      // textAlign:
                      //     TextAlign
                      //         .justify,
                      text: TextSpan(
                        text:
                            'Your e-KYC is incomplete because the Selfie doesn`t match with the Aadhar image. Please send the self attested image of the Aadhar card to ',
                        style: TextStyle(
                          fontSize: 14,
                          color: ColorsUtil.black,
                          height: 1.5,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'lend@monexo.co',
                              style: TextStyle(
                                // height:
                                //     1.9,
                                color: ColorsUtil.green,
                                decoration: TextDecoration.underline,
                                decorationColor: ColorsUtil.green,
                                decorationThickness: 1.5,
                                height: 1.5,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _sendEmail),
                          TextSpan(
                            text: ' for completing KYC process.',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorsUtil.black,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('ok'),
                  onPressed: () {
                    context.pushNamed(RoutesName.SettingsScreen);
                  },
                ),
              ],
            );
          },
        );
        // Utils.showAlert(
        //     context: context,
        //     msg: 'Your KYC is incomplete because of improper face Match',
        //     onTap: () {
        //       context.pushNamed(RoutesName.SettingsScreen);
        //     });
      } else {
        Utils.showAlert(
            context: context,
            msg: LanguageHelper.textEkycDone,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            });
      }
    }
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
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Header(
                        backOnPressed: () {
                          context.pop();
                        },
                      ),
                      mainWidgets(context),
                      submitButton(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: RichText(
                          text: TextSpan(
                            text:
                                'NOTE : You can either upload your Aadhaar card or send us to ',
                            style: TextStyle(
                                height: 1.25,
                                fontFamily: CustomFonts.nunito,
                                fontSize: 16,
                                color: ColorsUtil.black,
                                fontWeight: FontWeight.w400),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'lend@monexo.co',
                                  style: TextStyle(
                                    color: ColorsUtil.green,
                                    decoration: TextDecoration.underline,
                                    decorationColor: ColorsUtil.green,
                                    decorationThickness: 1.5,
                                    height: 1.5,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _sendEmail),
                              TextSpan(
                                text: ' for completing Ekyc.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Header(
                                backOnPressed: () {
                                  context.pop();
                                },
                              ),
                              SizedBox(height: 50),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Center(
                                      child: Container(
                                        width: screenSize.width * .4,
                                        constraints:
                                            BoxConstraints(maxWidth: 500),
                                        child: Column(
                                          children: [
                                            mainWidgets(context),
                                            submitButton(context),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 20),
                                              child: RichText(
                                                text: TextSpan(
                                                  text:
                                                      'NOTE : You can either upload your Aadhaar card or send us to ',
                                                  style: TextStyle(
                                                      height: 1.25,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 16,
                                                      color: ColorsUtil.black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: 'lend@monexo.co',
                                                        style: TextStyle(
                                                          color: ColorsUtil.green,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              ColorsUtil.green,
                                                          decorationThickness:
                                                              1.5,
                                                          height: 1.5,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  _sendEmail),
                                                    TextSpan(
                                                      text:
                                                          ' for completing Ekyc.',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    return Container(
      margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aadhaar Verification',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 25,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Verify your Aadhaar instantly and securely via DigiLocker, or share your details by uploading front and back photos of your Aadhaar card.',
            textAlign: TextAlign.left,
            // maxLines: 3,
            style: TextStyle(
                height: 1.25,
                fontFamily: CustomFonts.nunito,
                fontSize: 17,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 25.0,
          ),
          Text(
            'Preferred method; keep your Aadhaar card handy to make a faster and easy form filling. You may also need to take a selfie for image verifications.',
            textAlign: TextAlign.left,
            // maxLines: 3,
            style: TextStyle(
                height: 1.25,
                fontFamily: CustomFonts.nunito,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: ColorsUtil.lighterGrey),
          ),
          SizedBox(
            height: 15.0,
          ),
          Visibility(
            visible: isOcrDone,
            child: Row(
              children: [
                Image.asset(
                  LocalImages.green_sheild_tick,
                  width: 30,
                  height: 30,
                  color: ColorsUtil.blueColor,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  'OCR completed. Click on submit to\ncomplete other steps.',
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.blueColor),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget submitButton(context) {
    return Column(
      children: [
        CustomButton(
          titleStr: getButtonTitle(),
          onPress: submitBtnAction,
        ),
        Visibility(
          visible: !isOcrDone,
          child: TextButton(
            onPressed: startCashfreeKycProcess,
            child: Text(
              'Upload Aadhaar photos instead',
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorsUtil.blueColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getButtonTitle() {
    if (!isOcrDone) {
      return 'Verify with DigiLocker';
    } else {
      return 'Submit and continue';
    }
  }
}
