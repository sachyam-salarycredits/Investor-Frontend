import 'package:peerbridge/modules/marketplace/widgets/market_place_grid_cards.dart';
import 'package:peerbridge/modules/marketplace/widgets/secondary_loan_details_dialog.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'custom_tooltip.dart';

class SecondaryMarketPlaceCard extends StatefulWidget {
  final int index;
  final Function? onUpdate;

  const SecondaryMarketPlaceCard({Key? key, required this.index, this.onUpdate})
      : super(key: key);

  @override
  _SecondaryMarketPlaceCardState createState() =>
      _SecondaryMarketPlaceCardState();
}

class _SecondaryMarketPlaceCardState extends State<SecondaryMarketPlaceCard> {
  final GlobalKey<CustomTooltipState> _toolTipKey =
      GlobalKey<CustomTooltipState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final cardData = provider.secondaryMarketLoans![widget.index];

    final isAdded = cardData.isAddedToCart || cardData.alreadyFunded;
    var buttonText = "Buy loan";
    if (cardData.isAddedToCart) buttonText = "Added";
    if (cardData.alreadyFunded) buttonText = "Funded";
    final remaining = cardData.remainingDaysStr();
    final frequency = cardData.frequency.toFrequency();

    return LoanCard(
      category: remaining.isEmpty ? cardData.status : '${cardData.status} · $remaining',
      title: cardData.customerName,
      riskTag: (cardData.rating != null && cardData.rating != '')
          ? RiskTag.fromCategory(cardData.rating!)
          : null,
      metrics: [
        PbMetric(
            label: 'Selling price',
            value: '₹${cardData.sellingPrice.toInt().commaAddedValue()}'),
        PbMetric(
            label: 'Remaining',
            value: '${cardData.tenorRemaining.round()} $frequency'),
        PbMetric(
            label: 'Buyer’s yield',
            value: '${cardData.buyersYield ?? '-'}%',
            valueColor: AppColors.green),
      ],
      dimmed: isAdded,
      onDetails: () => showSecondaryLoanDetails(context, index: widget.index),
      action: CustomTooltip(
        key: _toolTipKey,
        message: '',
        child: LoanFundButton(
          label: buttonText,
          icon: isAdded ? Icons.check_rounded : Icons.add_rounded,
          light: isAdded,
          onTap: () => _buy(provider),
        ),
      ),
    );
  }

  void _buy(AppStateProvider provider) {
    final cardData = provider.secondaryMarketLoans![widget.index];
    if (cardData.alreadyFunded) return;

    final isKycDone = (provider.stepsData?.kyc ?? '0') == "1";
    var availableBalance = provider
            .userFundTransferDetails?.totalAvailableBalance?.availableBalance ??
        0;

    if (availableBalance <
        (provider.getTotalCartAmount() + cardData.sellingPrice)) {
      _toolTipKey.currentState!
          .showMessage("You do not have enough balance to fund this loan!");
      return;
    }

    if (!isKycDone) {
      _toolTipKey.currentState!
          .showMessage("KYC is missing! Please complete KYC to fund this loan");
      return;
    }

    var existLoanLength = provider.secondaryCartList
        .where((i) => cardData == i)
        .toList()
        .length;
    if (provider.secondaryCartList.length >= 10 && existLoanLength == 0) {
      _toolTipKey.currentState!
          .showMessage("You can't buy more than 10 loans at a time!");
      return;
    }

    provider.addItemsToCard(widget.index);
    widget.onUpdate?.call();
  }
}
