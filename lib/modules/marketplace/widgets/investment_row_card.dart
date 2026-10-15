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

  @override
  Widget build(BuildContext context) {
    final active = !isClosedInvestmentStatus(loan.status);
    return PbCard(
      radius: 18,
      onTap: () {
        final contract = loan.contractId ?? '';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((loan.productName ?? '').isNotEmpty)
                      Text(
                        loan.productName!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(10.5,
                                color: AppColors.green)
                            .copyWith(letterSpacing: 0.8),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      loan.borrowerName?.isNotEmpty == true
                          ? loan.borrowerName!
                          : (loan.contractId ?? '-'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(15),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(label: _statusLabel(loan.status), active: active),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
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
                  label: 'Rate',
                  value: '${loan.interestRate ?? 0}%',
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invested on ${loan.investedDate ?? '-'}',
                  style: AppTextStyles.caption,
                ),
              ),
              Text('Details',
                  style: AppTextStyles.semiBold(12, color: AppColors.green)),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.green),
            ],
          ),
        ],
      ),
    );
  }
}
