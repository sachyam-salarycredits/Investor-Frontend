import 'package:peerbridge/modules/marketplace/models/my_investments_data.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool isClosedInvestmentStatus(String? status) {
  final value = (status ?? '').toUpperCase();
  return value == 'CLOSED' || value == 'REDEEMED';
}

/// Portfolio loan row; opens the investment detail page on tap.
class InvestmentRowCard extends StatelessWidget {
  final MyInvestmentLoan loan;

  const InvestmentRowCard({Key? key, required this.loan}) : super(key: key);

  String _statusLabel(String? status) {
    final value = (status ?? '').trim();
    if (value.isEmpty) return '-';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  IconData _productIcon(String? product) {
    final value = (product ?? '').toLowerCase();
    if (value.contains('property') || value.contains('home')) {
      return Icons.apartment_rounded;
    }
    if (value.contains('business')) {
      return Icons.account_balance_wallet_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final active = !isClosedInvestmentStatus(loan.status);
    final contract = loan.contractId ?? '';
    final title = contract.isNotEmpty
        ? contract
        : (loan.borrowerName?.isNotEmpty == true ? loan.borrowerName! : '-');
    return PbCard(
      radius: 18,
      onTap: () {
        if (contract.isEmpty) return;
        context.pushNamed(
          RoutesName.MyInvestmentDetail,
          params: {Constants.contractId: contract},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PbIconTile(icon: _productIcon(loan.productName), size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(15),
                    ),
                    if ((loan.productName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        loan.productName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(label: _statusLabel(loan.status), active: active),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.green),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            children: [
              Expanded(
                child: PbMetric(
                  label: 'Invested',
                  value: '₹${(loan.investedAmount ?? 0).commaAddedValue()}',
                ),
              ),
              Expanded(
                child: PbMetric(
                  label: 'Interest earned',
                  value: '₹${(loan.interestReceived ?? 0).commaAddedValue()}',
                  valueColor: AppColors.green,
                ),
              ),
              Expanded(
                child: PbMetric(
                  label: 'ANR',
                  value: '${loan.interestRate ?? 0}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
