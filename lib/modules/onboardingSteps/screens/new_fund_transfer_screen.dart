import 'dart:io';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashFree_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashfree_web_token_response.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/fund_transfer_process_screen.dart';
import 'package:peerbridge/supporting_file/cashfree_api.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/enums.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/image_picker.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/user_preferences.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/checkbox_widget.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:peerbridge/widgets/tpv_registered_bank_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/modules/bankDetails/screens/welcome_screen.dart';

import '../../../utils/constants.dart';

class NewFundTransferScreen extends StatefulWidget {
  NewFundTransferScreen({
    Key? key,
  }) : super(key: key);

  @override
  _NewFundTransferScreenState createState() => _NewFundTransferScreenState();
}

class _NewFundTransferScreenState extends State<NewFundTransferScreen> {
  String? fileName;
  PlatformFile? selectedFile;

  var iFSCCodeController = TextEditingController();
  var accountNoController = TextEditingController();
  var chequeNoController = TextEditingController();
  var amountController = TextEditingController();
  var upiController = TextEditingController();

  PaymentOptions selectedPaymentMode = CashFreeApi.paymentTypes.first;
  bool isUPISelected = false;
  // bool isChequeSelected = false;
  bool isNetBankingSelected = false;
  bool verifyVisible = false;
  bool isAmountValid = false;
  bool isAmountError = false;
  bool isChequeValid = false;
  bool isChequeError = false;
  bool isUpiValid = false;
  bool isUpiError = false;
  bool _isLoading = false;
  bool isBankCodeAvailable = true;
  CashFreeDetail? cashFreeDetail;
  String orderId = '';
  int netBankingCharge = 15;

