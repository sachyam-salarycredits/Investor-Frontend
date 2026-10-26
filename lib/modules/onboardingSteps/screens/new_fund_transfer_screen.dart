import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashFree_details.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashfree_web_token_response.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/supporting_file/cashfree_api.dart';
import 'package:peerbridge/utils/enums.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:peerbridge/widgets/tpv_registered_bank_banner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final readOnly = _usesRegisteredUpiCollect;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          focusNode: _focus,
          controller: upiController,
          readOnly: readOnly,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.medium(15),
          onChanged: readOnly
              ? null
              : (input) {
                  setState(() {
                    isUpiValid = input.trim().isUpiIdValid;
                    isUpiError = input.trim().isNotEmpty && !isUpiValid;
                  });
                },
          decoration: InputDecoration(
            hintText: readOnly
                ? LanguageHelper.textTpvRegisteredUpi
                : LanguageHelper.textEnterUpiId,
            hintStyle: AppTextStyles.regular(14, color: const Color(0xffB0B0B0)),
            filled: readOnly,
            fillColor: const Color(0xffF7F7F7),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: _fieldBorder(
                isUpiError ? AppColors.error : const Color(0xffE4E4E4)),
            focusedBorder: _fieldBorder(
                isUpiError ? AppColors.error : AppColors.green),
            suffixIcon: isUpiValid
                ? const Icon(Icons.check_circle, color: AppColors.green, size: 20)
                : null,
          ),
        ),
        if (!readOnly) ...[
          const SizedBox(height: 6),
          Text(
            isUpiError
                ? LanguageHelper.textInvalidUpiId
                : LanguageHelper.textEnterUpiLinkedToBank,
            style: AppTextStyles.regular(
              12,
              color: isUpiError ? AppColors.error : AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.1),
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

  void _openHelp() {
    showPbBottomSheet<void>(
      context: context,
      builder: (_) => const NeedHelpWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PbPageHeader(
          title: 'Fund transfer',
          onBack: () => context.pop(),
          actions: [
            IconButton(
              onPressed: _openHelp,
              tooltip: 'Need help',
              icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            ),
          ],
        ),
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 520,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                      child: Column(
                        children: [
                          mainWidgets(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                    'Add money and start lending',
                    style: AppTextStyles.semiBold(22).copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transfer from your registered bank. Minimum ₹1,000.',
                    style: AppTextStyles.regular(13, color: AppColors.muted)
                        .copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _tpvBankBanner(),
                  amountWidget(),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 22),
                  Text('Pay using', style: AppTextStyles.semiBold(15)),
                  const SizedBox(height: 10),
                  _paymentOption(
                    title: 'UPI',
                    selected: isUPISelected,
                    onTap: () {
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
                    child: isUPISelected ? _upiPaymentSection() : null,
                  ),
                  _paymentOption(
                    title: 'Net banking',
                    selected: isNetBankingSelected,
                    onTap: () {
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
                  //                   ),
                  if (isFundExceeded)
                    _notice(
                      'Your total funding amount has crossed ₹10 lakh. Follow the instructions, fill the document and upload it.',
                      action: 'Complete this process now',
                      onAction: () =>
                          context.pushNamed(RoutesName.FundTransferProcess),
                    ),
                  if (!isBankCodeAvailable &&
                      (isUPISelected || isNetBankingSelected))
                    _notice(
                      'Your bank account is not supported for UPI or net banking.',
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
              PbPrimaryButton(
                label: 'Deposit money',
                onPressed: (!isUPISelected && !isNetBankingSelected) ||
                        (!isBankCodeAvailable &&
                            (isUPISelected || isNetBankingSelected))
                    ? null
                    : makePayment,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.pushNamed(RoutesName.HomeScreen),
                child: Text(
                  'Skip for now',
                  style: AppTextStyles.medium(14, color: AppColors.green),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.mintSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.green : AppColors.line,
                width: selected ? 1.4 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.green : Colors.white,
                        border: Border.all(
                          color: selected ? AppColors.green : AppColors.handle,
                          width: 1.6,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, size: 13, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: AppTextStyles.medium(15)),
                  ],
                ),
                if (child != null) ...[
                  const SizedBox(height: 12),
                  child,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(String message, {String? action, VoidCallback? onAction}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.regular(13).copyWith(height: 1.4)),
          if (action != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style: AppTextStyles.semiBold(13, color: AppColors.green)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget amountWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: AppTextStyles.medium(13, color: AppColors.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: AppTextStyles.semiBold(22),
          onChanged: (input) {
            setState(() {
              isAmountValid = input.doubleValue() >= 5000;
              isAmountError = false;
            });
          },
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: AppTextStyles.semiBold(22, color: AppColors.ink),
            hintText: 'Enter amount',
            hintStyle: AppTextStyles.regular(16, color: const Color(0xffB0B0B0)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: _fieldBorder(
                isAmountError ? AppColors.error : const Color(0xffE4E4E4)),
            focusedBorder: _fieldBorder(
                isAmountError ? AppColors.error : AppColors.green),
          ),
        ),
        if (isNetBankingSelected) ...[
          const SizedBox(height: 6),
          Text(
            LanguageHelper.textNetBankingCharge,
            style: AppTextStyles.regular(12, color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}

class AmountTabsWidget extends StatelessWidget {
  const AmountTabsWidget({Key? key, required this.title, required this.ontap})
      : super(key: key);

  final int title;
  final Function() ontap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: ontap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '+₹$title',
            style: AppTextStyles.medium(13, color: AppColors.greenDeep),
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
                'Help with fund transfer',
                style: AppTextStyles.semiBold(18),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Divider(
              thickness: .5,
              height: 1.0,
              color: AppColors.line,
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
          const Divider(
            thickness: .5,
            height: 1.0,
            color: AppColors.line,
          ),
          SizedBox(
            height: 10.0,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text:
                    "Can’t find what you’re looking for?\nGive us a call at : ",
                style: AppTextStyles.medium(13, color: AppColors.muted),
                children: <TextSpan>[
                  TextSpan(
                    text: Constants.callSupportNumber,
                    style: AppTextStyles.semiBold(13, color: AppColors.green),
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
        trailing: const Icon(
          Icons.check,
          size: 0.0,
          color: AppColors.white,
        ),
        leading: const Padding(
          padding: EdgeInsets.only(
            top: 5.5,
          ),
          child: Icon(
            Icons.arrow_forward_ios_outlined,
            color: AppColors.green,
            size: 14.0,
          ),
        ),
        textColor: AppColors.ink,
        collapsedIconColor: AppColors.white,
        iconColor: AppColors.white,
        title: Text(
          heading,
          style: AppTextStyles.regular(15),
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
                            style: AppTextStyles.regular(12, color: AppColors.muted),
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
