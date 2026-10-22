import 'package:peerbridge/modules/home/models/PortfolioAnalysisModel.dart';
import 'package:peerbridge/modules/home/models/portfolio_summary.dart';
import 'package:peerbridge/modules/marketplace/models/my_investments_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/investment_row_card.dart';
import 'package:peerbridge/modules/shell/main_shell.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PortfolioAnalysis extends StatefulWidget {
  final bool embedded;

  const PortfolioAnalysis({Key? key, this.embedded = false}) : super(key: key);

  @override
  _PortfolioAnalysisState createState() => _PortfolioAnalysisState();
}

enum _PortfolioBookSection { active, closed }

class _PortfolioAnalysisState extends State<PortfolioAnalysis> {
  static const int _pageSize = 20;

  bool _isLoading = false;
  _PortfolioBookSection _selectedBook = _PortfolioBookSection.active;
  List<MyInvestmentLoan> _investments = [];
  bool _investmentsLoading = false;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    getPortfolioData();
    _loadInvestments();
    context.read<AppStateProvider>().getUserFundDetails();
  }

  String get _book => _selectedBook == _PortfolioBookSection.active
      ? 'active'
      : 'closed';

  Future<void> _loadInvestments({bool reset = true}) async {
    if (!reset && (_loadingMore || !_hasMore || _investmentsLoading)) return;
    if (reset && _investmentsLoading) return;
    final nextPage = reset ? 1 : _page + 1;
    if (!reset) _loadingMore = true;
    if (reset) _investmentsLoading = true;
    setState(() {
      if (reset) {
        _investmentsLoading = true;
      } else {
        _loadingMore = true;
      }
    });
    final data = await context.read<AppStateProvider>().getMyInvestments(
          book: _book,
          page: nextPage,
          pageSize: _pageSize,
        );
    if (!mounted) return;
    setState(() {
      final incoming = data?.loanList ?? [];
      _investments = reset ? incoming : [..._investments, ...incoming];
      _page = data?.page ?? nextPage;
      _hasMore = data?.hasMore ?? false;
      _investmentsLoading = false;
      _loadingMore = false;
    });
  }

  Future<void> getPortfolioData() async {
    setLoader(true);
    try {
      await context.read<AppStateProvider>().getPortfolioAnalysisData();
    } catch (e) {
      debugPrint('Portfolio analysis failed: $e');
    }
    setLoader(false);
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AppStateProvider>().getPortfolioAnalysisData(),
      _loadInvestments(),
    ]);
  }

  void setLoader(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  List<MyInvestmentLoan> get _visibleInvestments => _investments;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final summary = provider.portfolioSummary;
    final selected = _selectedBook == _PortfolioBookSection.active
        ? summary?.active
        : summary?.closed;

    final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.embedded
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: PeerBridgeLoader(
        isLoading: _isLoading,
        child: Scaffold(
          backgroundColor:
              widget.embedded ? Colors.transparent : AppColors.surface,
          appBar: widget.embedded
              ? null
              : PbPageHeader(
                  title: 'Portfolio',
                  onBack: () => context.pop(),
                ),
          body: SafeArea(
            top: widget.embedded,
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.green,
              onRefresh: _refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 240) {
                    _loadInvestments(reset: false);
                  }
                  return false;
                },
                child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.embedded) ...[
                            Text('Your portfolio',
                                style: AppTextStyles.medium(28).copyWith(
                                    height: 1.2, letterSpacing: -0.5)),
                            const SizedBox(height: 18),
                          ],
                          SegmentedTabs(
                            tabs: [
                              SegmentedTab('Active',
                                  count: summary?.active?.loanCount ?? 0),
                              SegmentedTab('Closed',
                                  count: summary?.closed?.loanCount ?? 0),
                            ],
                            selectedIndex:
                                _selectedBook == _PortfolioBookSection.active
                                    ? 0
                                    : 1,
                            onChanged: (i) {
                              final next = i == 0
                                  ? _PortfolioBookSection.active
                                  : _PortfolioBookSection.closed;
                              if (next == _selectedBook) return;
                              setState(() {
                                _selectedBook = next;
                                _investments = [];
                                _hasMore = false;
                              });
                              _loadInvestments();
                            },
                          ),
                          const SizedBox(height: 24),
                          PbSectionTitle(
                            title: 'Loan summary',
                            subtitle: _selectedBook ==
                                    _PortfolioBookSection.active
                                ? 'Returns from active loans only'
                                : 'Returns from closed loans only',
                          ),
                          const SizedBox(height: 14),
                          if (selected != null && selected.loanCount > 0)
                            _summarySection(selected)
                          else
                            PbEmptyState(
                              icon: Icons.pie_chart_outline_rounded,
                              message: _selectedBook ==
                                      _PortfolioBookSection.active
                                  ? 'No active loans in your portfolio yet.'
                                  : 'No closed loans in your portfolio yet.',
                            ),
                          const SizedBox(height: 28),
                          PbSectionTitle(
                            title: _selectedBook == _PortfolioBookSection.active
                                ? 'Active loans'
                                : 'Closed loans',
                            subtitle: _loansSubtitle(selected?.loanCount ??
                                _visibleInvestments.length),
                          ),
                          const SizedBox(height: 12),
                          _investmentsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) return scaffold;
    return WillPopScope(onWillPop: () async => true, child: scaffold);
  }

  String _loansSubtitle(int count) {
    final kind =
        _selectedBook == _PortfolioBookSection.active ? 'active' : 'closed';
    return '$count $kind ${count == 1 ? 'loan' : 'loans'}';
  }

  Widget _summarySection(PortfolioSectionSummary section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryTile(
                label: 'Total invested',
                value: '₹${section.totalInvested.commaAddedValue()}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryTile(
                label: 'Total return',
                value: '₹${section.totalReturn.commaAddedValue()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryTile(
                label: 'Absolute return',
                value: '${section.absoluteReturnPercent.toStringAsFixed(2)}%',
                positive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryTile(
                label: 'ANR earned',
                value: '${section.annualizedNetReturn.toStringAsFixed(2)}%',
                positive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryTile(
                label: 'Interest earned',
                value: '+₹${section.interestEarned.commaAddedValue()}',
                positive: true,
                highlight: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryTile(
                label: 'Platform fee',
                value: '₹${section.platformFee.commaAddedValue(digit: 2)}',
              ),
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
        child: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    if (_investments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PbEmptyState(
            icon: Icons.savings_outlined,
            message: "You haven't funded any loans yet.",
          ),
          const SizedBox(height: 12),
          PbPrimaryButton(
            label: 'Explore loans',
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: () => openShellTab(context, ShellTab.explore),
          ),
        ],
      );
    }

    final visible = _visibleInvestments;
    if (visible.isEmpty) {
      return PbEmptyState(
        icon: Icons.inbox_outlined,
        message: _selectedBook == _PortfolioBookSection.active
            ? 'No active loans.'
            : 'No closed loans.',
      );
    }

    return Column(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          InvestmentRowCard(loan: visible[i]),
        ],
        if (_hasMore) ...[
          const SizedBox(height: 16),
          _loadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                )
              : PbGhostButton(
                  label: 'Load more',
                  icon: Icons.expand_more_rounded,
                  onPressed: () => _loadInvestments(reset: false),
                ),
        ],
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
