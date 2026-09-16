import 'package:Monexo/modules/marketplace/models/my_investments_data.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final about = detail?.aboutInvestmentOrder;
    final borrower = detail?.aboutBorrower;
    final financial = detail?.financialDetails;

    return Scaffold(
      backgroundColor: ColorsUtil.offWhite,
      body: SafeArea(
        child: MonexoLoader(
          isLoading: isLoading,
          child: Column(
            children: [
              Header(
                isBackBtnVisible: true,
                backOnPressed: () => context.pop(),
              ),
              TitleHeader(
                titleStr: detail?.borrowerName?.isNotEmpty == true
                    ? detail!.borrowerName!
                    : 'Loan Details',
                desStr: detail?.productName ?? widget.contractId,
              ),
              Expanded(
                child: detail == null && !isLoading
                    ? Center(
                        child: Text(
                          'Unable to load loan details.',
                          style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.lightBlack,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        children: [
                          _card(
                            title: 'Investment summary',
                            children: [
                              _row('Contract', detail?.contractId ?? '-'),
                              _row('Status', detail?.status ?? '-'),
                              _row(
                                'Invested amount',
                                '₹${(detail?.investedAmount ?? 0).commaAddedValue()}',
                              ),
                              _row(
                                  'Invested date', detail?.investedDate ?? '-'),
                              _row(
                                'Interest rate',
                                '${_v(about, 'interestRate')}%',
                              ),
                              _row('Tenor', '${_v(about, 'tenor')} months'),
                              _row(
                                'Interest received',
                                '₹${_v(about, 'interestReceived', '0')}',
                              ),
                              _row(
                                'Principal received',
                                '₹${_v(about, 'principalReceived', '0')}',
                              ),
                              _row(
                                'Principal outstanding',
                                '₹${_v(about, 'balancePrincipalOS', '0')}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _card(
                            title: 'About borrower',
                            children: [
                              _row('Name', detail?.borrowerName ?? '-'),
                              _row('Age', _v(borrower, 'age')),
                              _row('Gender', _v(borrower, 'gender')),
                              _row('State', _v(borrower, 'state')),
                              _row(
                                'Employment',
                                _v(borrower, 'employementType'),
                              ),
                              _row('Role', _v(borrower, 'role')),
                            ],
                          ),
                          if (financial != null && financial.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _card(
                              title: 'Financial details',
                              children: financial.entries
                                  .take(12)
                                  .map(
                                    (e) => _row(
                                      e.key,
                                      e.value?.toString() ?? '-',
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _card(
                            title: 'Repayments',
                            children: (detail?.repayments.isEmpty ?? true)
                                ? [
                                    Text(
                                      'No repayments received yet.',
                                      style: TextStyle(
                                        fontFamily: CustomFonts.nunito,
                                        fontSize: 13,
                                        color: ColorsUtil.lightGrey,
                                      ),
                                    ),
                                  ]
                                : detail!.repayments
                                    .map(
                                      (row) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              row['repaymentDate']?.toString() ??
                                                  '-',
                                              style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: ColorsUtil.blueColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Net ₹${row['netAmount'] ?? 0}  ·  Interest ₹${row['interest'] ?? 0}  ·  Principal ₹${row['principalReceived'] ?? 0}',
                                              style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontSize: 12,
                                                color: ColorsUtil.lightBlack,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsUtil.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsUtil.settingDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorsUtil.blueColor,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 13,
                color: ColorsUtil.lightGrey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorsUtil.blackish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
