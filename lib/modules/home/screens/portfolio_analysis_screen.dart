import 'package:Monexo/modules/home/models/DelinquencyStatusModel.dart';
import 'package:Monexo/modules/home/models/PortfolioAnalysisModel.dart';
import 'package:Monexo/modules/home/models/PortfolioTabStatusModel.dart';
import 'package:Monexo/modules/home/models/portfolio_summary.dart';
import 'package:Monexo/modules/marketplace/models/my_investments_data.dart';
import 'package:Monexo/modules/marketplace/widgets/outlined_popup_container.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/constants.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PortfolioAnalysis extends StatefulWidget {
  const PortfolioAnalysis({Key? key}) : super(key: key);

  @override
  _PortfolioAnalysisState createState() => _PortfolioAnalysisState();
}

enum _PortfolioBookSection { active, closed }

class _PortfolioAnalysisState extends State<PortfolioAnalysis>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  _PortfolioBookSection _selectedBook = _PortfolioBookSection.active;
  late TabController _riskTabController;
  late TabController _loanTennuretabController;
  late TabController _remainingLoanTenuretabController;
  late TabController _interestRatio;
  late TabController _delinquency;
  PortfolioAnalysisModel? portfolioResponse;
  List interestFinal = [];
  List<StackChartData> stackChartData = [];
  List<ChartData> chartData = [];
  bool isInvalidCid = false;
  bool isInterestEarnedShown = false;
  bool isRiskShown = false;
  bool isLoanTenureShown = false;
  bool isRemainingLoanShown = false;
  bool isInterestRatioShown = false;
  bool isDelinquencyShown = false;
  PortfolioTabStatusModel? portfolioTabStatusData;
  DelinquencyStatusModel? delinquencyTabStatusData;
  List<MyInvestmentLoan> _investments = [];
  bool _investmentsLoading = false;

  @override
  void initState() {
    getPortfolioTabStatus();
    getPortfolioData();
    _loadInvestments();
    context.read<AppStateProvider>().getUserFundDetails();

    // TODO: implement initState
    _riskTabController = new TabController(length: 2, vsync: this);
    _loanTennuretabController = new TabController(length: 2, vsync: this);
    _remainingLoanTenuretabController =
        new TabController(length: 2, vsync: this);
    _interestRatio = new TabController(length: 2, vsync: this);
    _delinquency = new TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> getPortfolioTabStatus() async {
    await context.read<AppStateProvider>().getPortfolioTabStatus();
    await context.read<AppStateProvider>().getDelinquencyStatus();
    delinquencyTabStatusData =
        context.read<AppStateProvider>().delinquencyTabStatusData;
    portfolioTabStatusData =
        context.read<AppStateProvider>().portfolioTabStatusData;

    final TabStatusList =
        context.read<AppStateProvider>().portfolioTabStatusData;
    isInterestEarnedShown = TabStatusList?.data
            .where((element) => element.name == 'INTEREST EARNED')
            .toList()
            .first
            .status ??
        false;
    // print('interest enr $isInterestEarnedShown');

    isRiskShown = TabStatusList?.data
            .where((element) => element.name == 'RISK')
            .toList()
            .first
            .status ??
        false;
    // print('risk $isRiskShown');

    isLoanTenureShown = TabStatusList?.data
            .where((element) => element.name == 'LOAN TENURE')
            .toList()
            .first
            .status ??
        false;
    // print('loan tenure $isLoanTenureShown');

    isRemainingLoanShown = TabStatusList?.data
            .where((element) => element.name == 'REMAINING TENURE')
            .toList()
            .first
            .status ??
        false;
    // print('remaing $isRemainingLoanShown');

    isInterestRatioShown = TabStatusList?.data
            .where((element) => element.name == 'INTEREST RATIO ')
            .toList()
            .first
            .status ??
        false;
    // print('interest ratio $isInterestRatioShown');
    // print(' ===${delinquencyTabStatusData?.data == '1' ? true : false}');

    isDelinquencyShown = ((TabStatusList?.data
                .where((element) => element.name == 'DELINQUENCY  ')
                .toList()
                .first
                .status ??
            false) &&
        (delinquencyTabStatusData?.data == '1' ? true : false));
    // print('delin $isDelinquencyShown');

    // Charts hidden for now — loan list is shown under Portfolio Summary.
    isInterestEarnedShown = false;
    isRiskShown = false;
    isLoanTenureShown = false;
    isRemainingLoanShown = false;
    isInterestRatioShown = false;
    isDelinquencyShown = false;
  }

  Future<void> _loadInvestments() async {
    setState(() => _investmentsLoading = true);
    final data = await context.read<AppStateProvider>().getMyInvestments();
    if (!mounted) return;
    setState(() {
      _investments = data?.loanList ?? [];
      _investmentsLoading = false;
    });
  }

  bool _isClosedInvestmentStatus(String? status) {
    final value = (status ?? '').toUpperCase();
    return value == 'CLOSED' || value == 'REDEEMED';
  }

  List<MyInvestmentLoan> get _visibleInvestments {
    if (_selectedBook == _PortfolioBookSection.active) {
      return _investments
          .where((loan) => !_isClosedInvestmentStatus(loan.status))
          .toList();
    }
    return _investments
        .where((loan) => _isClosedInvestmentStatus(loan.status))
        .toList();
  }

  Color _investmentStatusColor(String? status) {
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

  getPortfolioData() async {
    setLoader(true);
    await context.read<AppStateProvider>().getPortfolioAnalysisData();

    // portfolioAnalysisResponse =
    //
    //     await context.read<AppStateProvider>().getPortfolioAnalysisData();
    portfolioResponse = context.read<AppStateProvider>().portfolioAnalysis;

    print(portfolioResponse?.data?.statusCode);
    // print(portfolioResponse
    //     ?.data?.interestEarned?.interestEarned1?.percentInterestEarned);
    if (portfolioResponse?.data?.statusCode == 200) {
      if (portfolioResponse?.data?.interestEarned == null) {
        stackChartData = [];
      } else {
        InterestEarned interest =
            portfolioResponse?.data?.interestEarned ?? InterestEarned();
        // print('listtt==== ${interest}');

        interestFinal = [];
        interestFinal.add(interest.interestEarned6);
        interestFinal.add(interest.interestEarned5);
        interestFinal.add(interest.interestEarned4);
        interestFinal.add(interest.interestEarned3);
        interestFinal.add(interest.interestEarned2);
        interestFinal.add(interest.interestEarned1);
        print(interestFinal);

        for (int i = 0; i < interestFinal.length; i++) {
          stackChartData.add(
            StackChartData(
                interestFinal[i]
                        .statementMonth
                        ?.split(' ')
                        .first
                        .toUpperCase() ??
                    '',
                interestFinal[i].totalInvestement ?? 0,
                interestFinal[i].unInvestedAmount ?? 0,
                interestFinal[i].percentInterestEarned ?? 0),
          );
        }
        print('===$stackChartData');
        // stackChartData = [
        //   StackChartData('JAN', 38, 50, 60),
        //   StackChartData('FEB', 38, 50, 60),
        //   StackChartData('MAR', 34, 50, 70),
        //   StackChartData('APR', 52, 60, 79),
        //   StackChartData('MAY', 20, 59, 60),
        //   StackChartData('JUN', 80, 58, 30)
        // ];
      }
    } else {
      isInvalidCid = true;
      portfolioResponse = PortfolioAnalysisModel();
    }
    setLoader(false);
  }

  setLoader(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // isInvalidCid = true;
    var screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Portfolio Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                toolbarHeight: 70,
                backgroundColor: ColorsUtil.blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                leading: BackButton(
                  onPressed: () {
                    context.pop();
                  },
                ),
              )
            : null,
        body: MonexoLoader(
          isLoading: _isLoading,
          child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Container(
                      color: ColorsUtil.grey,
                      child: Column(
                        //mobile UI
                        children: [
                          isInvalidCid
                              ? Expanded(
                                  child: Container(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            image:
                                                AssetImage(LocalImages.noData),
                                            width: 150,
                                            height: 150,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "No Results found",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: ColorsUtil.blackish
                                                    .withOpacity(0.6)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: mainWidget(context),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Row(
                      // Web UI
                      children: [
                        Container(
                          width: screenSize.width * .56,
                          height: screenSize.height,
                          color: ColorsUtil.white,
                          child: Column(
                            children: [
                              Header(
                                isDownloadBarVisible: true,
                                backOnPressed: () {
                                  context.pop();
                                },
                              ),
                              isInvalidCid
                                  ? Expanded(
                                      child: Container(
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image(
                                                image: AssetImage(
                                                    LocalImages.noData),
                                                width: 150,
                                                height: 150,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                "No Results found",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorsUtil.blackish
                                                        .withOpacity(0.6)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          child: Center(
                                            child: Container(
                                              width: screenSize.width * .4,
                                              constraints:
                                                  BoxConstraints(maxWidth: 500),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [mainWidget(context)],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Container(
                          width: screenSize.width * .44,
                          color: ColorsUtil.blueColor,
                        )
                      ],
                    )),
        ),
      ),
    );
  }

  Color _healthColor(String health) {
    switch (health.toUpperCase()) {
      case 'GOOD':
      case 'COMPLETED':
        return ColorsUtil.green;
      case 'MODERATE':
      case 'REDEEMED':
        return ColorsUtil.orange;
      case 'CLOSED':
        return ColorsUtil.blueColor;
      default:
        return ColorsUtil.lightGrey;
    }
  }

  Widget _portfolioBookTabs(PortfolioSummary? summary) {
    final activeCount = summary?.active?.loanCount ?? 0;
    final closedCount = summary?.closed?.loanCount ?? 0;
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
            child: _portfolioBookTab(
              label: 'Active ($activeCount)',
              section: _PortfolioBookSection.active,
            ),
          ),
          Expanded(
            child: _portfolioBookTab(
              label: 'Closed ($closedCount)',
              section: _PortfolioBookSection.closed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolioBookTab({
    required String label,
    required _PortfolioBookSection section,
  }) {
    final selected = _selectedBook == section;
    return InkWell(
      onTap: () {
        if (_selectedBook == section) return;
        setState(() => _selectedBook = section);
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

  Widget _portfolioSummaryCards(PortfolioSectionSummary section) {
    final fourthTitle = _selectedBook == _PortfolioBookSection.active
        ? 'Principal Outstanding'
        : 'Interest Earned';
    final fourthValue = _selectedBook == _PortfolioBookSection.active
        ? '₹${section.principalOutstanding.commaAddedValue()}'
        : '₹${section.interestEarned.commaAddedValue()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _healthColor(section.health).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _healthColor(section.health)),
          ),
          child: Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  color: _healthColor(section.health), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Health',
                      style: TextStyle(
                        fontFamily: CustomFonts.nunito,
                        fontSize: 11,
                        color: ColorsUtil.lightGrey,
                      ),
                    ),
                    Text(
                      section.healthLabel,
                      style: TextStyle(
                        fontFamily: CustomFonts.nunito,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _healthColor(section.health),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${section.loanCount} loans',
                style: TextStyle(
                  fontFamily: CustomFonts.nunito,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.lightBlack,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.55 / 1,
          children: [
            OutlinePopupContainer(
              tabColor: ColorsUtil.portfolioTabColor1,
              tabBorderColor: ColorsUtil.portfolioTabBorderColor1,
              title: 'Total Invested',
              subtitle: '₹${section.totalInvested.commaAddedValue()}',
            ),
            OutlinePopupContainer(
              tabColor: ColorsUtil.portfolioTabColor2,
              tabBorderColor: ColorsUtil.portfolioTabBorderColor2,
              title: 'Total Return',
              subtitle: '₹${section.totalReturn.commaAddedValue()}',
            ),
            OutlinePopupContainer(
              tabColor: ColorsUtil.portfolioTabColor3,
              tabBorderColor: ColorsUtil.portfolioTabBorderColor3,
              title: '% Earned',
              subtitle: '${section.percentageEarned.toStringAsFixed(2)} %',
            ),
            OutlinePopupContainer(
              tabColor: ColorsUtil.portfolioTabColor1,
              tabBorderColor: ColorsUtil.portfolioTabBorderColor1,
              title: fourthTitle,
              subtitle: fourthValue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _investmentsSection() {
    if (_investmentsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final visible = _visibleInvestments;
    if (_investments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          "You haven't funded any loans yet.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 14,
            color: ColorsUtil.lightBlack,
          ),
        ),
      );
    }

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          _selectedBook == _PortfolioBookSection.active
              ? 'No active loans.'
              : 'No closed loans.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 14,
            color: ColorsUtil.lightBlack,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _investmentLoanCard(visible[i]),
        ],
      ],
    );
  }

  Widget _investmentLoanCard(MyInvestmentLoan loan) {
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
                    color: _investmentStatusColor(loan.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    loan.status ?? '-',
                    style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _investmentStatusColor(loan.status),
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
                _investmentMeta(
                  'Invested',
                  '₹${(loan.investedAmount ?? 0).commaAddedValue()}',
                ),
                _investmentMeta(
                  'Interest earned',
                  '₹${(loan.interestReceived ?? 0).commaAddedValue()}',
                ),
                _investmentMeta(
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

  Widget _investmentMeta(String label, String value) {
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

  Column mainWidget(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    final portfolioSummary = provider.portfolioSummary;
    final selectedSummary = _selectedBook == _PortfolioBookSection.active
        ? portfolioSummary?.active
        : portfolioSummary?.closed;
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 20,
                          width: 2,
                          color: ColorsUtil.blueColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'OVERVIEW',
                          style: TextStyle(
                              fontSize: 13,
                              fontFamily: CustomFonts.nunito,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      // height: 400,
                      // width: double.infinity,
                      child: Card(
                          child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        // height: 400,
                        child: Column(
                          children: [
                            Text(
                              'PORTFOLIO SUMMARY',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: CustomFonts.nunito,
                                color: ColorsUtil.greyTabColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _portfolioBookTabs(portfolioSummary),
                            const SizedBox(height: 12),
                            if (selectedSummary != null &&
                                selectedSummary.loanCount > 0)
                              _portfolioSummaryCards(selectedSummary)
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                child: Text(
                                  _selectedBook == _PortfolioBookSection.active
                                      ? 'No active loans in your portfolio.'
                                      : 'No closed loans in your portfolio.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 14,
                                    color: ColorsUtil.lightBlack,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'MY INVESTMENTS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: CustomFonts.nunito,
                                  color: ColorsUtil.greyTabColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _investmentsSection(),
                          ],
                        ),
                      )),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: isInterestEarnedShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 2,
                            color: ColorsUtil.blueColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'INTEREST EARNED (Data as of Last Month)',
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: CustomFonts.nunito,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        // height: 400,
                        // width: double.infinity,
                        child: Card(
                          child: portfolioResponse?.data?.interestEarned == null
                              ? Container(
                                  height: 400,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(LocalImages.noData),
                                          width: 150,
                                          height: 150,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "No Results found",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.blackish
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 400,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  child: SfCartesianChart(
                                      title: ChartTitle(
                                        text: 'Last 6 months INTEREST EARNED'
                                            .toUpperCase(),
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          fontFamily: CustomFonts.nunito,
                                          color: ColorsUtil.greyTabColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      palette: <Color>[
                                        ColorsUtil.blueColor,
                                        ColorsUtil.stackedChatColor,
                                        ColorsUtil.greenText
                                      ],
                                      primaryXAxis: CategoryAxis(
                                        axisLine: AxisLine(width: 0),
                                        majorGridLines:
                                            MajorGridLines(width: 0),
                                        labelStyle: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color: ColorsUtil.greyTabColor),
                                      ),
                                      primaryYAxis: CategoryAxis(
                                        axisLine: AxisLine(width: 0),
                                        isVisible: false,
                                        majorGridLines:
                                            MajorGridLines(width: 0),
                                      ),
                                      axes: <ChartAxis>[
                                        NumericAxis(
                                          borderColor: ColorsUtil.green,
                                          name: 'yAxis1',
                                          numberFormat:
                                              NumberFormat.compactCurrency(
                                                  symbol: ''),

                                          majorGridLines:
                                              MajorGridLines(width: 0),

                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color: ColorsUtil.greyTabColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          // title:
                                          //     AxisTitle(
                                          //   text:
                                          //       'Active Content',
                                          // )
                                        ),
                                        NumericAxis(
                                          interval: 0.5,
                                          axisLine: AxisLine(width: 0),
                                          name: 'yAxis2',
                                          labelFormat: '{value} %',
                                          opposedPosition: true,
                                          majorGridLines:
                                              MajorGridLines(width: 0),
                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color: ColorsUtil.greyTabColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          // title:
                                          //     AxisTitle(
                                          //   text:
                                          //       'Active Content',
                                          // )
                                        )
                                      ],
                                      legend: Legend(
                                        toggleSeriesVisibility: false,
                                        isVisible: true,
                                        position: LegendPosition.bottom,
                                        overflowMode:
                                            LegendItemOverflowMode.wrap,
                                      ),
                                      // primaryXAxis:
                                      //     CategoryAxis(),
                                      series: <CartesianSeries>[
                                        // Render column series
                                        ColumnSeries<StackChartData, String>(
                                            width: 0.4,
                                            yAxisName: 'yAxis1',
                                            name: 'Invested Amount',
                                            legendIconType:
                                                LegendIconType.circle,
                                            dataSource: stackChartData,
                                            xValueMapper:
                                                (StackChartData data, _) =>
                                                    data.x, // Month
                                            yValueMapper:
                                                (StackChartData data, _) =>
                                                    data.a), //totalInvestement
                                        ColumnSeries<StackChartData, String>(
                                            width: 0.4,
                                            yAxisName: 'yAxis1',
                                            name: 'Uninvested amount',
                                            legendIconType:
                                                LegendIconType.circle,
                                            dataSource: stackChartData,
                                            xValueMapper:
                                                (StackChartData data, _) =>
                                                    data.x, // Month
                                            yValueMapper: (StackChartData data,
                                                    _) =>
                                                data.b), // unInvestedAmount //
                                        // Render line series
                                        LineSeries<StackChartData, String>(
                                            width: 1.7,
                                            yAxisName: 'yAxis2',
                                            name: '% of Interest',
                                            markerSettings: MarkerSettings(
                                                height: 7,
                                                width: 7,
                                                borderWidth: 1.5,
                                                isVisible: true),
                                            legendIconType:
                                                LegendIconType.circle,
                                            dataSource: stackChartData,
                                            xValueMapper:
                                                (StackChartData data, _) =>
                                                    data.x, //Month
                                            yValueMapper:
                                                (StackChartData data, _) =>
                                                    data.c) // Percent
                                      ])),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isRiskShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 2,
                                color: ColorsUtil.blueColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'RISK (As of Now)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed(
                                  RoutesName.ViewDetailPortfolioAnalysis,
                                  params: {Constants.viewTitle: 'Risk'});
                            },
                            child: Text(
                              'View Details'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsUtil.blueColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Card(
                          child: Container(
                            height: 450,
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Column(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    //This is for background color
                                    color: Colors.white.withOpacity(0.0),
                                    //This is for bottom border that is needed
                                    border: Border(
                                        bottom: BorderSide(
                                            color: ColorsUtil.lightestGrey,
                                            width: 4)),
                                  ),
                                  child: TabBar(
                                    unselectedLabelColor:
                                        ColorsUtil.greyTabColor,
                                    labelColor: ColorsUtil.blueColor,
                                    indicatorColor: ColorsUtil.blueColor,
                                    indicatorWeight: 4,
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    tabs: [
                                      Tab(
                                        text: 'Number of loans',
                                      ),
                                      Tab(
                                        text: 'Amount',
                                      )
                                    ],
                                    controller: _riskTabController,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      portfolioResponse?.data?.riskNoOfLoans ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.riskNoOfLoans?.total ??
                                                  0,
                                              chartData: [
                                                ChartData(
                                                    'Conseravtive',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskNoOfLoans
                                                            ?.conservative
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Moderate',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskNoOfLoans
                                                            ?.medium
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'High',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskNoOfLoans
                                                            ?.high
                                                            ?.toDouble() ??
                                                        0.0),
                                                // Update value according to API
                                                ChartData(
                                                    'Closed',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskNoOfLoans
                                                            ?.closedLoans
                                                            ?.toDouble() ??
                                                        0.0),
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffFFDC4A),
                                              ],
                                            ),
                                      portfolioResponse?.data?.riskAmount ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.riskAmount?.total ??
                                                  0,
                                              showAmountSymbol: true,
                                              chartData: [
                                                ChartData(
                                                    'Conseravtive',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskAmount
                                                            ?.conservative
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Moderate',
                                                    portfolioResponse?.data
                                                            ?.riskAmount?.medium
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'High',
                                                    portfolioResponse?.data
                                                            ?.riskAmount?.high
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskAmount
                                                            ?.closedLoanAmount
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Uninvested Amount',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.riskAmount
                                                            ?.unInvestedAmount
                                                            ?.toDouble() ??
                                                        0.0),
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffFFDC4A),
                                                Color(0xffC67B00),
                                              ],
                                            ),
                                    ],
                                    controller: _riskTabController,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isLoanTenureShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: CardWidget(
                    tabController: _loanTennuretabController,
                    portfolioResponse: portfolioResponse,
                    title: 'LOAN TENURE (As of Now)',
                    onpressed: () {
                      context.pushNamed(RoutesName.ViewDetailPortfolioAnalysis,
                          params: {Constants.viewTitle: 'Loan Tenure'});
                    },
                    NoOfLoanDataToShow:
                        portfolioResponse?.data?.loanTenureNoOfLoans,
                    AmountDataToShow: portfolioResponse?.data?.loanTenureAmount,
                  ),
                ),
              ),
              Visibility(
                visible: isRemainingLoanShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: CardWidget(
                    tabController: _remainingLoanTenuretabController,
                    portfolioResponse: portfolioResponse,
                    title: 'REMAINING TENURE (As of Now)',
                    onpressed: () {
                      context.pushNamed(RoutesName.ViewDetailPortfolioAnalysis,
                          params: {Constants.viewTitle: 'Remaining Tenure'});
                    },
                    NoOfLoanDataToShow:
                        portfolioResponse?.data?.loanTenureNoOfLoansRemaining,
                    AmountDataToShow:
                        portfolioResponse?.data?.loanTenureAmountRemaining,
                  ),
                ),
              ),
              Visibility(
                visible: isInterestRatioShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 2,
                                color: ColorsUtil.blueColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'INTEREST RATIO (As of Now)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed(
                                  RoutesName.ViewDetailPortfolioAnalysis,
                                  params: {
                                    Constants.viewTitle: 'Interest Ratio'
                                  });
                            },
                            child: Text(
                              'View Details'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsUtil.blueColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Card(
                          child: Container(
                            height: 450,
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Column(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    //This is for background color
                                    color: Colors.white.withOpacity(0.0),
                                    //This is for bottom border that is needed
                                    border: Border(
                                        bottom: BorderSide(
                                            color: ColorsUtil.lightestGrey,
                                            width: 4)),
                                  ),
                                  child: TabBar(
                                    unselectedLabelColor:
                                        ColorsUtil.greyTabColor,
                                    labelColor: ColorsUtil.blueColor,
                                    indicatorColor: ColorsUtil.blueColor,
                                    indicatorWeight: 4,
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    tabs: [
                                      Tab(
                                        text: 'Number of loans',
                                      ),
                                      Tab(
                                        text: 'Amount',
                                      )
                                    ],
                                    controller: _interestRatio,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      portfolioResponse
                                                  ?.data?.interestNoOfLoan ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.interestNoOfLoan?.total
                                                      ?.toInt() ??
                                                  0,
                                              chartData: [
                                                ChartData(
                                                    '>17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.above171
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '<15%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.upto149
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '15%-17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.from15to17
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed > 17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.closedAbove171
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed < 15%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.closedUpto149
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed 15% - 17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestNoOfLoan
                                                            ?.closedFrom15to17
                                                            ?.toDouble() ??
                                                        0.0)
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffC67B00),
                                                Color(0xff3F704D),
                                                Color(0xffBFD7ED),
                                              ],
                                            ),
                                      portfolioResponse?.data?.interestAmount ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.interestAmount?.total
                                                      ?.toInt() ??
                                                  0,
                                              showAmountSymbol: true,
                                              chartData: [
                                                ChartData(
                                                    '>17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.above171
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '<15%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.upto149
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '15%-17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.from15to17
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed > 17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.closedAbove171
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed < 15%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.closedUpto149
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Closed 15% - 17%',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.interestAmount
                                                            ?.closedFrom15to17
                                                            ?.toDouble() ??
                                                        0.0),
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffC67B00),
                                                Color(0xff3F704D),
                                                Color(0xffBFD7ED),
                                              ],
                                            ),
                                    ],
                                    controller: _interestRatio,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: isDelinquencyShown,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 2,
                                color: ColorsUtil.blueColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'DELINQUENCY (As of Now)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed(
                                  RoutesName.ViewDetailPortfolioAnalysis,
                                  params: {Constants.viewTitle: 'Delinquency'});
                            },
                            child: Text(
                              'View Details'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsUtil.blueColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Card(
                          child: Container(
                            height: 520,
                            margin: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Column(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    //This is for background color
                                    color: Colors.white.withOpacity(0.0),
                                    //This is for bottom border that is needed
                                    border: Border(
                                        bottom: BorderSide(
                                            color: ColorsUtil.lightestGrey,
                                            width: 4)),
                                  ),
                                  child: TabBar(
                                    unselectedLabelColor:
                                        ColorsUtil.greyTabColor,
                                    labelColor: ColorsUtil.blueColor,
                                    indicatorColor: ColorsUtil.blueColor,
                                    indicatorWeight: 4,
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    tabs: [
                                      Tab(
                                        text: 'Number of loans',
                                      ),
                                      Tab(
                                        text: 'Amount',
                                      )
                                    ],
                                    controller: _delinquency,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      portfolioResponse
                                                  ?.data?.deliquencyCount ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.deliquencyCount?.total
                                                      ?.toInt() ??
                                                  0,
                                              chartData: [
                                                ChartData(
                                                    '>24 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.above_24M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '12-24 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.bwt_12M_24M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '>6 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.above_6M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '6-12 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.bwt_6M_12M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '3-6 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.bwt_3M_6M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '<3 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.less_3M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Uninvested Amount',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.uninvestedAmount
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Good Standing',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyCount
                                                            ?.goodStanding
                                                            ?.toDouble() ??
                                                        0.0),
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffFFDC4A),
                                                Color(0xffC67B00),
                                                Color(0xff3F704D),
                                                Color(0xffBFD7ED),
                                                Color(0xff5C5CFF),
                                              ],
                                            ),
                                      portfolioResponse
                                                  ?.data?.deliquencyAmount ==
                                              null
                                          ? Container(
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image(
                                                      image: AssetImage(
                                                          LocalImages.noData),
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "No Results found",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ColorsUtil
                                                              .blackish
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : DoughnutChartWidget(
                                              total: portfolioResponse?.data
                                                      ?.deliquencyAmount?.total
                                                      ?.toInt() ??
                                                  0,
                                              showAmountSymbol: true,
                                              chartData: [
                                                ChartData(
                                                    '>24 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.above_24M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '12-24 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.bwt_12M_24M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '>6 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.above_6M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '6-12 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.bwt_6M_12M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '3-6 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.bwt_3M_6M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    '<3 Month',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.less_3M
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Uninvested Amount',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.uninvestedAmount
                                                            ?.toDouble() ??
                                                        0.0),
                                                ChartData(
                                                    'Good Standing',
                                                    portfolioResponse
                                                            ?.data
                                                            ?.deliquencyAmount
                                                            ?.goodStanding
                                                            ?.toDouble() ??
                                                        0.0),
                                              ],
                                              paletteList: [
                                                Color(0xffD9ED92),
                                                Color(0xff52B69A),
                                                ColorsUtil.blueColor,
                                                Color(0xffFFDC4A),
                                                Color(0xffC67B00),
                                                Color(0xff3F704D),
                                                Color(0xffBFD7ED),
                                                Color(0xff5C5CFF),
                                              ],
                                            ),
                                    ],
                                    controller: _delinquency,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )

        // mainWidgets(context),
      ],
    );
  }
}

class CardWidget extends StatelessWidget {
  CardWidget(
      {Key? key,
      required this.tabController,
      required this.portfolioResponse,
      required this.title,
      required this.onpressed,
      required this.NoOfLoanDataToShow,
      required this.AmountDataToShow})
      : super(key: key);

  TabController tabController;
  final PortfolioAnalysisModel? portfolioResponse;
  String title;
  Function() onpressed;
  var NoOfLoanDataToShow;
  var AmountDataToShow;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 2,
                    color: ColorsUtil.blueColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onpressed,
                //     () {
                //   context.pushNamed(RoutesName.ViewDetailPortfolioAnalysis,
                //       params: {Constants.viewTitle: 'Loan Tenure'});
                // },
                child: Text(
                  'View Details'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.blueColor),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Card(
              child: Container(
                height: 450,
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        //This is for background color
                        color: Colors.white.withOpacity(0.0),
                        //This is for bottom border that is needed
                        border: Border(
                            bottom: BorderSide(
                                color: ColorsUtil.lightestGrey, width: 4)),
                      ),
                      child: TabBar(
                        unselectedLabelColor: ColorsUtil.greyTabColor,
                        labelColor: ColorsUtil.blueColor,
                        indicatorColor: ColorsUtil.blueColor,
                        indicatorWeight: 4,
                        labelStyle: TextStyle(
                          fontSize: 15,
                          fontFamily: CustomFonts.nunito,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: [
                          Tab(
                            text: 'Number of loans',
                          ),
                          Tab(
                            text: 'Amount',
                          )
                        ],
                        controller: tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          NoOfLoanDataToShow == null
                              ? Container(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(LocalImages.noData),
                                          width: 150,
                                          height: 150,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "No Results found",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.blackish
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : DoughnutChartWidget(
                                  total: NoOfLoanDataToShow?.total ?? 0,
                                  chartData: [
                                    ChartData(
                                        '24 Month',
                                        NoOfLoanDataToShow?.above_24M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '12-24 Month',
                                        NoOfLoanDataToShow?.bwt_12M_24M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '6-12 Month',
                                        NoOfLoanDataToShow?.bwt_6M_12M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '3-6 Month',
                                        NoOfLoanDataToShow?.bwt_3M_6M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '<3 Month',
                                        NoOfLoanDataToShow?.less_3M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        'Closed',
                                        NoOfLoanDataToShow?.closed
                                                ?.toDouble() ??
                                            0.0)
                                  ],
                                  paletteList: [
                                    Color(0xffBFD7ED),
                                    Color(0xffD9ED92),
                                    Color(0xff405AA9),
                                    Color(0xffC67B00),
                                    Color(0xff52B69A),
                                    Color(0xffFFDC4A),
                                  ],
                                ),
                          AmountDataToShow == null
                              ? Container(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          image: AssetImage(LocalImages.noData),
                                          width: 150,
                                          height: 150,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "No Results found",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.blackish
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : DoughnutChartWidget(
                                  total: AmountDataToShow?.total ?? 0,
                                  showAmountSymbol: true,
                                  chartData: [
                                    ChartData(
                                        '24 Month',
                                        AmountDataToShow?.above_24M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '12-24 Month',
                                        AmountDataToShow?.bwt_12M_24M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '6-12 Month',
                                        AmountDataToShow?.bwt_6M_12M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '3-6 Month',
                                        AmountDataToShow?.bwt_3M_6M
                                                ?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        '<3 Month',
                                        AmountDataToShow?.less_3M?.toDouble() ??
                                            0.0),
                                    ChartData(
                                        'Closed',
                                        AmountDataToShow?.closed?.toDouble() ??
                                            0.0),
                                  ],
                                  paletteList: [
                                    Color(0xffBFD7ED),
                                    Color(0xffD9ED92),
                                    Color(0xff405AA9),
                                    Color(0xffC67B00),
                                    Color(0xff52B69A),
                                    Color(0xffFFDC4A),
                                  ],
                                ),
                        ],
                        controller: tabController,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoughnutChartWidget extends StatelessWidget {
  DoughnutChartWidget({
    Key? key,
    required this.chartData,
    required this.paletteList,
    required this.total,
    this.showAmountSymbol = false,
  }) : super(key: key);

  final List<ChartData> chartData;
  List<Color> paletteList;
  int total;
  bool showAmountSymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SfCircularChart(palette: paletteList, annotations: [
          CircularChartAnnotation(
              widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                showAmountSymbol
                    ? '₹ ${NumberFormat.compact().format(total)}'
                    : '$total',
                style: const TextStyle(
                    fontSize: 20,
                    color: ColorsUtil.lightGrey,
                    fontWeight: FontWeight.w700
                    // fontFamily:CustomFonts.nunito,
                    ),
              ),
              Text(
                showAmountSymbol ? 'Active Loans' : 'Total Loans',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorsUtil.greyTabColor,
                  // fontFamily:CustomFonts.nunito,
                ),
              ),
            ],
          ))
        ], series: <CircularSeries>[
          // Renders doughnut chart
          DoughnutSeries<ChartData, String>(
              innerRadius: '65',
              legendIconType: LegendIconType.circle,
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y)
        ]),
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          runSpacing: 10,
          spacing: 15,
          children: [
            for (int i = 0; i < chartData.length; i++)
              UnconstrainedBox(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: paletteList[i],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      showAmountSymbol
                          ? '(${NumberFormat.compact().format((chartData[i].y))})'
                          : '(${chartData[i].y.toStringAsFixed(0)})',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: CustomFonts.nunito,
                        color: ColorsUtil.viewDetailTabColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      chartData[i].x.toString(),
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: CustomFonts.nunito,
                        color: ColorsUtil.viewDetailTabColor,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ],
    ));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class StackChartData {
  StackChartData(this.x, this.a, this.b, this.c);
  final String x;
  final double a;
  final double b;
  final double c;
}
