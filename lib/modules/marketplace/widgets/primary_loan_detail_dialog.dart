import 'package:peerbridge/modules/marketplace/models/primary_loan_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Opens the primary-market loan detail sheet for the loan at [index].
Future<void> showPrimaryLoanDetails(
  BuildContext context, {
  required int index,
  VoidCallback? onFund,
}) {
  return showPbBottomSheet<void>(
    context: context,
    builder: (_) => PrimaryLoanDetailsDialog(index: index, onFund: onFund),
  );
}

class PrimaryLoanDetailsDialog extends StatefulWidget {
  final int index;
  final VoidCallback? onFund;

  const PrimaryLoanDetailsDialog({required this.index, this.onFund, Key? key})
      : super(key: key);

  @override
  State<PrimaryLoanDetailsDialog> createState() =>
      _PrimaryLoanDetailsDialogState();
}

class _PrimaryLoanDetailsDialogState extends State<PrimaryLoanDetailsDialog> {
  late final Future<PrimaryLoanDetails?> _details;

  @override
  void initState() {
    super.initState();
    _details = context.read<AppStateProvider>().getPrimaryLoanDetails(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppStateProvider>();
    final loan = provider.primaryMarketLoans![widget.index];
    final committed = loan.getCommittedPercentage().clamp(0, 100).toDouble();
    final onFund = widget.onFund;

    return FutureBuilder<PrimaryLoanDetails?>(
      future: _details,
      builder: (context, snap) {
        final details = snap.data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 6),
              child: PbSheetTitle(
                eyebrow: loan.contract.isNotEmpty
                    ? loan.contract
                    : loan.productName,
                title: loan.customerName,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loan.category != '')
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RiskTag.fromCategory(loan.category),
                      ),
                    const SizedBox(height: 14),
                    _MetricGrid(items: [
                      MapEntry('Loan amount',
                          '₹${loan.loanAmount.commaAddedValue()}'),
                      MapEntry('Interest rate (p.a.)', loan.listedRateLabel),
                      MapEntry('Duration',
                          '${loan.tenor.round()} ${loan.frequency.toFrequency()}'),
                      MapEntry('Frequency', loan.frequency),
                    ]),
                    const SizedBox(height: 16),
                    _FundingProgress(
                      committedAmount:
                          '₹${loan.alreadyCommitedAmount.commaAddedValue()}',
                      percent: committed,
                    ),
                    const SizedBox(height: 16),
                    if (snap.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.green),
                        ),
                      )
                    else if (details == null)
                      const PbEmptyState(
                        message: 'Borrower details are unavailable right now.',
                        icon: Icons.info_outline_rounded,
                      )
                    else ...[
                      DetailListCard(
                        title: 'About borrower',
                        rows: [
                          MapEntry('Age', '${details.aboutBorrower?.age} years'),
                          MapEntry('Gender', '${details.aboutBorrower?.gender}'),
                          MapEntry('State', '${details.aboutBorrower?.state}'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DetailListCard(
                        title: 'Financial details',
                        rows: [
                          MapEntry('Current net salary',
                              '₹${details.financialDetails?.currentNetSalary}'),
                          MapEntry('Bureau score',
                              '${details.financialDetails?.bureauScore}'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _BureauTable(loans: details.activeLoans),
                    ],
                  ],
                ),
              ),
            ),
            if (onFund != null && !loan.isMaxFunded())
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: PbPrimaryButton(
                  label: loan.isAddedToCart
                      ? 'Add ₹1,000 more'
                      : 'Fund this loan',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onFund();
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<MapEntry<String, String>> items;

  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: _metric(items[i])),
          const SizedBox(width: 10),
          Expanded(
              child: i + 1 < items.length
                  ? _metric(items[i + 1])
                  : const SizedBox.shrink()),
        ],
      ));
      if (i + 2 < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _metric(MapEntry<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mintSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: PbMetric(label: item.key, value: item.value, valueSize: 15),
    );
  }
}

class _FundingProgress extends StatelessWidget {
  final String committedAmount;
  final double percent;

  const _FundingProgress({required this.committedAmount, required this.percent});

  @override
  Widget build(BuildContext context) {
    return PbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Already committed', style: AppTextStyles.cardTitle),
              ),
              Text('${percent.toStringAsFixed(1)}%',
                  style: AppTextStyles.semiBold(13, color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              color: AppColors.green,
              backgroundColor: AppColors.mint,
            ),
          ),
          const SizedBox(height: 8),
          Text('$committedAmount funded by investors',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _BureauTable extends StatelessWidget {
  final ActiveLoans? loans;

  const _BureauTable({required this.loans});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, ActiveLoanDetail?>>[
      MapEntry('Credit cards', loans?.creditCards),
      MapEntry('Personal loans', loans?.personalLoan),
      MapEntry('Home loans', loans?.homeLoan),
    ];
    TextStyle head = AppTextStyles.semiBold(11, color: AppColors.muted);
    return PbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active credit (bureau)', style: AppTextStyles.cardTitle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(flex: 3, child: Text('LOAN TYPE', style: head)),
              Expanded(
                  flex: 2,
                  child: Text('COUNT', style: head, textAlign: TextAlign.center)),
              Expanded(
                  flex: 2,
                  child: Text('POS', style: head, textAlign: TextAlign.right)),
            ],
          ),
          for (final row in rows) ...[
            const Divider(height: 18, color: AppColors.line),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(row.key, style: AppTextStyles.medium(13))),
                Expanded(
                  flex: 2,
                  child: Text('${row.value?.numberLoan ?? 0}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.semiBold(13)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(row.value?.pos ?? 'N/A',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.semiBold(13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