  FocusNode _focus = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    amountController.text = '10000';
    _focus.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRegisteredUpiFromProfile());
    getFundDetails();
    // getCashFreeToken();
    // final userData = context.read<AppStateProvider>().userDetails;
    // iFSCCodeController.text = userData?.bankAccountDetails?.ifscCode ?? '';
    // accountNoController.text =
    //     userData?.bankAccountDetails?.accountNumber ?? '';
  }

  void getFundDetails() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<AppStateProvider>().getUserFundDetails();
    setState(() {
      _isLoading = false;
    });
  }

  void _onFocusChange() {
    isFocused = _focus.hasFocus;
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
    setState(() {});
  }

  bool get _isNetBanking => isNetBankingSelected;

  PaymentOptions get _netBankingOption => CashFreeApiWeb.paymentTypes
      .firstWhere((option) => option.type == PaymentType.netBanking);

  void _selectUpi() {
    setState(() {
      isUPISelected = true;
      isNetBankingSelected = false;
      selectedPaymentMode = CashFreeApiWeb.paymentTypes.first;
      isBankCodeAvailable = true;
      isAmountError = false;
      isAmountValid = false;
    });
  }

  void _selectNetBanking() {
    setState(() {
      isNetBankingSelected = true;
      isUPISelected = false;
      selectedPaymentMode = _netBankingOption;
      isBankCodeAvailable = true;
      isAmountError = false;
      isAmountValid = false;
    });
  }

  int _orderAmountForCreate() {
    final amount = int.parse(amountController.text);
    return _isNetBanking ? amount + netBankingCharge : amount;
  }

  bool _hasValidNetbankingCode(CashFreeOrderResponse? response) {
    return response != null && response.netbankingCode.isNotEmpty;
  }

  BankAccountDetails? get _registeredBank =>
      context.read<AppStateProvider>().userDetails?.bankAccountDetails;

  bool get _hasRegisteredBankDetails {
    final bank = _registeredBank;
    return bank != null &&
        bank.ifscCode.trim().isNotEmpty &&
        bank.accountNumber.trim().isNotEmpty;
  }

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

  Widget _tpvBankBanner() {
    final bank = _registeredBank;
    if (!_hasRegisteredBankDetails || bank == null) {
      return const SizedBox.shrink();
    }
    return TpvRegisteredBankBanner(
      bankName: bank.bankName,
      accountNumber: bank.accountNumber,
      upiId: bank.upiId.trim().isEmpty ? null : bank.upiId.trim(),
    );
  }

  Widget _upiPaymentSection() {
    if (_usesRegisteredUpiCollect) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        child: InputWidget(
          focusNode: _focus,
          isFocused: isFocused,
          isUPI: true,
          isEditable: false,
          rightIcon: isUpiValid
              ? Image(
                  width: 25,
                  height: 20,
                  fit: BoxFit.cover,
                  image: AssetImage(LocalImages.upi_valid_icon),
                )
              : Container(),
          controller: upiController,
          keyboardType: TextInputType.emailAddress,
          isValid: isUpiValid,
          isError: isUpiError,
          hintStr: LanguageHelper.textTpvRegisteredUpi,
          heading: LanguageHelper.textTpvRegisteredUpi,
          horizontalMargin: 0,
          onChange: (_) {},
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: InputWidget(
        focusNode: _focus,
        isFocused: isFocused,
        isUPI: true,
        controller: upiController,
        keyboardType: TextInputType.emailAddress,
        isValid: isUpiValid,
        isError: isUpiError,
        alertStr: isUpiError ? LanguageHelper.textInvalidUpiId : '',
        hintStr: LanguageHelper.textEnterUpiId,
        heading: LanguageHelper.textEnterUpiLinkedToBank,
        horizontalMargin: 0,
        onChange: (String input) {
          setState(() {
            isUpiValid = input.trim().isUpiIdValid;
            isUpiError = input.trim().isNotEmpty && !isUpiValid;
          });
        },
      ),
    );
  }

  String _effectiveUpiId() {
    final entered = upiController.text.trim();
    if (entered.isNotEmpty) {
      return entered;
    }
    return _registeredBank?.upiId.trim() ?? '';
  }

  Future<bool> _persistUpiIfNeeded() async {
    final upi = upiController.text.trim();
    if (!upi.isUpiIdValid) {
      return false;
    }
    final profileUpi = _registeredBank?.upiId.trim() ?? '';
    if (upi == profileUpi) {
      return true;
    }
    return context.read<AppStateProvider>().saveProfileUpi(upi);
  }

  @override
  void dispose() {
    iFSCCodeController.dispose();
    // iFSCCodeController.dispose();
    accountNoController.dispose();
    chequeNoController.dispose();
    amountController.dispose();
    upiController.dispose();

    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
    // Clean up the controller when the widget is disposed.
  }

  bool checkValidation() {
    if (!_hasRegisteredBankDetails) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textTpvBankDetailsMissing);
      return false;
    }

    if (isUPISelected && !_effectiveUpiId().isUpiIdValid) {
      setState(() {
        isUpiError = true;
      });
      return false;
    }

    if (amountController.text.doubleValue() < 1000 ||
        amountController.text.doubleValue() > 1000000) {
      setState(() {
        isAmountError = true;
        Utils.showAlert(
            context: context, msg: "Amount should be at least 1000");
      });
      return false;
    }

    return true;
  }

  makePayment() {
    print('called');
    if (checkValidation()) {
      print('check');
      try {
        if (amountController.text.doubleValue() < 10000 &&
            context
                    .read<AppStateProvider>()
                    .userFundTransferDetails!
                    .totalFundsTransferred ==
                null) {
          Utils.showAlert(
              context: context,
              msg:
                  "You are adding funds for first time, Please add at least 10000 rupees");
          return;
        }
      } catch (e) {}

      // if (isOnlineSelected) {
      if (isBankCodeAvailable) {
        getCashFreeToken();
      }
      // }
    }
  }

  /// Get CashFree token and bankCode
  Future<void> getCashFreeToken() async {
    if (isUPISelected) {
      final saved = await _persistUpiIfNeeded();
      if (!saved) {
        Utils.showAlert(context: context, msg: LanguageHelper.textInvalidUpiId);
        return;
      }
    }

    var customerId = context.read<AppStateProvider>().customerId;
    var userDetails = context.read<AppStateProvider>().userDetails;
    var param = Map<String, dynamic>();

    setLoading(true);

    var ip = await Utils.getIpAddress();
    param = {
      "order_amount": "${_orderAmountForCreate()}",
      "order_currency": "INR",
      "ifscCode": userDetails?.bankAccountDetails?.ifscCode ?? "",
      "ip": ip,
      "customer_details": {
        "customer_id": customerId,
        "customer_email": userDetails?.profileDetails?.email ?? "",
        "customer_phone": userDetails?.profileDetails?.phoneNumber ?? "",
      },
    };
    var cashFreeDataWeb =
        await context.read<AppStateProvider>().getCashFreeTokenWeb(param);
    setLoading(false);

    if (_isNetBanking) {
      if (!_hasValidNetbankingCode(cashFreeDataWeb)) {
        setState(() {
          isBankCodeAvailable = false;
        });
        Utils.showAlert(
            context: context,
            msg: cashFreeDataWeb?.txMsg ?? LanguageHelper.textNetBankingUnavailable);
        return;
      }
    } else if (cashFreeDataWeb?.bankCode == null ||
        cashFreeDataWeb?.bankCode == '') {
      setState(() {
        isBankCodeAvailable = false;
      });
      Utils.showAlert(context: context, msg: cashFreeDataWeb?.txMsg ?? "");
      return;
    }

    if (cashFreeDataWeb != null) {
      makeOnlinePaymentWeb(cashFreeDataWeb);
    }
  }

  /// Make online payment (UPI and NetBanking) for web
  void makeOnlinePaymentWeb(CashFreeOrderResponse response) async {
    final userData = context.read<AppStateProvider>().userDetails;
    orderId = "${response.orderId}";
    print("bankCode :${response.bankCode}");
    print("netbankingBankCode :${response.netbankingBankCode}");
    var params = CashFreeParams(
      orderID: "${response.orderId}",
      orderAmount: "${response.orderAmount ?? 0}",
      tokenData: response.sessionId,
      paymentSessionId: response.sessionId,
      orderToken: response.sessionId,
      paymentCode: _isNetBanking ? response.netbankingCode : response.bankCode,
      customerName: userData?.profileDetails?.fullName ?? "",
      customerPhone: userData?.profileDetails?.phoneNumber ?? "",
      customerEmail: userData?.profileDetails?.email ?? "",
    );

    setLoading(true);
    if (_isNetBanking) {
      await CashFreeApiWeb.doNetBankingPayment(
          params, context, amountController.text);
    } else if (isUPISelected) {
      final upi = _effectiveUpiId();
      params.upiID = upi.isNotEmpty ? upi : null;
      params.paymentLink = response.paymentLink;

      await CashFreeApiWeb.doUpiPayment(params, context, amountController.text);
    }

    setLoading(false);
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
                  'Fund Transfer',
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
                actions: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          // <-- SEE HERE
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15.0),
                          ),
                        ),
                        builder: (BuildContext context) => NeedHelpWidget(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Need Help ?',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.white,
                            fontWeight: FontWeight.w500,
                          ),
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
                ? Container(
                    margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
                    child: Column(
                      children: [
                        mainWidgets(context),
                      ],
                    ))
                : Row(
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
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TitleHeader(
                                          titleStr: 'Fund Transfer',
                                          desStr: '',
                                        ),
                                        mainWidgets(context)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    var fundDetails =
        Provider.of<AppStateProvider>(context).userFundTransferDetails;
    bool isFundExceeded =
        (fundDetails?.totalFundsTransferred?.transactionAmount ?? 0) >
                1000000 ||
            amountController.text.doubleValue() > 1000000;
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer Money instantly and start earning 18%*',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  _tpvBankBanner(),
                  amountWidget(),
                  SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AmountTabsWidget(
                        title: 1000,
                        ontap: () {
                          int amount;
                          if (amountController.text.isEmpty) {
                            amount = 0;
                          } else {
                            amount = int.parse(amountController.text);
                          }
                          amount = amount + 1000;
                          amountController.text = amount.toString();
                        },
                      ),
                      AmountTabsWidget(
                        title: 5000,
                        ontap: () {
                          int amount;
                          if (amountController.text.isEmpty) {
                            amount = 0;
                          } else {
                            amount = int.parse(amountController.text);
                          }
                          amount = amount + 5000;
                          amountController.text = amount.toString();
                        },
                      ),
                      AmountTabsWidget(
                        title: 10000,
                        ontap: () {
                          int amount;
                          if (amountController.text.isEmpty) {
                            amount = 0;
                          } else {
                            amount = int.parse(amountController.text);
                          }

                          amount = amount + 10000;
                          amountController.text = amount.toString();
                        },
                      ),
                      AmountTabsWidget(
                        title: 50000,
                        ontap: () {
                          int amount;
                          if (amountController.text.isEmpty) {
                            amount = 0;
                          } else {
                            amount = int.parse(amountController.text);
                          }
                          print(amount);
                          amount = amount + 50000;
                          amountController.text = amount.toString();
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  CheckBoxWidget(
                    isUPIBox: true,
                    UPIWidget: _upiPaymentSection(),
                    titleStr: 'UPI',
                    isSelected: isUPISelected,
                    onPress: () {
                      if (isUPISelected) {
                        setState(() {
                          isUPISelected = false;
                          isAmountError = false;
                          isAmountValid = false;
                        });
                      } else {
                        _selectUpi();
                      }
                    },
                  ),
                  CheckBoxWidget(
                    titleStr: 'Net Banking',
                    isSelected: isNetBankingSelected,
                    onPress: () {
                      if (isNetBankingSelected) {
                        setState(() {
                          isNetBankingSelected = false;
                          isAmountError = false;
                          isAmountValid = false;
                        });
                      } else {
                        _selectNetBanking();
                      }
                    },
                  ),
                  // CheckBoxWidget(
                  //   titleStr: 'Cheque Deposit',
                  //   isSelected: isChequeSelected,
                  //   onPress: () {
                  //     setState(() {
                  //       isChequeSelected = !isChequeSelected;
                  //       isOnlineSelected = false;
                  //       amountController.text = '';
                  //       isAmountError = false;
                  //       isAmountValid = false;
                  //     });
                  //   },
                  // ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: CustomFonts.nunito,
                        color: ColorsUtil.blueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: InkWell(
                      onTap: () {
                        context.pushNamed(RoutesName.ChequeDepositScreen);
                      },
                      child: Text(
                        'Do a Cheque Deposit Instead',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: CustomFonts.nunito,
                          color: ColorsUtil.greenText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isFundExceeded,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                          color: ColorsUtil.rewardRedContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.info,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your total funding amount has crossed ₹ 10 Lakh. Please follow the instructions, fill the document and upload it.',
                                  maxLines: 3,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context.pushNamed(
                                            RoutesName.FundTransferProcess);
                                      },
                                      child: Text(
                                        'Complete this process now',
                                        style: TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: CustomFonts.nunito,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 21,
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isBankCodeAvailable &&
                      (isUPISelected || isNetBankingSelected))
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      margin: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          color: ColorsUtil.rewardRedContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorsUtil.redColor)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.info,
                              color: ColorsUtil.redColor,
                            ),
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your bank account is not supported for Online Transaction. Kindly do Cheque deposit',
                                  maxLines: 3,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 24.0,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CustomButton(
                titleStr: 'Deposit Money',
                horizontalMargin: 0,
                isDisable: (!isUPISelected && !isNetBankingSelected) ||
                    (!isBankCodeAvailable &&
                        (isUPISelected || isNetBankingSelected)),
                onPress: makePayment,
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(RoutesName.HomeScreen);
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.greenText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget amountWidget() {
    return InputWidget(
      prefixText: '₹ ',
      initialValue: '1000',
      controller: amountController,
      keyboardType: TextInputType.number,
      isValid: isAmountValid,
      alertColor: Colors.red,
      alertStr: isNetBankingSelected ? LanguageHelper.textNetBankingCharge : "",
      isError: isAmountError,
      hintStr: 'Enter Amount',
      heading: 'Enter Amount',
      horizontalMargin: 0,
      onChange: (String input) {
        setState(() {
          isAmountValid = input.doubleValue() >= 5000;
          isAmountError = false;
        });
      },
    );
  }
}

class AmountTabsWidget extends StatelessWidget {
  AmountTabsWidget({Key? key, required this.title, required this.ontap})
      : super(key: key);

  int title;
  Function() ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        // height: 35,
        width: 80,
        decoration: BoxDecoration(
          color: ColorsUtil.greenDepositScreenText.withOpacity(.2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '+${title.toString()}',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: CustomFonts.nunito,
                  fontSize: 13,
                  color: ColorsUtil.blackish),
            ),
          ),
        ),
      ),
    );
  }
}

