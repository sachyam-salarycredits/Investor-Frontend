import 'dart:io';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashFree_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashfree_web_token_response.dart';
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
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../supporting_file/appsFlyerSdk.dart';

class FundTransferScreen extends StatefulWidget {
  const FundTransferScreen({
    Key? key,
  }) : super(key: key);

  @override
  _FundTransferScreenState createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  String? fileName;
  PlatformFile? selectedFile;

  var iFSCCodeController = TextEditingController();
  var accountNoController = TextEditingController();
  var chequeNoController = TextEditingController();
  var amountController = TextEditingController();
  var upiController = TextEditingController();

  PaymentOptions selectedPaymentMode = CashFreeApi.paymentTypes.first;
  bool isOnlineSelected = false;
  bool isChequeSelected = false;
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

  @override
  void initState() {
    super.initState();
    // getCashFreeToken();
    final userData = context.read<AppStateProvider>().userDetails;
    iFSCCodeController.text = userData?.bankAccountDetails?.ifscCode ?? '';
    accountNoController.text =
        userData?.bankAccountDetails?.accountNumber ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncRegisteredUpiFromProfile());
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
      return InputWidget(
        isUPI: true,
        isEditable: false,
        controller: upiController,
        keyboardType: TextInputType.emailAddress,
        isValid: isUpiValid,
        isError: isUpiError,
        hintStr: LanguageHelper.textTpvRegisteredUpi,
        heading: LanguageHelper.textTpvRegisteredUpi,
        horizontalMargin: 0,
        onChange: (_) {},
      );
    }

    return InputWidget(
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
    iFSCCodeController.dispose();
    accountNoController.dispose();
    chequeNoController.dispose();
    amountController.dispose();
    upiController.dispose();
    super.dispose();
    // Clean up the controller when the widget is disposed.
  }

  bool checkValidation() {
    if (isOnlineSelected && !_hasRegisteredBankDetails) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textTpvBankDetailsMissing);
      return false;
    }

    if (isOnlineSelected &&
        selectedPaymentMode.type == PaymentType.upi &&
        !_effectiveUpiId().isUpiIdValid) {
      setState(() {
        isUpiError = true;
      });
      return false;
    }
    if (!isOnlineSelected && chequeNoController.text.length < 6) {
      setState(() {
        isChequeError = true;
      });
      return false;
    }
    if ((Utils.isWeb && selectedFile == null && !isOnlineSelected) ||
        (!Utils.isWeb && fileName == null && !isOnlineSelected)) {
      setState(() {
        isAmountError = true;
        Utils.showAlert(context: context, msg: "Please upload the Cheque.");
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
    if (checkValidation()) {
      try {
        if (amountController.text.doubleValue() < 25000 &&
            context
                .read<AppStateProvider>()
                .userFundTransferDetails!
                .totalFundsTransferred!
                .statement
                .isEmpty) {
          Utils.showAlert(
              context: context,
              msg:
                  "You are adding funds for first time, Please add at least 25000 rupees");
        }
      } catch (e) {}
      if (isOnlineSelected) {
        if (isBankCodeAvailable) {
          getCashFreeToken();
        }
      } else {
        makeChequePayment();
      }
    }
  }

  /// Get CashFree token and bankCode
  Future<void> getCashFreeToken() async {
    if (isOnlineSelected && selectedPaymentMode.type == PaymentType.upi) {
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
      "order_amount": selectedPaymentMode.type == PaymentType.netBanking
          ? "${(int.parse(amountController.text) + netBankingCharge)}"
          : amountController.text,
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

    if (selectedPaymentMode.type == PaymentType.netBanking) {
      if (cashFreeDataWeb == null ||
          cashFreeDataWeb.netbankingCode.isEmpty) {
        setState(() {
          isBankCodeAvailable = false;
        });
        Utils.showAlert(
            context: context,
            msg: cashFreeDataWeb?.txMsg ??
                LanguageHelper.textNetBankingUnavailable);
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
      paymentCode: selectedPaymentMode.type == PaymentType.netBanking
          ? response.netbankingCode
          : response.bankCode,
      customerName: userData?.profileDetails?.fullName ?? "",
      customerPhone: userData?.profileDetails?.phoneNumber ?? "",
      customerEmail: userData?.profileDetails?.email ?? "",
    );

    setLoading(true);
    if (selectedPaymentMode.type == PaymentType.upi) {
      final upi = _effectiveUpiId();
      params.upiID = upi.isNotEmpty ? upi : null;
      params.paymentLink = response.paymentLink;

      await CashFreeApiWeb.doUpiPayment(params, context, amountController.text);
    } else {
      await CashFreeApiWeb.doNetBankingPayment(
          params, context, amountController.text);
    }

    setLoading(false);
  }

  /// Make payment using Cheque
  Future<void> makeChequePayment() async {
    setLoading(true);
    var ip = await Utils.getIpAddress();

    var param = Map<String, String>();
    param[ApiParams.customerId] = (context.read<AppStateProvider>().customerId);
    param[ApiParams.chequeNumber] = chequeNoController.text;
    param[ApiParams.enterAmount] = amountController.text;
    param[ApiParams.ip] = ip;
    var files;
    if (Utils.isWeb || selectedFile != null) {
      files = Map<String, PlatformFile>();
      files[ApiParams.file] = selectedFile ?? "";
    } else {
      files = Map<String, String>();
      files[ApiParams.file] = fileName ?? "";
    }
    var chequeRes = await context
        .read<AppStateProvider>()
        .chequeFundTransfer(param, files, (selectedFile != null));
    setLoading(false);
    if (chequeRes) {
      selectedFile = null;
      fileName = '';
      context.pop();
      var value = Map<String, dynamic>();
      value["af_revenue"] = amountController.text;
      value["af_currency"] = "INR";
      // AFSdk.logEvent(AFSdk.af_fundTransfer, value);
      Utils.showToast(msg: LanguageHelper.textFundTransfer);
    }
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> openCamera() async {
    var pickedImg = await ImgPicker.pickAndCropFromCamera();
    if (pickedImg != null) {
      setState(() {
        fileName = pickedImg.path;
      });
    }
  }

  Future<void> openFiles() async {
    final filePicked = await Utils.pickFile(
        allowedExtensions: ["pdf", "png", "jpg", "jpeg"],
        fileType: FileType.custom);
    if (filePicked == null) return;
    debugPrint('file selected');
    setState(() {
      fileName = filePicked.name;
      selectedFile = filePicked;
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
                      TitleHeader(
                        titleStr: 'Fund Transfer',
                        desStr:
                            'Transfer Money instantly and start earning 13%*',
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: mainWidgets(context),
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
                        child: Column(
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
                                          TitleHeader(
                                            titleStr: 'Fund Transfer',
                                            desStr:
                                                'Transfer Money instantly and start earning 13%*',
                                          ),
                                          SizedBox(height: 30),
                                          mainWidgets(context),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Fund Transfer Method',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        CheckBoxWidget(
          titleStr: 'Online Transfer',
          isSelected: isOnlineSelected,
          onPress: () {
            setState(() {
              isOnlineSelected = !isOnlineSelected;
              isChequeSelected = false;
              amountController.text = '';
              isAmountError = false;
              isAmountValid = false;
            });
          },
        ),
        CheckBoxWidget(
          titleStr: 'Cheque Deposit',
          isSelected: isChequeSelected,
          onPress: () {
            setState(() {
              isChequeSelected = !isChequeSelected;
              isOnlineSelected = false;
              amountController.text = '';
              isAmountError = false;
              isAmountValid = false;
            });
          },
        ),
        SizedBox(height: 30),
        Visibility(
            visible: isOnlineSelected,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tpvBankBanner(),
                SizedBox(height: 16),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Mode',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Choose your payment mode',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: ColorsUtil.lighterGrey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    height: 56.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: false,
                        value: selectedPaymentMode,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 17.0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: ColorsUtil.black,
                          ),
                        ),
                        iconSize: 20,
                        elevation: 16,
                        style: const TextStyle(
                          color: ColorsUtil.black,
                        ),
                        underline: Container(
                          height: 2,
                          color: Colors.grey.shade700,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            selectedPaymentMode = newValue as PaymentOptions;
                            isBankCodeAvailable = true;
                          });
                        },
                        hint: Container(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 17.0, right: 160.0),
                            child: Text(
                              "Net Banking",
                              style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 18.0,
                                  color: ColorsUtil.black),
                            ),
                          ),
                        ),
                        items: CashFreeApi.paymentTypes
                            .map<DropdownMenuItem<PaymentOptions>>(
                                (PaymentOptions value) {
                          return DropdownMenuItem<PaymentOptions>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                value.typeLabel,
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 16.0,
                                    color: ColorsUtil.black),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedPaymentMode.type == PaymentType.upi,
                  child: Column(
                    children: [
                      _upiPaymentSection(),
                      SizedBox(height: 30.0),
                    ],
                  ),
                ),
                amountWidget(),
                SizedBox(height: 30.0),
              ],
            )),
        Visibility(
          visible: isChequeSelected,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputWidget(
                controller: chequeNoController,
                hintStr: 'Cheque Number',
                heading: 'Cheque Number',
                isError: isChequeError,
                isValid: isChequeValid,
                keyboardType: TextInputType.number,
                horizontalMargin: 0,
                maxLength: 6,
                onChange: (String input) {
                  setState(() {
                    isChequeValid =
                        input.length == 6 && input.isValidChequeNumber;
                    isChequeError = false;
                  });
                },
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () async {
                  if (Utils.isWeb) {
                    openFiles();
                  } else {
                    showSourceDialog();
                  }
                },
                child: Container(
                  child: DottedBorder(
                    color: ColorsUtil.blueColor,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(5),
                    strokeWidth: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: ColorsUtil.lightestGrey,
                      ),
                      height: 52,
                      width: double.infinity,
                      child: fileName != null
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  width: 300,
                                  child: Text(
                                    fileName.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                        color: ColorsUtil.black),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Image.asset(
                                  LocalImages.upload,
                                  width: 16,
                                  height: 16,
                                  color: ColorsUtil.blueColorText,
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  'Upload Cheque',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                      color: ColorsUtil.blueColor),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Formats Accepted: PDF, PNG, JPG',
                      style: TextStyle(
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                          color: ColorsUtil.lightBlack),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline),
                      onPressed: showChequeHelpDialog,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              amountWidget(),
              SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
        Visibility(
          visible: isFundExceeded,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                              context.pushNamed(RoutesName.FundTransferProcess);
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
        if (!isBankCodeAvailable && isOnlineSelected)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                        'Your bank account is not supported for Net banking. Kindly do Cheque deposit',
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
        CustomButton(
          titleStr: 'Make Payment',
          horizontalMargin: 0,
          isDisable: (!isOnlineSelected && !isChequeSelected) ||
              (!isBankCodeAvailable && isOnlineSelected),
          onPress: makePayment,
        ),
      ],
    );
  }

  void showSourceDialog() {
    var screenSize = MediaQuery.of(context).size;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
            title: Container(
              width: ResponsiveWidget.isSmallScreen(context)
                  ? screenSize.width * .8
                  : screenSize.width * .35,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    'Select Source Type',
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: CustomFonts.nunito,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          openCamera();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera,
                              size: 60,
                              color: ColorsUtil.lighterGrey,
                            ),
                            Text('Camera',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          openFiles();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 60,
                              color: ColorsUtil.lighterGrey,
                            ),
                            Text('Files',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  CustomButton(
                    horizontalMargin: 5,
                    borderColor: ColorsUtil.lightGrey,
                    titleStr: 'Cancel',
                    bgColor: ColorsUtil.white,
                    textColor: ColorsUtil.lightGrey,
                    onPress: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
  }

  void showChequeHelpDialog() {
    var screenSize = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title:
                const Text('Credentials and guidelines for filling the Cheque',
                    style: TextStyle(
                        // fontFamily: CustomFonts.nunito,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700)),
            content: Container(
              width: screenSize.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Table(
                      border: TableBorder.all(),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text('Account Name',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text(
                                'Monexo Fintech - Lender Funding Escrow Account',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Account Number',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('10000781341',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text('Account Type',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text('Current Account',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Bank Name',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IDFC Bank Limited',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IFS Code',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IDFB0040101',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('MICR Code',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('400751002',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Bank Address',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text(
                                'IDFC Bank Limited, Naman Chambers, C-32, G-Block, Bandra-Kurla Complex, Bandra East, MUMBAI-400051',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Please note the following:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                        'The transfer of the funds for cheque deposit should be from the bank account mentioned above.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                        'As the transfer of funds is made by cheque, you need to provide your cheque number and upload the scanned image of your cheque. The funds will be credited to your account after clearance of your cheque proceeds.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        ))
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: const Text("Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        // fontFamily: CustomFonts.nunito
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // your code
                  })
            ],
          );
        });
  }

  Widget amountWidget() {
    return InputWidget(
      controller: amountController,
      keyboardType: TextInputType.number,
      isValid: isAmountValid,
      alertColor: Colors.red,
      alertStr: (selectedPaymentMode.type == PaymentType.netBanking &&
              isOnlineSelected)
          ? "${LanguageHelper.textNetBankingCharge}"
          : "",
      isError: isAmountError,
      hintStr: 'Enter Amount',
      heading: 'Enter Amount',
      horizontalMargin: 0,
      onChange: (String input) {
        setState(() {
          isAmountValid = input.doubleValue() >= 1000;
          isAmountError = false;
        });
      },
    );
  }
}
