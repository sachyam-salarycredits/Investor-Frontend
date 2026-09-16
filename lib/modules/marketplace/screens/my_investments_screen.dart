import 'package:Monexo/modules/marketplace/models/my_investments_data.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/constants.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _LoanSection { active, closed }

class MyInvestmentsScreen extends StatefulWidget {
  const MyInvestmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyInvestmentsScreen> createState() => _MyInvestmentsScreenState();
}

class _MyInvestmentsScreenState extends State<MyInvestmentsScreen> {
  bool isLoading = true;
  List<MyInvestmentLoan> loans = [];
  _LoanSection selectedSection = _LoanSection.active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await context.read<AppStateProvider>().getMyInvestments();
    if (!mounted) return;
    setState(() {
      loans = data?.loanList ?? [];
      isLoading = false;
    });
  }

  bool _isClosedStatus(String? status) {
    final value = (status ?? '').toUpperCase();
    return value == 'CLOSED' || value == 'REDEEMED';
  }

  List<MyInvestmentLoan> get _activeLoans =>
      loans.where((loan) => !_isClosedStatus(loan.status)).toList();

  List<MyInvestmentLoan> get _closedLoans =>
      loans.where((loan) => _isClosedStatus(loan.status)).toList();

  List<MyInvestmentLoan> get _visibleLoans =>
      selectedSection == _LoanSection.active ? _activeLoans : _closedLoans;

  Color _statusColor(String? status) {
    switch ((status ?? '').toUpperCase()) {
      case 'ACTIVE':
        return ColorsUtil.green;
      case 'CLOSED':
        return ColorsUtil.blueColor;
      case 'REDEEMED':
        return ColorsUtil.orange;
      default:
        return ColorsUtil.lightGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleLoans;

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
              TitleHeader(titleStr: 'My Investments'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: _sectionTabs(),
              ),
              Expanded(
                child: loans.isEmpty && !isLoading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            "You haven't funded any loans yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 15,
                              color: ColorsUtil.lightBlack,
                            ),
                          ),
                        ),
                      )
                    : visible.isEmpty && !isLoading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                selectedSection == _LoanSection.active
                                    ? 'No active loans.'
                                    : 'No closed loans.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 15,
                                  color: ColorsUtil.lightBlack,
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: visible.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _loanCard(visible[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTabs() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorsUtil.lightestGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _sectionTab(
              label: 'Active (${_activeLoans.length})',
              section: _LoanSection.active,
            ),
          ),
          Expanded(
            child: _sectionTab(
              label: 'Closed (${_closedLoans.length})',
              section: _LoanSection.closed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTab({
    required String label,
    required _LoanSection section,
  }) {
    final selected = selectedSection == section;
    return InkWell(
      onTap: () {
        if (selectedSection == section) return;
        setState(() => selectedSection = section);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? ColorsUtil.blueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? ColorsUtil.white : ColorsUtil.lightBlack,
          ),
        ),
      ),
    );
  }

  Widget _loanCard(MyInvestmentLoan loan) {
    return InkWell(
      onTap: () {
        final contract = loan.contractId ?? '';
        if (contract.isEmpty) return;
        context.pushNamed(
          RoutesName.MyInvestmentDetail,
          params: {
            Constants.contractId: contract,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorsUtil.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorsUtil.settingDivider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.borrowerName?.isNotEmpty == true
                        ? loan.borrowerName!
                        : (loan.contractId ?? '-'),
                    style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorsUtil.blueColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(loan.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    loan.status ?? '-',
                    style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(loan.status),
                    ),
                  ),
                ),
              ],
            ),
            if ((loan.productName ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  loan.productName!,
                  style: TextStyle(
                    fontFamily: CustomFonts.nunito,
                    fontSize: 13,
                    color: ColorsUtil.lightGrey,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                _meta(
                  'Invested',
                  '₹${(loan.investedAmount ?? 0).commaAddedValue()}',
                ),
                _meta(
                  'Interest earned',
                  '₹${(loan.interestReceived ?? 0).commaAddedValue()}',
                ),
                _meta(
                  'Rate',
                  '${loan.interestRate ?? 0}%',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Invested on ${loan.investedDate ?? '-'}  ·  ${loan.contractId ?? ''}',
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 11,
                color: ColorsUtil.lightGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 11,
              color: ColorsUtil.lightGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ColorsUtil.blackish,
            ),
          ),
        ],
      ),
    );
  }
}