class NeedHelpWidget extends StatelessWidget {
  const NeedHelpWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Help with Fund Transfer',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: CustomFonts.nunito,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.close,
                    size: 25.0,
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Divider(
              thickness: .5,
              height: 1.0,
              color: ColorsUtil.lighterGrey,
            ),
          ),

          //no of headers
          PointWidget(
              heading: "How does PeerBridge work?",
              body:
                  "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),
          PointWidget(
              heading:
                  "Why is it safe to lend or borrow money online at PeerBridge's marketplace?",
              body:
                  "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),
          PointWidget(
              heading: "is my personal/financial information safe with PeerBridge?",
              body:
                  "'The entire process is online, using technology to lower the cost of borrowing and pass the savings back in the form of lower rates for borrowers and solid returns for lenders.'"),

          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: .5,
            height: 1.0,
            color: ColorsUtil.lighterGrey,
          ),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text:
                    "Can’t find what you’re looking for?\nGive us a call at : ",
                style: TextStyle(
                  color: ColorsUtil.lightGrey,
                  fontWeight: FontWeight.w500,
                  fontFamily: CustomFonts.nunito,
                  fontSize: 13.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: Constants.callSupportNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.greenText,
                      fontFamily: CustomFonts.nunito,
                      fontSize: 13.0,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        launch('tel://${Constants.callSupportNumber}');
                      },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}

