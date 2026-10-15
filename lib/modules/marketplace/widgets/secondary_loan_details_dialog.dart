import 'package:peerbridge/modules/marketplace/models/secondary_market_loan_detail.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Opens the secondary-market loan detail sheet for the loan at [index].
Future<void> showSecondaryLoanDetails(BuildContext context,
    {required int index}) {
  return showPbBottomSheet<void>(
    context: context,
    builder: (_) => SecondaryLoanDetailsDialog(index: index),
  );
}

class SecondaryLoanDetailsDialog extends StatefulWidget {
  final int index;

  const SecondaryLoanDetailsDialog({required this.index, Key? key})
      : super(key: key);

  @override
  State<SecondaryLoanDetailsDialog> createState() =>
      _SecondaryLoanDetailsDialogState();
}

class _SecondaryLoanDetailsDialogState
    extends State<SecondaryLoanDetailsDialog> {
  late final Future<SecondaryMarketLoanDetail?> _details;

  @override
  void initState() {
    super.initState();
    _details = context
        .read<AppStateProvider>()
        .getSecondaryMarketLoanDetail(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final loan =
        context.read<AppStateProvider>().secondaryMarketLoans![widget.index];

    return FutureBuilder<SecondaryMarketLoanDetail?>(
      future: _details,
      builder: (context, snapshot) {
        final order = snapshot.data?.aboutInvestmentOrder;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 6),
              child: PbSheetTitle(
                eyebrow: 'Secondary market',
                title: loan.customerName,
                subtitle: 'Investment order ${loan.investorId}',
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loan.rating != null && loan.rating != '')
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RiskTag.fromCategory(loan.rating!),
                      ),
                    const SizedBox(height: 14),
                    DetailListCard(
                      title: 'Loan summary',
                      rows: [
                        MapEntry('Status', loan.status),
                        MapEntry('Interest rate', '${loan.interestRate}%'),
                        MapEntry('Tenor remaining',
                            '${loan.tenorRemaining.toInt()}'),
                        MapEntry('Loan disbursal date', loan.startDate ?? '-'),
                        MapEntry('EMI start date', loan.startDate ?? '-'),
                        MapEntry('EMI end date', loan.endDate ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.green),
                        ),
                      )
                    else if (snapshot.data == null)
                      const PbEmptyState(
                        message: 'Investment details are unavailable right now.',
                        icon: Icons.info_outline_rounded,
                      )
                    else
                      DetailListCard(
                        title: 'Overview of investment',
                        rows: [
                          MapEntry('Loan amount',
                              '₹${loan.sellingPrice.toStringAsFixed(2)}'),
                          MapEntry('Payment received till date',
                              '${order?.paymentReceivedTillDate ?? '-'}'),
                          MapEntry('Principal received',
                              '${order?.principalReceived ?? '-'}'),
                          MapEntry('Interest received',
                              '${order?.interestReceived ?? '-'}'),
                          MapEntry('Misc. income', '${order?.miscIncome ?? '-'}'),
                          MapEntry('Balance principal O/S',
                              '${order?.balancePrincipalOs ?? '-'}'),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
