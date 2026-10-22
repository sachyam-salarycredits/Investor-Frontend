import 'dart:convert';
import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/BankDetailSIPModel.dart';
import 'package:peerbridge/modules/onboardingSteps/models/sip_details.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/app_router.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/supporting_file/web_utils.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/checkbox_widget.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:peerbridge/widgets/tpv_registered_bank_banner.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class _ThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const RectangularSliderValueIndicatorShape();

  const _ThumbShape();

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      textDirection: textDirection,
    );
    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: 3,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );
  }
}

class SIPScreen extends StatefulWidget {
  const SIPScreen({Key? key}) : super(key: key);

  @override
  _SIPScreenState createState() => _SIPScreenState();
}

class _SIPScreenState extends State<SIPScreen> {
  final double min = 12;
  final double max = 120;
  double sliderValue = 24;
  String amountError = "";
  bool isAmountValid = false;
  bool isAmountError = false;
  bool isTermCondition = false;
  bool _isLoading = false;
  var amountController = TextEditingController();
  OldSipDetail? previousSip;

  //used to check user has inititaled the sip or not
  bool isSipCreated = false;
  bool isDebitCardSelected = false;
  // bool isChequeSelected = false;
  bool isNetBankingSelected = false;
  BankDetailSipModel? bankDetailData;

  FocusNode _focus = FocusNode();
  bool isFocused = false;
  bool isUpiValid = false;
  bool isUpiError = false;
  bool isUPISelected = false;
  var upiController = TextEditingController();
  var dateController = TextEditingController();
  String datetError = "";
  bool isDateError = false;
  bool isDateValid = false;
  bool switchValue = true;
  var isOtpVerified = false;
  String auth = '';
  var advanceStepsList;

  @override
  void initState() {
    super.initState();
    getOptionVisibility();
    getOldSipDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRegisteredUpiFromProfile());
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    upiController.dispose();
    _focus.dispose();

