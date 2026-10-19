import 'package:peerbridge/modules/marketplace/models/primary_market_loan.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routes_management/routes_list.dart';
import '../../../utils/constants.dart';
import 'custom_tooltip.dart';
import 'primary_loan_detail_dialog.dart';

/// Kept for wide layouts; renders the same card as mobile.
class WebMarketPlaceCard extends StatelessWidget {
  final int index;
  final Function? onUpdate;

  const WebMarketPlaceCard({Key? key, required this.index, this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      MarketPlaceCard(index: index, onUpdate: onUpdate);
}

class MarketPlaceCard extends StatefulWidget {
  final int index;
  final Function? onUpdate;

  const MarketPlaceCard({Key? key, required this.index, this.onUpdate})
      : super(key: key);

  @override
  State<MarketPlaceCard> createState() => _MarketPlaceCardState();
}

class _MarketPlaceCardState extends State<MarketPlaceCard> {
  final GlobalKey<CustomTooltipState> _toolTipKey =
      GlobalKey<CustomTooltipState>();

  void _notify() => widget.onUpdate?.call();

  bool _isSocialImpact(PrimaryMarketLoan loan) =>
      loan.productName.toString().toLowerCase().contains('social impact loan');

  void _openDetails(PrimaryMarketLoan loan) {
    if (_isSocialImpact(loan)) {
      final videos = context
          .read<AppStateProvider>()
          .youtubeVideos
          ?.data
          ?.where((element) => element.videoType == Constants.socialImpactKey);
      final loanVideo = (videos == null || videos.isEmpty) ? null : videos.first;
      if (Utils.isWeb) {
        Utils.launchURL(loanVideo?.videoUrl ?? '');
      } else {
        context.pushNamed(RoutesName.VideoPlayerPage, params: {
          Constants.videoUrl: loanVideo?.videoUrl ?? '',
          Constants.validateWatchTime: 'false',
        });
      }
      return;
    }
    showPrimaryLoanDetails(
      context,
      index: widget.index,
      onFund: () {
        if (!mounted) return;
        addToCart(loan);
        _notify();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final loan = provider.primaryMarketLoans![widget.index];
    final funded = loan.alreadyFunded();

    return LoanCard(
      category: loan.contract.isNotEmpty ? loan.contract : loan.productName,
      title: loan.customerName,
      riskTag: loan.category != '' ? RiskTag.fromCategory(loan.category) : null,
      metrics: [
        PbMetric(
            label: 'Amount', value: '₹${loan.loanAmount.commaAddedValue()}'),
        PbMetric(
            label: 'Tenure',
            value: '${loan.tenor.round()} ${loan.frequency.toFrequency()}'),
        PbMetric(
            label: 'Returns',
            value: '${loan.lenderXIRR}% p.a.',
            valueColor: AppColors.green),
      ],
      fundedPercent: loan.getAlreadyFunded().clamp(0, 1).toDouble(),
      detailLabel: _isSocialImpact(loan) ? 'Learn more' : 'View loan details',
      onDetails: () => _openDetails(loan),
      dimmed: funded,
      action: CustomTooltip(
        key: _toolTipKey,
        message: '',
        child: loan.isAddedToCart
            ? AmountStepper(
                compact: true,
                height: 32,
                value: '₹${loan.fundedAmount.round().commaAddedValue()}',
                onDecrease: () {
                  if (loan.fundedAmount.round() > 1000) {
                    loan.fundedAmount -= 1000;
                    provider.updateMarketPlaceCardData();
                  } else {
                    provider.removeItemFromCard(loan.contract);
                    _notify();
                  }
                },
                onIncrease: () {
                  addToCart(loan);
                  _notify();
                },
              )
            : _FundButton(
                label: funded ? 'Funded' : 'Fund now',
                icon: funded ? Icons.check_rounded : Icons.add_rounded,
                light: funded,
                onTap: () {
                  addToCart(loan);
                  _notify();
                },
              ),
      ),
    );
  }

  void addToCart(PrimaryMarketLoan cardData) {
    final provider = context.read<AppStateProvider>();
    final isKycDone = (provider.stepsData?.kyc ?? '0') == "1";
    if (!isKycDone) {
      _toolTipKey.currentState!
          .showMessage("KYC is missing! Please complete KYC to fund this loan");
      return;
    }

    var availableBalance = provider.userFundTransferDetails?.withdrawableBalance ??
        provider
            .userFundTransferDetails?.totalAvailableBalance?.availableBalance ??
        0;
    var newTotal = 1000 + provider.getTotalCartAmount();

    if (newTotal > availableBalance) {
      _toolTipKey.currentState!
          .showMessage("You do not have enough balance to fund this loan!");
      return;
    }

    if ((cardData.alreadyFundedAmount + cardData.fundedAmount + 1000) > 5000) {
      _toolTipKey.currentState!.showMessage(
          "Please do not lend more than ₹ 5,000 for a diversified portfolio.");
      return;
    }

    if (cardData.fundedAmount + 1000 > cardData.getRequiredFunding()) {
      _toolTipKey.currentState!.showMessage(
          "your funding amount can’t be greater than the required loan amount!");
      return;
    }

    var existLoanLength =
        provider.primaryCartList.where((i) => cardData == i).toList().length;
    if (provider.primaryCartList.length >= 20 && existLoanLength == 0) {
      _toolTipKey.currentState!
          .showMessage("You can't fund more than 20 loans at a time!");
      return;
    }

    cardData.isAddedToCart = true;
    cardData.fundedAmount += 1000;
    provider.playCartSound();
    provider.updateMarketPlaceCardData();
  }
}

/// Compact pill used as the trailing action in a loan card footer.
class _FundButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool light;
  final VoidCallback onTap;

  const _FundButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: light ? Colors.white : null,
          gradient: light ? null : AppColors.goldGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.ink),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.semiBold(12, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

/// Shared footer pill for secondary-market cards.
class LoanFundButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool light;
  final VoidCallback onTap;

  const LoanFundButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.light = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      _FundButton(label: label, icon: icon, onTap: onTap, light: light);
}
