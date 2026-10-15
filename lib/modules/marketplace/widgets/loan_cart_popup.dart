import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/marketplace/models/common_loan_cart.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/supporting_file/otp_auto_detect.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:provider/provider.dart';

/// Funding summary sheet: cart lines, expected returns, OTP confirmation and
/// a success state once the checkout completes.
class loanCartPopupDialog extends StatefulWidget {
  final Function? onUpdate;
  final Function? refreshData;
  final VoidCallback? onViewPortfolio;

  const loanCartPopupDialog({
    Key? key,
    this.onUpdate,
    this.refreshData,
    this.onViewPortfolio,
  }) : super(key: key);

  @override
  State<loanCartPopupDialog> createState() => _loanCartPopupDialogState();
}

class _loanCartPopupDialogState extends State<loanCartPopupDialog> {
  String otp = "";
  final formKey = GlobalKey<FormState>();
  late OTPTextEditController otpController;
  bool _submitting = false;

  bool _success = false;
  int _fundedTotal = 0;
  int _fundedCount = 0;

  @override
  void initState() {
    super.initState();
    otpController = AutoDetectOtp().getOtpController();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  List<CommonLoanCart> _cart(AppStateProvider provider) =>
      provider.isPrimaryMarketSelected
          ? provider.primaryCartList
          : provider.secondaryCartList;

  double _expectedReturn(List<CommonLoanCart> cart) {
    double sum = 0.0;
    for (final loan in cart) {
      sum += loan.fundedAmount +
          (((loan.lenderXIRR / 100) * loan.fundedAmount) / 12) * loan.tenor;
    }
    return sum;
  }

  Future<void> _confirm() async {
    final state = context.read<AppStateProvider>();
    final availableBalance = state.userFundTransferDetails?.withdrawableBalance ??
        state
            .userFundTransferDetails?.totalAvailableBalance?.availableBalance ??
        0;
    final totalAmount = state.getTotalCartAmount();
    if (availableBalance < totalAmount) {
      Utils.showAlert(
          context: context,
          msg: "You do not have enough balance to fund this loan!");
      return;
    }

    if (!formKey.currentState!.validate() || otp.length != 6) return;

    setState(() => _submitting = true);
    final verified = await state.loginVerifyOTP(
        state.userDetails!.profileDetails!.phoneNumber, otp);
    if (!mounted) return;
    if (!verified) {
      setState(() => _submitting = false);
      otpController.clear();
      otp = '';
      Utils.showToast(msg: LanguageHelper.textValidOtp);
      return;
    }

    final count = _cart(state).length;
    final status = await state.checkoutItems();
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (status) {
        _success = true;
        _fundedTotal = totalAmount;
        _fundedCount = count;
      }
    });
    if (!status) {
      Utils.showToast(msg: 'We could not complete your investment. Please try again.');
    }
  }

  void _finish({bool openPortfolio = false}) {
    Navigator.of(context).pop();
    widget.refreshData?.call();
    if (openPortfolio) widget.onViewPortfolio?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuccessSheet(
              title: 'Investment confirmed',
              message:
                  'You funded $_fundedCount ${_fundedCount == 1 ? 'loan' : 'loans'} worth ₹${_fundedTotal.commaAddedValue()}. ${LanguageHelper.textInvestedSuccessfully}',
              buttonLabel: 'Done',
              onDone: () => _finish(),
            ),
            if (widget.onViewPortfolio != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () => _finish(openPortfolio: true),
                  child: Text('View portfolio',
                      style: AppTextStyles.semiBold(14, color: AppColors.green)),
                ),
              ),
          ],
        ),
      );
    }

    final provider = Provider.of<AppStateProvider>(context);
    final cartList = _cart(provider);
    final total = provider.getTotalCartAmount();
    final expected = _expectedReturn(cartList);
    final interest = (expected - total).clamp(0, double.infinity);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: PbSheetTitle(
              eyebrow:
                  '${cartList.length} ${cartList.length == 1 ? 'loan' : 'loans'} selected',
              title: 'Funding summary',
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cartList.length; i++) ...[
                    LoanCartCard(
                      cartIndex: i,
                      onUpdate: () {
                        setState(() {});
                        widget.onUpdate?.call();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: AppColors.mintSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        SummaryLine(
                            label: 'Investment amount',
                            value: '₹${total.commaAddedValue()}'),
                        SummaryLine(
                            label: 'Expected interest',
                            value: '₹${interest.round().commaAddedValue()}'),
                        const Divider(height: 12, color: AppColors.line),
                        SummaryLine(
                          label: 'Expected returns',
                          value: '₹${expected.round().commaAddedValue()}',
                          total: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Confirm with OTP', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text('Enter the 6-digit code sent to your registered mobile.',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: otpController,
                    autocorrect: false,
                    enableSuggestions: false,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.length != 6
                        ? 'Enter a valid 6-digit OTP'
                        : null,
                    onChanged: (value) => otp = value,
                    style: AppTextStyles.semiBold(18)
                        .copyWith(letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.green, width: 1.4),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: PbPrimaryButton(
              label: 'Confirm & invest ₹${total.commaAddedValue()}',
              isLoading: _submitting,
              onPressed: _submitting ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class LoanCartCard extends StatelessWidget {
  final int cartIndex;
  final Function onUpdate;

  const LoanCartCard({Key? key, required this.cartIndex, required this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final cartList = provider.isPrimaryMarketSelected
        ? provider.primaryCartList
        : provider.secondaryCartList;
    final cardData = cartList[cartIndex];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardData.productName.isEmpty
                      ? cardData.customerName
                      : cardData.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiBold(13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cardData.customerName} · ${cardData.lenderXIRR}% p.a.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '₹${cardData.fundedAmount.round().commaAddedValue()}',
              style: AppTextStyles.semiBold(13, color: AppColors.greenDeep),
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.muted, size: 21),
            onPressed: () {
              provider.removeItemFromCard(cardData.toString());
              if (provider.getTotalCartAmount() == 0) {
                Navigator.pop(context);
              }
              onUpdate();
            },
          ),
        ],
      ),
    );
  }
}