    super.dispose();
    // Clean up the controller when the widget is disposed.
  }

  Future<void> getOldSipDetail() async {
    setLoading(true);
    var sipDetail = await context.read<AppStateProvider>().getPreviousSip();
    setLoading(false);

    if (sipDetail != null) {
      amountController.text = "${sipDetail.amountMaximum ?? 0}";
      dateController.text = sipDetail.presdatevalue ?? '';
      auth = sipDetail.authMode ?? '';
      switchValue = sipDetail.sipEnable ?? false;
      setState(() {
        previousSip = sipDetail;
        final value = (sipDetail.monthDuration ?? '$min').doubleValue();
        sliderValue = value < min ? min : value;
        isAmountValid = checkAmountValidation();
        isAmountError = !isAmountValid;
        isDateValid = checkDateValidation();
        isDateError = !isDateValid;
        if (auth == 'netbanking') {
          isNetBankingSelected = true;
        } else if (auth == 'debitCard') {
          isDebitCardSelected = true;
        } else {
          isUPISelected = true;
        }
      });
    }
  }

  bool checkDateValidation() {
    if (dateController.text.doubleValue() < 1 ||
        dateController.text.doubleValue() > 28) {
      setState(() {
        datetError = "Please Enter Date between 1st to 28th";
        isDateError = true;
      });
      return false;
    }

    setState(() {
      datetError = "";
    });

    return true;
  }

  bool checkAmountValidation() {
    if (amountController.text.doubleValue() < 1000) {
      setState(() {
        amountError = "Amount cannot be less than 1000";
        isAmountError = true;
      });
      return false;
    }

    if (amountController.text.doubleValue() > 1000000) {
      setState(() {
        amountError = "Amount cannot greater than 10,00,000";
        isAmountError = true;
      });
      return false;
    }

    if (!(amountController.text.doubleValue() % 1000 == 0)) {
      setState(() {
        amountError = "Amount must be in multiples of 1000";
        isAmountError = true;
      });

      return false;
    }

    setState(() {
      amountError = "";
    });

    return true;
  }

  BankAccountDetails? get _registeredBank =>
      context.read<AppStateProvider>().userDetails?.bankAccountDetails;

  bool get _usesRegisteredUpiCollect =>
      (_registeredBank?.upiId.trim().isNotEmpty ?? false);

  void _syncRegisteredUpiFromProfile() {
    final registeredUpi = _registeredBank?.upiId.trim() ?? '';
    if (registeredUpi.isNotEmpty) {
      upiController.text = registeredUpi;
      isUpiValid = registeredUpi.isUpiIdValid;
      if (mounted) setState(() {});
    }
  }

  String _effectiveUpiId() {
    final entered = upiController.text.trim();
    if (entered.isNotEmpty) {
      return entered;
    }
    return _registeredBank?.upiId.trim() ?? '';
  }

  Future<bool> _persistUpiIfNeeded(AppStateProvider provider) async {
    final upi = upiController.text.trim();
    if (!upi.isUpiIdValid) {
      return false;
    }
    final profileUpi = _registeredBank?.upiId.trim() ?? '';
    if (upi == profileUpi) {
      return true;
    }
    return provider.saveProfileUpi(upi);
  }

  Widget _upiInputSection() {
    final hasRegisteredUpi = _usesRegisteredUpiCollect;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InputWidget(
        focusNode: _focus,
        isFocused: isFocused,
        isUPI: true,
        isEditable: !hasRegisteredUpi,
        controller: upiController,
        keyboardType: TextInputType.emailAddress,
        isValid: isUpiValid,
        isError: isUpiError,
        alertStr: isUpiError ? LanguageHelper.textInvalidUpiId : '',
        hintStr: hasRegisteredUpi
            ? LanguageHelper.textTpvRegisteredUpi
            : LanguageHelper.textEnterUpiId,
        heading: hasRegisteredUpi
            ? LanguageHelper.textTpvRegisteredUpi
            : LanguageHelper.textEnterUpiLinkedToBank,
        horizontalMargin: 0,
        onChange: hasRegisteredUpi
            ? (_) {}
            : (String input) {
                setState(() {
                  isUpiValid = input.trim().isUpiIdValid;
                  isUpiError = input.trim().isNotEmpty && !isUpiValid;
                });
              },
      ),
    );
  }

  /// Check validation
  bool checkValidation() {
    if (!(checkAmountValidation() && checkDateValidation())) {
      return false;
    }

    if (!(isDebitCardSelected || isNetBankingSelected || isUPISelected)) {
      Utils.showAlert(context: context, msg: LanguageHelper.textSelectOption);
      return false;
    }
    if (isUPISelected && !_effectiveUpiId().isUpiIdValid) {
      setState(() {
        isUpiError = true;
      });
      Utils.showAlert(context: context, msg: LanguageHelper.textInvalidUpiId);
      return false;
    }
    return true;
  }

  /// Create SIP
  static const _defaultSipReturnUrl = 'https://www.monexo.co/in/';

  Future<void> _openSipWebView(SipDetails sipDetail) async {
    final checkoutUrl = sipDetail.redirect?.url ?? '';
    final returnUrl = sipDetail.redirect?.returnUrl?.trim();
    final effectiveReturnUrl = (returnUrl != null && returnUrl.isNotEmpty)
        ? returnUrl
        : _defaultSipReturnUrl;

    if (Utils.isWeb) {
      openWebWindow(checkoutUrl);
    } else {
      context.pushNamed(
        RoutesName.SipWebView,
        extra: {
          Constants.url: checkoutUrl,
          Constants.returnUrl: effectiveReturnUrl,
          Constants.amount: amountController.text,
        },
      );
    }
  }

  Future<void> createSip() async {
    if (!checkValidation()) {
      return;
    }
    Constants.sipAmount = amountController.text.doubleValue().ceil();
    Constants.sipTenure = sliderValue.ceil();
    Constants.sipDate = dateController.text;
    Constants.sipPaymnentMethod = auth;
    print('lll');
    print(sliderValue.ceil());
    print(Constants.sipTenure);

    if (isUPISelected) {
      auth = 'upi';
    }

    setLoading(true);
    final provider = context.read<AppStateProvider>();
    final userDetail = provider.userDetails;
    final bankDetails = userDetail?.bankAccountDetails;
    final ifscCode = bankDetails?.ifscCode ?? '';
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = provider.customerId;
    param[ApiParams.amountMaximum] =
        amountController.text.doubleValue().ceil();
    param[ApiParams.monthDuration] = sliderValue.ceil();
    param[ApiParams.debtorAccountName] =
        userDetail?.profileDetails?.fullName ?? '';
    param[ApiParams.debtorAccountNumber] = bankDetails?.accountNumber ?? '';
    param[ApiParams.debtorAgentCode] =
        ifscCode.length > 4 ? ifscCode.substring(0, 4) : '';
    param[ApiParams.debtorEmail] = userDetail?.profileDetails?.email ?? '';
    param[ApiParams.authMode] = auth;
    param[ApiParams.dateValue] = dateController.text;
    if (isUPISelected) {
      final saved = await _persistUpiIfNeeded(provider);
      if (!saved) {
        setLoading(false);
        Utils.showAlert(
            context: context, msg: LanguageHelper.textInvalidUpiId);
        return;
      }
      final upiId = _effectiveUpiId();
      param['upi_id'] = upiId;
      Constants.sipUpiId = upiId;
    }

    print(param);
    var result = await provider.createSip(param);
    setLoading(false);

    isSipCreated = true;
    if (result.errorMessage != null && result.errorMessage!.isNotEmpty) {
      Utils.showAlert(context: context, msg: result.errorMessage!);
      return;
    }
    if (result.sip != null) {
      await _openSipWebView(result.sip!);
    }
  }

  Future<void> getOptionVisibility() async {
    setLoading(true);
    await context.read<AppStateProvider>().sipOptionVisibility();
    bankDetailData = context.read<AppStateProvider>().bankDetailData;
    // print('lkll ${bankDetailData?.data?.variantApiNetbanking}');
    setLoading(false);
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification(bool isSwitch) async {
    if (!isSwitch && !checkValidation()) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => switchValue
          ? OtpVerificationWidget(
              onFailed: () {
                // context.pop();

                if (previousSip?.sipEnable != null) {
                  setState(() {
                    switchValue = previousSip?.sipEnable ?? false;
                  });
                }
              },
              onVerified: () {
                setState(() {
                  print('not sip one dialog otp');
                  updateSipSwitch();
                });
              },
            )
          : OtpVerificationWidget(
              isSipOTP: true,
              onFailed: () {
                if (previousSip?.sipEnable != null) {
                  setState(() {
                    switchValue = previousSip?.sipEnable ?? false;
                  });
                }
              },
              onVerified: () {
                setState(() {
                  print('sip one dialog otp');
                  updateSipSwitch();
                });
              },
            ),
    );
  }

  // Update Sip Switch
  Future<void> updateSipSwitch() async {
    setLoading(true);
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.sipFlag] = switchValue;
    param[ApiParams.authSipMode] = auth;
    // isDebitCardSelected ? 'debitcard' : 'netbanking';
    var updateSwitch =
        await context.read<AppStateProvider>().updateSipSwitch(param);
    setLoading(false);
    setState(() {
      isOtpVerified = false;
    });
    if (updateSwitch) {
      print('after togggle');
      getOldSipDetail();
      context.read<AppStateProvider>().getCustomerDetails();
    } else {
      if (previousSip != null) {
        setState(() {
          switchValue = previousSip!.sipEnable ?? false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Monthly SIP',
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
                    if (isSipCreated) {
                      context.read<AppStateProvider>().getStepsStatus();
                    }

                    Navigator.of(context).maybePop();
                  },
                ),
                actions: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: FlutterSwitch(
                          activeColor: ColorsUtil.white,
                          toggleColor: ColorsUtil.blueColor,
                          inactiveToggleColor: ColorsUtil.lightGrey,
                          width: 50.0,
                          height: 25.0,
                          toggleSize: 20.0,
                          value: switchValue,
                          borderRadius: 30.0,
                          onToggle: (val) {
                            // setState(() {
                            //   switchValue = val;
                            // });
                            if (!switchValue) {
                              setState(() {
                                switchValue = val;
                              });
                              startOtpVerification(true);
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Dialog(
                                  child: Container(
                                    width: 220,
                                    child: ListView(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(20),
                                      //  mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Cancel Monthly SIP?',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Are you sure you want to cancel the Monthly SIP?\nThe ongoing SIP (if any) will be terminated and you cannot reverse this actions.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: CustomFonts.nunito,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        CustomButton(
                                          bgColor: ColorsUtil.white,
                                          borderColor: ColorsUtil.blueColor,
                                          titleStr: "Yes, Cancel",
                                          textColor: ColorsUtil.blueColor,
                                          // isLoader: isLoading,
                                          onPress: () {
                                            switchValue = val;
                                            startOtpVerification(true);
                                            setState(() {});
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        CustomButton(
                                          bgColor: ColorsUtil.blueColor,
                                          textColor: ColorsUtil.white,
                                          titleStr: "No, Keep Active",
                                          onPress: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                            // Navigator.pop(context);
                                            // widget.onFailed();
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            // startOtpVerification(true);
                            // debugPrint(switchValue.toString());
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )
            : null,
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        child: RichText(
                          text: TextSpan(
                            text: "\"Systematic Investment Plan\"",
                            style: TextStyle(
                              color: ColorsUtil.blueColor,
                              fontWeight: FontWeight.w900,
                              fontFamily: CustomFonts.nunito,
                              fontSize: 15.0,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    ' - Build a habit of investing every month.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: ColorsUtil.blueColor,
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      mainWidgets(context),
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
                                  if (isSipCreated) {
                                    context
                                        .read<AppStateProvider>()
                                        .getStepsStatus();
                                  }
                                  Navigator.of(context).maybePop();
                                },
                              ),
                              SizedBox(height: 50),
                              Expanded(
                                child: Container(
                                  child: Center(
                                    child: Container(
                                      width: screenSize.width * .4,
                                      constraints:
                                          BoxConstraints(maxWidth: 500),
                                      child: Column(
                                        children: [
                                          TitleHeader(
                                            titleStr: 'Monthly SIP',
                                            desStr:
                                                '"Systematic Investment Plan" - Build a habit of investing every month.',
                                            isVisibleSwitch: true,
                                            switchValue: switchValue,
                                            onChange: (val) {
                                              if (!switchValue) {
                                                setState(() {
                                                  switchValue = val;
                                                });
                                                startOtpVerification(true);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) => Dialog(
                                                    child: Container(
                                                      width: 220,
                                                      child: ListView(
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        //  mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Cancel Monthly SIP?',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(
                                                            'Are you sure you want to cancel the Monthly SIP?\nThe ongoing SIP (if any) will be terminated and you cannot reverse this actions.',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          SizedBox(height: 20),
                                                          CustomButton(
                                                            bgColor: ColorsUtil
                                                                .white,
                                                            borderColor:
                                                                ColorsUtil
                                                                    .blueColor,
                                                            titleStr:
                                                                "Yes, Cancel",
                                                            textColor:
                                                                ColorsUtil
                                                                    .blueColor,
                                                            // isLoader: isLoading,
                                                            onPress: () {
                                                              switchValue = val;
                                                              startOtpVerification(
                                                                  true);
                                                              setState(() {});
                                                            },
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          CustomButton(
                                                            bgColor: ColorsUtil
                                                                .blueColor,
                                                            textColor:
                                                                ColorsUtil
                                                                    .white,
                                                            titleStr:
                                                                "No, Keep Active",
                                                            onPress: () {
                                                              setState(() {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                              // Navigator.pop(context);
                                                              // widget.onFailed();
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          mainWidgets(context),
                                        ],
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
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputWidget(
                    prefixText: "₹ ",
                    leftIcon: Image.asset(LocalImages.rupee_sign),
                    controller: amountController,
                    hintStr: "Enter Amount",
                    heading: "Enter Amount",
                    keyboardType: TextInputType.number,
                    isValid: isAmountValid,
                    isError: isAmountError,
                    alertStr: amountError,
                    horizontalMargin: 15,
                    onChange: (String input) {
                      setState(() {
                        isAmountValid = checkAmountValidation();
                        isAmountError = !isAmountValid;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duration',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              color: ColorsUtil.blueColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Please set duration for SIP',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorsUtil.blueColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: modelBuilder(
                            ['${min.ceil()} month', '${max.ceil()} month'],
                            (index, label) {
                          final isSelected = index <= sliderValue;
                          return buildLabel(
                              label: label.toString(),
                              width: 0,
                              color: ColorsUtil.blueColor);
                        })),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      inactiveTrackColor: ColorsUtil.greyTabColor,
                      activeTrackColor: ColorsUtil.blueColor,
                      overlayColor: Colors.transparent,
                      thumbColor: ColorsUtil.thumbSliderColor,
                      activeTickMarkColor: Colors.transparent,
                      inactiveTickMarkColor: Colors.transparent,
                      valueIndicatorColor: ColorsUtil.circleGrey,
                      valueIndicatorTextStyle: TextStyle(
                        color: ColorsUtil.greenText,
                        fontFamily: CustomFonts.nunito,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      showValueIndicator: ShowValueIndicator.never,
                      thumbShape: const _ThumbShape(),
                    ),
                    // SliderThemeData(
                    //     inactiveTrackColor: Colors.green.shade100,
                    //     activeTrackColor: ColorsUtil.greenColor,
                    //     overlayColor: Colors.transparent,
                    //     thumbColor: ColorsUtil.greenColor,
                    //     activeTickMarkColor: Colors.transparent,
                    //     inactiveTickMarkColor: Colors.transparent,
                    //     valueIndicatorColor: ColorsUtil.greenColor,
                    //     showValueIndicator: ShowValueIndicator.always),
                    child: Slider(
                        value: sliderValue,
                        min: min,
                        max: max,
                        divisions: 120,
                        label: sliderValue.ceil().toString(),
                        onChanged: (value) =>
                            setState(() => this.sliderValue = value)),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    // padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            'Select the date when the amount is deducted from your bank account',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: ColorsUtil.blueColor),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InputWidget(
                          controller: dateController,
                          isValid: isDateValid,
                          isError: isDateError,
                          maxLength: 2,

                          heading: 'Enter a date between 1st to 28th',
                          hintStr: "Enter a date between 1st to 28th",
                          alertStr: datetError,
                          // textCapitalization: TextCapitalization.characters,
                          autoCaps: true,
                          keyboardType: TextInputType.number,
                          onChange: (String input) {
                            setState(() {
                              // isDateValid = checkDateValidation();
                              // isDateError = false;
                              isDateValid = checkDateValidation();
                              isDateError = !isDateValid;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Note: The SIP registration process take 3 working days. Your 1st  SIP activation debit to your registered bank will happen  on 4th working day. Successive SIP debits to you bank account will be on the date selected by you.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: CustomFonts.nunito,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.blueColor),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: TpvRegisteredBankBanner(
                      bankName: context
                              .read<AppStateProvider>()
                              .userDetails
                              ?.bankAccountDetails
                              ?.bankName ??
                          '',
                      accountNumber: context
                              .read<AppStateProvider>()
                              .userDetails
                              ?.bankAccountDetails
                              ?.accountNumber ??
                          '',
                      upiId: context
                          .read<AppStateProvider>()
                          .userDetails
                          ?.bankAccountDetails
                          ?.upiId,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select payment method',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorsUtil.blueColor),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            Visibility(
                              visible: bankDetailData
                                      ?.data?.variantApiUpiCashfree ??
                                  false,
                              child: InkWell(
                              onTap: () {
                                setState(() {
                                  isUPISelected = !isUPISelected;
                                  isNetBankingSelected = false;
                                  isDebitCardSelected = false;
                                  auth = isUPISelected ? 'upi' : '';

                                  // amountController.text = '';
                                  // isAmountError = false;
                                  // isAmountValid = false;
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            // widget.isSelected
                                            //     ? ColorsUtil.blueColor
                                            //     :
                                            ColorsUtil.lightestGrey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color:
                                        // widget.isSelected
                                        //     ? Colors.blue.shade50
                                        //     :
                                        ColorsUtil.lightestGrey,
                                  ),
                                  height: 56,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Visibility(
                                              child: Theme(
                                            data: Theme.of(context).copyWith(
                                              disabledColor:
                                                  ColorsUtil.blueColor,
                                            ),
                                            child: Container(
                                              height: 22,
                                              width: 22,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          ColorsUtil.blueColor,
                                                      // widget.isSelected
                                                      //     ? ColorsUtil.blueColor
                                                      //     : ColorsUtil.lighterGrey,
                                                      width: 1.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          60)),
                                              child: Center(
                                                child: Container(
                                                  height: 16,
                                                  width: 16,
                                                  decoration: BoxDecoration(
                                                      color: isUPISelected
                                                          ? ColorsUtil.blueColor
                                                          : ColorsUtil
                                                              .lightestGrey,
                                                      border: Border.all(
                                                          color: isUPISelected
                                                              ? ColorsUtil.white
                                                              : ColorsUtil
                                                                  .lightestGrey,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60)),
                                                ),
                                              ),
                                            ),
                                          )),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'UPI',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontSize: 15,
                                                    color: isUPISelected
                                                        ? ColorsUtil.blueColor
                                                        : ColorsUtil.black,
                                                    fontWeight: isUPISelected
                                                        ? FontWeight.w700
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 4),
                                                  child: Text(
                                                    '(Recommended)',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 11,
                                                      color: ColorsUtil
                                                          .lighterGrey,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                            ),
                            Visibility(
                              visible: isUPISelected,
                              child: _upiInputSection(),
                            ),
                            SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                        Visibility(
                          visible: bankDetailData?.data?.variantApiDebitcard ??
                              false,
                          child: CheckBoxWidget(
                            titleStr: 'Debit Card',
                            isSelected: isDebitCardSelected,
                            onPress: () {
                              setState(() {
                                isDebitCardSelected = !isDebitCardSelected;
                                isNetBankingSelected = false;
                                isUPISelected = false;

                                auth = isDebitCardSelected ? 'debitCard' : '';
                                // amountController.text = '';
                                // isAmountError = false;
                                // isAmountValid = false;
                              });
                            },
                          ),
                        ),
                        Visibility(
                          visible: bankDetailData?.data?.variantApiNetbanking ??
                              false,
                          child: CheckBoxWidget(
                            titleStr: 'Net Banking',
                            isSelected: isNetBankingSelected,
                            onPress: () {
                              setState(() {
                                isNetBankingSelected = !isNetBankingSelected;
                                isDebitCardSelected = false;
                                isUPISelected = false;
                                auth = isNetBankingSelected ? 'netbanking' : '';
                                // amountController.text = '';
                                // isAmountError = false;
                                // isAmountValid = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Container(
              //   child: Row(
              //     children: [
              //       Checkbox(
              //         checkColor: Colors.white,
              //         activeColor: ColorsUtil.blueColor,
              //         value: isTermCondition,
              //         onChanged: (bool? value) {
              //           setState(() {
              //             isTermCondition = value!;
              //           });
              //         },
              //       ),
              //       Flexible(
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 8.0, right: 15),
              //           child: RichText(
              //             text: TextSpan(
              //               text: "By entering the details, you agree with our ",
              //               style: TextStyle(
              //                 color: Colors.black,
              //                 fontFamily: CustomFonts.nunito,
              //               ),
              //               children: <TextSpan>[
              //                 TextSpan(
              //                   text: 'terms & conditions',
              //                   style: TextStyle(
              //                     color: ColorsUtil.blueColor,
              //                     fontFamily: CustomFonts.nunito,
              //                     decoration: TextDecoration.underline,
              //                   ),
              //                   recognizer: TapGestureRecognizer()
              //                     ..onTap = () {
              //                       if (Utils.isWeb) {
              //                         Utils.launchURL(APIUrls.termsCondition);
              //                       } else {
              //                         context.pushNamed(RoutesName.TermsWebView);
              //                       }
              //                       // context.pushNamed(RoutesName.TermsWebView);
              //                     },
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 35),
              CustomButton(
                titleStr: 'Save & Verify E-Mandate',
                onPress: createSip,
                // onPress: () {
                //   context.pushNamed(RoutesName.UPIScreen1);
                // },
              ),
              SizedBox(
                height: 25,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildLabel({
    required String label,
    required double width,
    required Color color,
  }) =>
      Container(
        // width: width,
        // child: label == '64 Months'
        //     ? Container(
        //         height: 35,
        //         padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        //         margin: EdgeInsets.symmetric(horizontal: 4),
        //         decoration: BoxDecoration(
        //             color: ColorsUtil.lightestGrey,
        //             borderRadius: BorderRadius.all(Radius.circular(15))),
        //         child: Text(
        //           '${sliderValue.toInt().toString()} Months',
        //           style: TextStyle(
        //                   fontFamily: CustomFonts.roboto,
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500)
        //               .copyWith(color: ColorsUtil.greenColor),
        //         ),
        //       )
        //     :
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            label,
            style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    fontSize: 12,
                    fontWeight: FontWeight.w400)
                .copyWith(color: color),
          ),
        ),
      );

  static List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();
}

class doneSIPDialog extends StatelessWidget {
  const doneSIPDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 220,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(20),
          //  mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Monthly SIP cancelled and turned off',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your monthly SIP has been successfully cancelled (if any) and turned off.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 30,
              height: 60,
              margin: EdgeInsets.all(8),
              child: CustomButton(
                horizontalMargin: 0,
                bgColor: ColorsUtil.blueColor,
                borderColor: ColorsUtil.blueColor,
                titleStr: "Done",
                textColor: ColorsUtil.white,
                // isLoader: isLoading,
                onPress: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String base64StringEncodeOriginal() {
    if (this.trim().isEmpty == true) return '';
    String lowerCasedString = (this);
    var bytes = utf8.encode(lowerCasedString);
    return base64.encode(bytes);
  }

  String base64StringDecodeOriginal() {
    if (this.trim().isEmpty == true) return '';
    String lowerCasedString = (this);
    // var bytes = utf8.decode(lowerCasedString);
    // return base64.encode(bytes);
    return utf8.decode(base64.decode(lowerCasedString));
  }
}
