import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/bankDetails/screens/bank_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/global_data.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/date_picker/custom_date_picker.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/steps_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:universal_html/html.dart';

import '../../../utils/constants.dart';

class PanVerification extends StatefulWidget {
  const PanVerification({Key? key}) : super(key: key);

  @override
  _PanVerificationState createState() => _PanVerificationState();
}

class _PanVerificationState extends State<PanVerification> {
  bool isTermCheck = false;
  bool isPanValid = false;
  bool isPanError = false;
  bool isDobValid = false;
  bool isDobError = false;
  bool isReferralValid = false;
  bool isReferralCode = false;
  var panController = TextEditingController();
  var dobController = TextEditingController();
  var referralController = TextEditingController();
  var selectedDate = DateTime(1980);
  bool _isLoading = false;
  int lastLength = 0;
  FocusNode _focus = FocusNode();
  bool isFocused = false;
  String? refferCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focus.addListener(_onFocusChange);
    SetRegistrationStatus();
    resetOnbaordingScreenStatus();
    if (Utils.isWeb) {
      // final storage = window.sessionStorage;
      // refferCode = storage['referCode'];
      setState(() {
        isReferralCode = true;
        referralController.text = refferCode ?? '';
      });
    }
  }
  Future<void> resetOnbaordingScreenStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('show_onboarding', true);
  }
  Future<void> SetRegistrationStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('set_registrationStatus', true);
  }
  void _onFocusChange() {
    isFocused = _focus.hasFocus;
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    panController.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  // Validation function for all fields
  bool checkValidation() {
    // PAN number validation
    if (!panController.text.isPanValid || panController.text == '') {
      setState(() {
        isPanError = true;
      });
      return false;
    }
    if (dobController.text == '') {
      Utils.showAlert(context: context, msg: LanguageHelper.textChooseDob);

      setState(() {
        isDobError = true;
      });
      return false;
    }
    if (!isTermCheck) {
      Utils.showAlert(context: context, msg: LanguageHelper.textTermsCondAgree);

      return false;
    }
    return true;
  }

  void submitBtnTap() async {
    applyReferralCode();
    if (checkValidation()) {
      setState(() {
        _isLoading = true;
      });
      var panDetail = await context.read<AppStateProvider>().getPanDetails(
          panController.text, dobController.text.replaceAll(' ', ''));
      setState(() {
        _isLoading = false;
      });
      if (panDetail != null) {
        context.pushNamed(RoutesName.PersonalDetail);
      }
    }
  }

  void startDatePicker(context) async {
    final todayDate = DateTime.now();
    final minDate = DateTime(1900);

    DatePicker.showDatePicker(
      context,
      pickerMode: DateTimePickerMode.date,
      minDateTime: minDate,
      maxDateTime: todayDate,
      initialDateTime: selectedDate,
      dateFormat: 'dd/MMMM/yyyy',
      locale: DateTimePickerLocale.en_us,
      onConfirm: changeDOB,
    );
  }

  void changeDOB(DateTime date, event) {
    FocusScope.of(context).unfocus();
    setState(() {
      selectedDate = date;
      var day = date.day.toString().padLeft(2, '0');
      var month = date.month.toString().padLeft(2, '0');
      var year = date.year;
      dobController.text = '$day/$month/$year';
      isDobValid = true;
      isDobError = false;
    });
  }

  void applyReferralCode() async {
    final referralCode = referralController.text;
    if (referralCode.length > 0) {
      var mapResult = await FlyyFlutterPlugin.verifyReferralCode(referralCode);
      print('Referral code response is ${mapResult.toString()}');
      if (mapResult["is_valid"]) {
        FlyyFlutterPlugin.setFlyyReferralCode(mapResult["referral_code"]);
      }
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
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'PAN Verification',
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
                              Header(
                                backOnPressed: () {
                                  context.pop();
                                },
                              ),
                              SizedBox(height: 50),
                              Expanded(
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      // color: ColorsUtil.redColor,
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
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.symmetric(
                                          //           horizontal: 15),
                                          //   child: Align(
                                          //     alignment: Alignment.centerLeft,
                                          //     child: Text(
                                          //       'PAN Verification',
                                          //       style: TextStyle(
                                          //         fontFamily:
                                          //             CustomFonts.nunito,
                                          //         fontWeight: FontWeight.bold,
                                          //         fontSize: 20,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          mainWidgets(context)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: Container(
                              //       width: screenSize.width * .4,
                              //       constraints: BoxConstraints(maxWidth: 500),
                              //       child: Center(child: mainWidgets(context))),
                              // )
                            ],
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
                                //image: AssetImage(LocalImages.girl),
                                image: AssetImage(LocalImages.girl),
                              ),
                              Container(
                                color: ColorsUtil.blueColor.withAlpha(200),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.end,
                                      // crossAxisAlignment: CrossAxisAlignment.center,
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
                                                // mainAxisAlignment:
                                                //     MainAxisAlignment.center,
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
                                                    'Solid returns, robust risk migration & great team ”',
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
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputWidget(
                    // focusNode: _focus,
                    // isFocused: panController.hasListeners,
                    controller: panController,
                    isValid: isPanValid,
                    isError: isPanError,
                    maxLength: 10,
                    leftIcon: Image(
                      width: 12,
                      height: 18,
                      image: AssetImage(LocalImages.pan_dots),
                    ),
                    heading: 'PAN card number',
                    hintStr: "ABCDE1234D",
                    alertStr: isPanError ? "Please enter valid Pan Number" : "",
                    textCapitalization: TextCapitalization.characters,
                    autoCaps: true,
                    onChange: (String input) {
                      setState(() {
                        isPanValid = input.isPanValid;
                        isPanError = false;
                      });
                    },
                    rightIcon: isPanError
                        ? Image(
                            width: 25,
                            height: 22,
                            image: AssetImage(LocalImages.caution_icon),
                          )
                        : null,
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    // focusNode: _focus,
                    // isFocused: dobController.,
                    controller: dobController,
                    isValid: isDobValid,
                    isError: isDobError,
                    onChange: (val) {
                      try {
                        var currentPos = dobController.selection.baseOffset;
                        //checking for day
                        if (currentPos == 2) {
                          //user removing the test
                          if (lastLength == 3) {
                            dobController.value = TextEditingValue(
                                text: val.substring(0, 1),
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 1)));
                            lastLength = 1;
                          } else {
                            dobController.value = TextEditingValue(
                                text: val + "/",
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 3)));
                            lastLength = 3;
                          }
                        }
                        //checking for month
                        if (currentPos == 5) {
                          //user removing the test
                          if (lastLength == 6) {
                            dobController.value = TextEditingValue(
                                text: val.substring(0, 4),
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 4)));
                            lastLength = 4;
                          } else {
                            dobController.value = TextEditingValue(
                                text: val + "/",
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 6)));
                            lastLength = 6;
                          }
                        }

                        var formatter = DateFormat("dd/MM/yyyy");
                        var date = formatter.parse(val);
                        if (date.month <= 12 &&
                            date.month > 0 &&
                            date.day > 0 &&
                            date.day <= 31 &&
                            date.year > 1900 &&
                            date.year.toString().length == 4 &&
                            date.year <= DateTime.now().year) {
                          selectedDate = date;
                          isDobValid = true;
                          setState(() {});
                        }
                      } catch (e) {
                        isDobValid = false;
                        setState(() {});
                      }
                    },
                    maxLength: 10,
                    rightIcon: Tooltip(
                      message: "Show Calendar",
                      child: IconButton(
                        onPressed: () {
                          startDatePicker(context);
                        },
                        icon: Icon(
                          CupertinoIcons.calendar_today,
                          color: ColorsUtil.blueColor,
                        ),
                      ),
                    ),
                    hintStr: 'DD/MM/YYYY',
                    heading: 'Date of Birth / Incorporation',
                    isEnable: true,
                    alertColor: ColorsUtil.lightBlack,
                    alertStr:
                        "In case of non-individuals date of incorporation as per PAN",
                    // !isDobValid && dobController.text.isNotEmpty
                    //     ? "Date entry should be in DD-MM-YYYY format"
                    //     : "",
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // SizedBox(height: 40),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                if (GlobalData.referralCode != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Image(
                            width: 15,
                            height: 15,
                            image: AssetImage(LocalImages.referral_check),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Referral Code",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: CustomFonts.nunito,
                                fontSize: 14),
                          ),
                          SizedBox(width: 4),
                          Text(
                            GlobalData.referralCode ?? 'ABC',
                            style: TextStyle(
                              color: ColorsUtil.blueColor,
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'applied',
                            style: TextStyle(
                              color: ColorsUtil.black,
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                if (GlobalData.referralCode == null)
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Checkbox(
                              side: BorderSide(
                                  width: 1, color: ColorsUtil.greyPlaceHolder),
                              splashRadius: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                              checkColor: Colors.white,
                              activeColor: ColorsUtil.blueColor,
                              value: isReferralCode,
                              onChanged: (bool? value) {
                                setState(() {
                                  isReferralCode = value!;
                                });
                              },
                            ),
                            Text(
                              "Have a referral code?",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isReferralCode,
                        child: InputWidget(
                          controller: referralController,
                          isValid: isReferralValid,
                          isError: false,
                          heading: 'Referral Code',
                          hintStr: "ABCDEF6",
                          textCapitalization: TextCapitalization.characters,
                          onChange: (String input) {
                            setState(() {
                              isReferralValid = input.length >= 6;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 5),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        side: BorderSide(
                            width: 1, color: ColorsUtil.greyPlaceHolder),
                        splashRadius: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                        checkColor: Colors.white,
                        activeColor: ColorsUtil.blueColor,
                        value: isTermCheck,
                        onChanged: (bool? value) {
                          setState(() {
                            isTermCheck = value!;
                          });
                        },
                      ),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            text:
                                "By entering the details, you agree with our ",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: CustomFonts.nunito,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'terms & conditions',
                                style: TextStyle(
                                  color: ColorsUtil.blueColorText,
                                  fontFamily: CustomFonts.nunito,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (Utils.isWeb) {
                                      Utils.launchURL(APIUrls.termsCondition);
                                    } else {
                                      context
                                          .pushNamed(RoutesName.TermsWebView);
                                    }

                                    // context.pushNamed(RoutesName.TermsWebView);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  titleStr: 'Register',
                  onPress: submitBtnTap,
                ),
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account ?',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w500,
                          color: ColorsUtil.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: ' Login here',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushNamed(RoutesName.Login);
                              },
                            style: TextStyle(
                              color: ColorsUtil.blueColorText,
                              // decoration: TextDecoration.underline
                            )),
                      ],
                    ),
                  ),
                ),
                // CustomButton(
                //   titleStr: 'Existing User? Login Instead',
                //   borderColor: ColorsUtil.blueColor,
                //   textColor: ColorsUtil.blueColor,
                //   bgColor: ColorsUtil.white,
                //   onPress: () {
                //     applyReferralCode();
                //     context.pushNamed(RoutesName.Login);
                //   },
                // ),
                // SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }
}
