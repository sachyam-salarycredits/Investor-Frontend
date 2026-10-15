import 'package:peerbridge/modules/marketplace/models/my_investments_data.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyInvestmentDetailScreen extends StatefulWidget {
  const MyInvestmentDetailScreen({Key? key, required this.contractId})
      : super(key: key);

  final String contractId;

  @override
  State<MyInvestmentDetailScreen> createState() =>
      _MyInvestmentDetailScreenState();
}

class _MyInvestmentDetailScreenState extends State<MyInvestmentDetailScreen> {
  bool isLoading = true;
  MyInvestmentDetail? detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await context
        .read<AppStateProvider>()
        .getMyInvestmentDetail(widget.contractId);
    if (!mounted) return;
    setState(() {
      detail = data;
      isLoading = false;
    });
  }

  String _v(Map<String, dynamic>? map, String key, [String fallback = '-']) {
    if (map == null) return fallback;
    final value = map[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  double _num(Map<String, dynamic>? map, String key) =>
      double.tryParse(_v(map, key, '0').replaceAll(',', '')) ?? 0;

  String _labelize(String key) {
    final spaced = key.replaceAllMapped(
        RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m.group(1)}');
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: PbPageHeader(
          title: 'Loan details',
          onBack: () => context.pop(),
        ),
        body: PeerBridgeLoader(
          isLoading: isLoading,
          child: detail == null && !isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PbEmptyState(
                          icon: Icons.cloud_off_rounded,
                          message: 'Unable to load loan details.',
                        ),
                        const SizedBox(height: 12),
                        PbGhostButton(
                          label: 'Try again',
                          icon: Icons.refresh_rounded,
                          onPressed: _load,
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: _content(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _content() {
    final about = detail?.aboutInvestmentOrder;
    final borrower = detail?.aboutBorrower;
    final financial = detail?.financialDetails;
    final invested = (detail?.investedAmount ?? 0).toDouble();
    final principalReceived = _num(about, 'principalReceived');
    final repaidPercent =
        invested > 0 ? (principalReceived / invested).clamp(0.0, 1.0) : 0.0;
    final status = detail?.status ?? '';
    final isActive = !['CLOSED', 'REDEEMED'].contains(status.toUpperCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          invested: invested,
          status: status,
          isActive: isActive,
          repaidPercent: repaidPercent.toDouble(),
          about: about,
        ),
        const SizedBox(height: 16),
        DetailListCard(
          title: 'Investment summary',
          rows: [
            MapEntry('Contract', detail?.contractId ?? widget.contractId),
            MapEntry('Invested on', detail?.investedDate ?? '-'),
            MapEntry('Interest received',
                '₹${_v(about, 'interestReceived', '0')}'),
            MapEntry('Principal received',
                '₹${_v(about, 'principalReceived', '0')}'),
            MapEntry('Principal outstanding',
                '₹${_v(about, 'balancePrincipalOS', '0')}'),
          ],
        ),
        const SizedBox(height: 14),
        DetailListCard(
          title: 'About borrower',
          rows: [
            MapEntry('Name', detail?.borrowerName ?? '-'),
            MapEntry('Age', _v(borrower, 'age')),
            MapEntry('Gender', _v(borrower, 'gender')),
            MapEntry('State', _v(borrower, 'state')),
            MapEntry('Employment', _v(borrower, 'employementType')),
            MapEntry('Role', _v(borrower, 'role')),
          ],
        ),
        if (financial != null && financial.isNotEmpty) ...[
          const SizedBox(height: 14),
          DetailListCard(
            title: 'Financial details',
            rows: financial.entries
                .take(12)
                .map((e) => MapEntry(_labelize(e.key).replaceAll('Monexo', 'PeerBridge'),
                    e.value?.toString() ?? '-'))
                .toList(),
          ),
        ],
        const SizedBox(height: 14),
        _repayments(),
      ],
    );
  }

  Widget _hero({
    required double invested,
    required String status,
    required bool isActive,
    required double repaidPercent,
    required Map<String, dynamic>? about,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
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
                    if ((detail?.productName ?? '').isNotEmpty)
                      Text(
                        detail!.productName!.toUpperCase(),
                        style: AppTextStyles.semiBold(10.5,
                                color: AppColors.goldLight)
                            .copyWith(letterSpacing: 0.8),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      detail?.borrowerName?.isNotEmpty == true
                          ? detail!.borrowerName!
                          : widget.contractId,
                      style: AppTextStyles.semiBold(19, color: Colors.white),
                    ),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1).toLowerCase(),
                    style: AppTextStyles.semiBold(11,
                        color: isActive ? AppColors.greenLink : Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Invested',
              style: AppTextStyles.medium(12,
                  color: Colors.white.withOpacity(0.7))),
          Text('₹${invested.round().commaAddedValue()}',
              style: AppTextStyles.bold(30, color: Colors.white)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: repaidPercent,
              minHeight: 7,
              color: AppColors.goldBright,
              backgroundColor: Colors.white.withOpacity(0.14),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(repaidPercent * 100).toStringAsFixed(0)}% of principal repaid',
              style: AppTextStyles.regular(11.5,
                  color: Colors.white.withOpacity(0.72))),
          const SizedBox(height: 16),
          Row(
            children: [
              _heroMetric('Interest rate', '${_v(about, 'interestRate')}%'),
              _heroMetric('Tenor', '${_v(about, 'tenor')} mo'),
              _heroMetric(
                  'Interest earned', '₹${_v(about, 'interestReceived', '0')}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.regular(11,
                  color: Colors.white.withOpacity(0.65))),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.semiBold(14, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _repayments() {
    final rows = detail?.repayments ?? const [];
    return PbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Repayments', style: AppTextStyles.cardTitle)),
              if (rows.isNotEmpty)
                Text('${rows.length} received', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Text('No repayments received yet.', style: AppTextStyles.bodyMuted)
          else
            for (var i = 0; i < rows.length; i++)
              _repaymentRow(rows[i], last: i == rows.length - 1),
        ],
      ),
    );
  }

  Widget _repaymentRow(Map<String, dynamic> row, {required bool last}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(width: 2, color: AppColors.mint),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          row['repaymentDate']?.toString() ?? '-',
                          style: AppTextStyles.semiBold(13),
                        ),
                      ),
                      Text('₹${row['netAmount'] ?? 0}',
                          style: AppTextStyles.semiBold(13,
                              color: AppColors.green)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Interest ₹${row['interest'] ?? 0}  ·  Principal ₹${row['principalReceived'] ?? 0}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