class PointWidget extends StatelessWidget {
  String heading;
  String body;
  PointWidget({
    required this.heading,
    required this.body,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(0),
        trailing: Icon(
          Icons.check,
          size: 0.0,
          color: ColorsUtil.white,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(
            top: 5.5,
          ),
          child: Icon(
            Icons.arrow_forward_ios_outlined,
            color: ColorsUtil.arrowColor,
            size: 14.0,
          ),
        ),
        textColor: Colors.black54,
        collapsedIconColor: ColorsUtil.white,
        iconColor: Colors.white,
        title: Text(
          heading,
          style: TextStyle(
              color: Colors.black,
              fontFamily: CustomFonts.nunito,
              fontSize: 16.0,
              fontWeight: FontWeight.w400),
        ),
        children: [
          VerticalDivider(
            thickness: 5.0,
            color: Colors.black,
            width: 2.0,
          ),
          Padding(
              padding: const EdgeInsets.only(
                  top: 4.0, bottom: 4.0, left: 25.0, right: 25.0),
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Image.asset(LocalImages.line),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Text(
                            body,
                            maxLines: 7,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontFamily: CustomFonts.nunito,
                              fontWeight: FontWeight.w400,
                              color: ColorsUtil.greyPlaceHolder,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ))),
        ],
      ),
    );
  }
}
