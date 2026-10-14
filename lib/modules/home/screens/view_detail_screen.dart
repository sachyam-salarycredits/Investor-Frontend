// import 'dart:html';

import 'dart:io';

import 'package:Monexo/modules/home/models/ViewRiskDataModel.dart';
import 'package:Monexo/modules/home/screens/portfolio_analysis_screen.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../providers/app_state_provider.dart';
import '../../../utils/generate_pdf.dart';
import '../models/PortfolioAnalysisModel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io' as io;

import '../models/ViewDataModel.dart';

class ViewDetailPortfolioAnalysis extends StatefulWidget {
  final String viewTitle;

  ViewDetailPortfolioAnalysis({
    Key? key,
    required this.viewTitle,
  }) : super(key: key);

  @override
  _ViewDetailPortfolioAnalysisState createState() =>
      _ViewDetailPortfolioAnalysisState();
}

class _ViewDetailPortfolioAnalysisState
    extends State<ViewDetailPortfolioAnalysis>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;
  final _horizontalscrollController = ScrollController();
  final _verticalscrollController = ScrollController();
  String? selectedTab;
  PortfolioAnalysisModel? portfolioResponse;
  ViewDataModel? portfolioRiskResponse;
  bool isInvalidCid = false;
  RiskNoOfLoans? riskNoOfLoans;
  var pieChartNoOfLoansData;
  var pieChartAmountsData;
  List<ChartData> noOfLoansChartData = [];
  List<ChartData> amountChartData = [];
  List<Color> paletteList = [];
  int dataLength = 0;
  // late Page page;

  List<String> tabList = [];
  List<InvestOrderList> riskTableData = [];
  List<RemainingTenureData> loanTenureTableData = [];
  List<RemainingTenureData> remainingLoanTenureTableData = [];
  List<DelinquencyList> delinquencyTableData = [];
  List<InterestRateList> interestTableData = [];

  @override
  void initState() {
    // TODO: implement initState
    _tabController = new TabController(length: 2, vsync: this);
    portfolioResponse = context.read<AppStateProvider>().portfolioAnalysis;
    getTabData(widget.viewTitle);
    getChartData();
    getPortfolioRiskData();

    super.initState();
  }

  getTabData(String title) {
    switch (title) {
      case 'Risk':
        // do something
        tabList = ['Conseravtive', 'Moderate', 'High'];
        break;
      case 'Interest Ratio':
        tabList = ['> 17.1%', '< 15%', '15% - 17%'];
        // do something else
        break;
      case 'Delinquency':
        tabList = [
          '> 24 Months',
          '12 - 24 Months',
          '6 Month',
          '6 - 12 Months',
          '3 - 6 Months',
          '< 3 Months',
          // 'Uninvested Amount'
        ];
        // do something else
        break;
      default:
        tabList = [
          '> 24 Months',
          '12 - 24 Months',
          '6 - 12 Months',
          '3 - 6 Months',
          '< 3 Months'
        ];
        break;
    }
    selectedTab = tabList.first;
  }

  getChartData() {
    if (widget.viewTitle == 'Risk') {
      pieChartNoOfLoansData = portfolioResponse?.data?.riskNoOfLoans;
      pieChartAmountsData = portfolioResponse?.data?.riskAmount;
      noOfLoansChartData = [
        ChartData('Conseravtive',
            pieChartNoOfLoansData?.conservative?.toDouble() ?? 0.0),
        ChartData('Moderate', pieChartNoOfLoansData?.medium?.toDouble() ?? 0.0),
        ChartData('High', pieChartNoOfLoansData?.high?.toDouble() ?? 0.0),
        ChartData(
            'Closed', pieChartNoOfLoansData?.closedLoans?.toDouble() ?? 0.0),
      ];

      amountChartData = [
        ChartData('Conseravtive',
            pieChartAmountsData?.conservative?.toDouble() ?? 0.0),
        ChartData('Moderate', pieChartAmountsData?.medium?.toDouble() ?? 0.0),
        ChartData('High', pieChartAmountsData?.high?.toDouble() ?? 0.0),
        ChartData(
            'Closed', pieChartAmountsData?.closedLoanAmount?.toDouble() ?? 0.0),
        ChartData('Uninvested Amount',
            pieChartAmountsData?.unInvestedAmount?.toDouble() ?? 0.0),
      ];
      paletteList = [
        Color(0xffD9ED92),
        Color(0xff52B69A),
        ColorsUtil.blueColor,
        Color(0xffFFDC4A),
        Color(0xffC67B00),
      ];
    } else if (widget.viewTitle == 'Interest Ratio') {
      pieChartNoOfLoansData = portfolioResponse?.data?.interestNoOfLoan;
      pieChartAmountsData = portfolioResponse?.data?.interestAmount;
      noOfLoansChartData = [
        ChartData('>17%', pieChartNoOfLoansData?.above171?.toDouble() ?? 0.0),
        ChartData('<15%', pieChartNoOfLoansData?.upto149?.toDouble() ?? 0.0),
        ChartData(
            '15%-17%', pieChartNoOfLoansData?.from15to17?.toDouble() ?? 0.0),
        ChartData('Closed > 17%',
            pieChartNoOfLoansData?.closedAbove171?.toDouble() ?? 0.0),
        ChartData('Closed < 15%',
            pieChartNoOfLoansData?.closedUpto149?.toDouble() ?? 0.0),
        ChartData('Closed 15% - 17%',
            pieChartNoOfLoansData?.closedFrom15to17?.toDouble() ?? 0.0),
      ];
      amountChartData = [
        ChartData('>17%', pieChartAmountsData?.above171?.toDouble() ?? 0.0),
        ChartData('<15%', pieChartAmountsData?.upto149?.toDouble() ?? 0.0),
        ChartData(
            '15%-17%', pieChartAmountsData?.from15to17?.toDouble() ?? 0.0),
        ChartData('Closed > 17%',
            pieChartAmountsData?.closedAbove171?.toDouble() ?? 0.0),
        ChartData('Closed < 15%',
            pieChartAmountsData?.closedUpto149?.toDouble() ?? 0.0),
        ChartData('Closed 15% - 17%',
            pieChartAmountsData?.closedFrom15to17?.toDouble() ?? 0.0),
      ];
      paletteList = [
        Color(0xffD9ED92),
        Color(0xff52B69A),
        ColorsUtil.blueColor,
        Color(0xffC67B00),
        Color(0xff3F704D),
        Color(0xffBFD7ED),
      ];
    } else if (widget.viewTitle == 'Delinquency') {
      pieChartNoOfLoansData = portfolioResponse?.data?.deliquencyCount;
      pieChartAmountsData = portfolioResponse?.data?.deliquencyAmount;

      noOfLoansChartData = [
        ChartData(
            '>24 Month', pieChartNoOfLoansData?.above_24M?.toDouble() ?? 0.0),
        ChartData('12-24 Month',
            pieChartNoOfLoansData?.bwt_12M_24M?.toDouble() ?? 0.0),
        ChartData(
            '>6 Month', pieChartNoOfLoansData?.above_6M?.toDouble() ?? 0.0),
        ChartData(
            '6-12 Month', pieChartNoOfLoansData?.bwt_6M_12M?.toDouble() ?? 0.0),
        ChartData(
            '3-6 Month', pieChartNoOfLoansData?.bwt_3M_6M?.toDouble() ?? 0.0),
        ChartData(
            '<3 Month', pieChartNoOfLoansData?.less_3M?.toDouble() ?? 0.0),
        ChartData('Uninvested Amount',
            pieChartNoOfLoansData?.uninvestedAmount?.toDouble() ?? 0.0),
        ChartData('Good Standing',
            pieChartNoOfLoansData?.goodStanding?.toDouble() ?? 0.0),
      ];
      amountChartData = [
        ChartData(
            '>24 Month', pieChartAmountsData?.above_24M?.toDouble() ?? 0.0),
        ChartData('12-24 Months',
            pieChartAmountsData?.bwt_12M_24M?.toDouble() ?? 0.0),
        ChartData('>6 Month', pieChartAmountsData?.above_6M?.toDouble() ?? 0.0),
        ChartData(
            '6-12 Month', pieChartAmountsData?.bwt_6M_12M?.toDouble() ?? 0.0),
        ChartData(
            '3-6 Month', pieChartAmountsData?.bwt_3M_6M?.toDouble() ?? 0.0),
        ChartData('<3 Month', pieChartAmountsData?.less_3M?.toDouble() ?? 0.0),
        ChartData('Uninvested Amount',
            pieChartAmountsData?.uninvestedAmount?.toDouble() ?? 0.0),
        ChartData('Good Standing',
            pieChartAmountsData?.goodStanding?.toDouble() ?? 0.0),
      ];
      paletteList = [
        Color(0xffD9ED92),
        Color(0xff52B69A),
        ColorsUtil.blueColor,
        Color(0xffFFDC4A),
        Color(0xffC67B00),
        Color(0xff3F704D),
        Color(0xffBFD7ED),
        Color(0xff5C5CFF),
      ];
    } else {
      // print('1else');
      if (widget.viewTitle == 'Loan Tenure') {
        // print('loan tenure');
        pieChartNoOfLoansData = portfolioResponse?.data?.loanTenureNoOfLoans;
        pieChartAmountsData = portfolioResponse?.data?.loanTenureAmount;
      } else if (widget.viewTitle == 'Remaining Tenure') {
        // print('remaining loan tenure');
        pieChartNoOfLoansData = [];
        pieChartAmountsData = [];
        pieChartNoOfLoansData =
            portfolioResponse?.data?.loanTenureNoOfLoansRemaining;
        pieChartAmountsData =
            portfolioResponse?.data?.loanTenureAmountRemaining;
      }
      noOfLoansChartData = [
        ChartData(
            '24 Month', pieChartNoOfLoansData?.above_24M?.toDouble() ?? 0.0),
        ChartData('12-24 Month',
            pieChartNoOfLoansData?.bwt_12M_24M?.toDouble() ?? 0.0),
        ChartData(
            '6-12 Month', pieChartNoOfLoansData?.bwt_6M_12M?.toDouble() ?? 0.0),
        ChartData(
            '3-6 Month', pieChartNoOfLoansData?.bwt_3M_6M?.toDouble() ?? 0.0),
        ChartData(
            '<3 Month', pieChartNoOfLoansData?.less_3M?.toDouble() ?? 0.0),
        ChartData('Closed', pieChartNoOfLoansData?.closed?.toDouble() ?? 0.0),
      ];
      amountChartData = [
        ChartData(
            '24 Month', pieChartAmountsData?.above_24M?.toDouble() ?? 0.0),
        ChartData(
            '12-24 Month', pieChartAmountsData?.bwt_12M_24M?.toDouble() ?? 0.0),
        ChartData(
            '6-12 Month', pieChartAmountsData?.bwt_6M_12M?.toDouble() ?? 0.0),
        ChartData(
            '3-6 Month', pieChartAmountsData?.bwt_3M_6M?.toDouble() ?? 0.0),
        ChartData('<3 Month', pieChartAmountsData?.less_3M?.toDouble() ?? 0.0),
        ChartData('Closed', pieChartAmountsData?.closed?.toDouble() ?? 0.0),
      ];
      paletteList = [
        Color(0xffBFD7ED),
        Color(0xffD9ED92),
        Color(0xff405AA9),
        Color(0xffC67B00),
        Color(0xff52B69A),
        Color(0xffFFDC4A),
      ];
    }
  }

  getPortfolioRiskData() async {
    setLoader(true);
    await context.read<AppStateProvider>().getPortfolioRiskData();
    portfolioRiskResponse =
        context.read<AppStateProvider>().portfolioRiskAnalysis;

    print(portfolioRiskResponse?.data?.statusCode);
    if (portfolioRiskResponse?.data?.statusCode == 200) {
      // According to Selected Tab.
      riskTableData =
          portfolioRiskResponse?.data?.risk?.conservative?.investOrderList ??
              [];
      loanTenureTableData = portfolioRiskResponse?.data?.tenureData
              ?.where((element) => element.termCategory == selectedTab)
              .toSet()
              .toList() ??
          [];
      remainingLoanTenureTableData = portfolioRiskResponse
              ?.data?.remainingTenureData
              ?.where((element) => element.termCategory == selectedTab)
              .toSet()
              .toList() ??
          [];
      delinquencyTableData = portfolioRiskResponse?.data?.delinquencyList
              ?.where((element) => element.deliquentRange == selectedTab)
              .toSet()
              .toList() ??
          [];
      interestTableData = portfolioRiskResponse?.data?.interestRateList
              ?.where(
                  (element) => element.interestRateonLoanRange == selectedTab)
              .toSet()
              .toList() ??
          [];
      getPortfolioDataLength();
    } else {
      isInvalidCid = true;
      portfolioRiskResponse = ViewDataModel();
    }
    setLoader(false);
  }

  setLoader(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void getPortfolioDataLength() {
    switch (widget.viewTitle) {
      case 'Risk':
        dataLength = riskTableData.length;
        break;
      case 'Interest Ratio':
        dataLength = interestTableData.length;
        break;
      case 'Delinquency':
        dataLength = delinquencyTableData.length;
        break;
      case 'Loan Tenure':
        dataLength = loanTenureTableData.length;
        break;
      case 'Remaining Tenure':
        dataLength = remainingLoanTenureTableData.length;
        break;
      default:
        dataLength = 0;
        break;
    }
  }

  PortfolioDataModel? getPortfolioRowValue(int index) {
    PortfolioDataModel? dataModel;
    switch (widget.viewTitle) {
      case 'Risk':
        dataModel = PortfolioDataModel(
            date: DateFormat('MMM yyyy').format(DateTime.parse(
                riskTableData[index].loanInvestorStartDateC ?? '')),
            amount:
                riskTableData[index].loanInvestmentAmountC.commaAddedValue(),
            xirr:
                '${riskTableData[index].loanLoanR?.slxirrc?.toStringAsFixed(2)}%',
            status: riskTableData[index].loanStatusC == 'Inactive'
                ? 'Closed'
                : 'Live');
        break;
      case 'Interest Ratio':
        dataModel = PortfolioDataModel(
            date: DateFormat('MMM yyyy').format(
                DateTime.parse(interestTableData[index].startDate ?? '')),
            amount: interestTableData[index].investmentAmount.commaAddedValue(),
            xirr: '${interestTableData[index].xirr?.toStringAsFixed(2)}%',
            status: interestTableData[index].status == 'Active - Good Standing'
                ? 'Live'
                : 'Closed');
        break;
      case 'Delinquency':
        dataModel = PortfolioDataModel(
            date: DateFormat('MMM yyyy').format(
                DateTime.parse(delinquencyTableData[index].startDate ?? '')),
            amount:
                delinquencyTableData[index].investmentAmount.commaAddedValue(),
            xirr: '${delinquencyTableData[index].xirr?.toStringAsFixed(2)}%',
            status:
                delinquencyTableData[index].status == 'Active - Good Standing'
                    ? 'Live'
                    : 'Closed');
        break;
      case 'Loan Tenure':
        dataModel = PortfolioDataModel(
            date: DateFormat('MMM yyyy').format(
                DateTime.parse(loanTenureTableData[index].startDate ?? '')),
            amount: loanTenureTableData[index].amount.commaAddedValue(),
            xirr: '${loanTenureTableData[index].xirr?.toStringAsFixed(2)}%',
            status:
                loanTenureTableData[index].status == 'Active - Good Standing'
                    ? 'Live'
                    : 'Closed');
        break;
      case 'Remaining Tenure':
        dataModel = PortfolioDataModel(
            date: DateFormat('MMM yyyy').format(DateTime.parse(
                remainingLoanTenureTableData[index].startDate ?? '')),
            amount:
                remainingLoanTenureTableData[index].amount.commaAddedValue(),
            xirr:
                '${remainingLoanTenureTableData[index].xirr?.toStringAsFixed(2)}%',
            status: remainingLoanTenureTableData[index].status ==
                    'Active - Good Standing'
                ? 'Live'
                : 'Closed');
        break;
      default:
        dataLength = 0;
        break;
    }
    return dataModel;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    // context.read<AppStateProvider>().context = context;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  widget.viewTitle,
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
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      children: [
                                        mainWidgets(context),
                                      ],
                                    ),
                                  )

                                  // mainWidgets(context),
                                ],
                              ),
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
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Center(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      // color: ColorsUtil.redColor,
                                      width: screenSize.width * .4,
                                      constraints:
                                          BoxConstraints(maxWidth: 500),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [mainWidgets(context)],
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

  Container mainWidgets(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Card(
            child: Container(
              height: widget.viewTitle == 'Interest Ratio'
                  ? 450
                  : widget.viewTitle == 'Delinquency'
                      ? 520
                      : 470,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Center(
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
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          pieChartNoOfLoansData == null
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
                                  total:
                                      pieChartNoOfLoansData.total?.toInt() ?? 0,
                                  chartData: noOfLoansChartData,
                                  paletteList: paletteList,
                                ),
                          pieChartAmountsData == null
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
                                  total:
                                      pieChartAmountsData.total?.toInt() ?? 0,
                                  showAmountSymbol: true,
                                  chartData: amountChartData,
                                  paletteList: paletteList,
                                ),
                        ],
                        controller: _tabController,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 40,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: tabList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedTab = tabList[index];
                          // Casing for Date Model filter on Click of Tab
                          switch (widget.viewTitle) {
                            case 'Risk':
                              if (selectedTab == 'Conseravtive') {
                                riskTableData = portfolioRiskResponse?.data
                                        ?.risk?.conservative?.investOrderList ??
                                    [];
                              } else if (selectedTab == 'Moderate') {
                                riskTableData = portfolioRiskResponse
                                        ?.data?.risk?.medium?.investOrderList ??
                                    [];
                              } else {
                                riskTableData = portfolioRiskResponse
                                        ?.data?.risk?.high?.investOrderList ??
                                    [];
                              }
                              break;
                            case 'Interest Ratio':
                              interestTableData = portfolioRiskResponse
                                      ?.data?.interestRateList
                                      ?.where((element) =>
                                          element.interestRateonLoanRange ==
                                          selectedTab)
                                      .toSet()
                                      .toList() ??
                                  [];
                              break;
                            case 'Delinquency':
                              delinquencyTableData = portfolioRiskResponse
                                      ?.data?.delinquencyList
                                      ?.where((element) =>
                                          element.deliquentRange == selectedTab)
                                      .toSet()
                                      .toList() ??
                                  [];
                              break;
                            case 'Loan Tenure':
                              loanTenureTableData = portfolioRiskResponse
                                      ?.data?.tenureData
                                      ?.where((element) =>
                                          element.termCategory == selectedTab)
                                      .toSet()
                                      .toList() ??
                                  [];
                              break;
                            case 'Remaining Tenure':
                              remainingLoanTenureTableData =
                                  portfolioRiskResponse
                                          ?.data?.remainingTenureData
                                          ?.where((element) =>
                                              element.termCategory ==
                                              selectedTab)
                                          .toSet()
                                          .toList() ??
                                      [];
                              break;
                            default:
                              break;
                          }
                          getPortfolioDataLength();
                        });
                      },
                      child: tabWidget(context, tabList[index]),
                    ),
                  );
                }),
          ),
          // widget.viewTitle == 'Risk'
          //     ? Wrap(
          //         children: [
          //           InkWell(
          //             onTap: () {
          //               setState(() {
          //                 selectedTab = 'Conseravtive';
          //                 finalTableData = portfolioRiskResponse
          //                         ?.data?.risk?.conservative?.investOrderList ??
          //                     [];
          //               });
          //             },
          //             child: tabWidget(context, 'Conseravtive'),
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //             onTap: () {
          //               setState(() {
          //                 selectedTab = 'Moderate';
          //                 finalTableData = portfolioRiskResponse
          //                         ?.data?.risk?.medium?.investOrderList ??
          //                     [];
          //               });
          //             },
          //             child: tabWidget(context, 'Moderate'),
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //               onTap: () {
          //                 setState(() {
          //                   selectedTab = 'High';
          //                   finalTableData = portfolioRiskResponse
          //                           ?.data?.risk?.high?.investOrderList ??
          //                       [];
          //                 });
          //               },
          //               child: tabWidget(context, 'High'))
          //         ],
          //       )
          //     : Wrap(
          //         alignment: WrapAlignment.center,
          //         runSpacing: 10,
          //         children: [
          //           InkWell(
          //             onTap: () {
          //               setState(() {
          //                 selectedTab = '24 Month';
          //                 finalTableData = portfolioRiskResponse
          //                         ?.data?.risk?.conservative?.investOrderList ??
          //                     [];
          //               });
          //             },
          //             child: tabWidget(context, '24 Month'),
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //             onTap: () {
          //               setState(() {
          //                 selectedTab = '12-24 Month';
          //                 finalTableData = portfolioRiskResponse
          //                         ?.data?.risk?.medium?.investOrderList ??
          //                     [];
          //               });
          //             },
          //             child: tabWidget(context, '12-24 Month'),
          //           ),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //               onTap: () {
          //                 setState(() {
          //                   selectedTab = '6-12 Month';
          //                   finalTableData = portfolioRiskResponse
          //                           ?.data?.risk?.high?.investOrderList ??
          //                       [];
          //                 });
          //               },
          //               child: tabWidget(context, '6-12 Month')),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //               onTap: () {
          //                 setState(() {
          //                   selectedTab = '3-6 Month';
          //                   finalTableData = portfolioRiskResponse
          //                           ?.data?.risk?.high?.investOrderList ??
          //                       [];
          //                 });
          //               },
          //               child: tabWidget(context, '3-6 Month')),
          //           SizedBox(
          //             width: 10,
          //           ),
          //           InkWell(
          //               onTap: () {
          //                 setState(() {
          //                   selectedTab = '<3 Month';
          //                   finalTableData = portfolioRiskResponse
          //                           ?.data?.risk?.high?.investOrderList ??
          //                       [];
          //                 });
          //               },
          //               child: tabWidget(context, '<3 Month'))
          //         ],
          //       ),
          SizedBox(
            height: 20,
          ),
          Card(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Container(
                    child: Scrollbar(
                      controller: _horizontalscrollController,
                      isAlwaysShown:
                          Utils.isWeb && dataLength != 0 ? true : false,
                      child: SingleChildScrollView(
                        controller: _horizontalscrollController,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowHeight: 42,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Container(
                                child: Text(
                                  'Month/year',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: CustomFonts.nunito,
                                    color: ColorsUtil.viewDetailTableColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                width: 140,
                                child: Row(
                                  children: [
                                    Text(
                                      'Your Investment',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: CustomFonts.nunito,
                                        color: ColorsUtil.viewDetailTableColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      'Your XIRR',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: CustomFonts.nunito,
                                        color: ColorsUtil.viewDetailTableColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Container(
                                width: 100,
                                child: Text(
                                  'Loan Status',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: CustomFonts.nunito,
                                    color: ColorsUtil.viewDetailTableColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            // casing for count
                            dataLength,
                            (int index) => DataRow(
                              cells: <DataCell>[
                                DataCell(Container(
                                  width: 130,
                                  child: Text(
                                    // Casing for Date
                                    "${getPortfolioRowValue(index)?.date}",
                                    // dataModel?.date ?? '',

                                    // DateFormat('MMM yyyy').format(
                                    //     DateTime.parse(riskTableData[index]
                                    //             .loanInvestorStartDateC ??
                                    //         '')),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: CustomFonts.nunito,
                                      color:
                                          ColorsUtil.viewDetailTableTextColor,
                                    ),
                                  ),
                                )),
                                DataCell(
                                  Container(
                                    width: 140,
                                    child: Text(
                                      // Casing for Date
                                      // riskTableData[index]
                                      //     .loanInvestmentAmountC
                                      //     .commaAddedValue(),
                                      "${getPortfolioRowValue(index)?.amount}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: CustomFonts.nunito,
                                        color:
                                            ColorsUtil.viewDetailTableTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 100,
                                    child: Text(
                                      // Casing for Date
                                      // '${riskTableData[index].loanLoanR?.slxirrc?.toStringAsFixed(2)}%',
                                      "${getPortfolioRowValue(index)?.xirr}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: CustomFonts.nunito,
                                        color:
                                            ColorsUtil.viewDetailTableTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 100,
                                    child: Text(
                                      // Casing for Date
                                      // riskTableData[index].loanStatusC ==
                                      //         'Inactive'
                                      //     ? 'Closed'
                                      //     : 'Live',
                                      "${getPortfolioRowValue(index)?.status}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: CustomFonts.nunito,
                                        color:
                                            ColorsUtil.viewDetailTableTextColor,
                                      ),
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

                  // Casing for No Data View

                  dataLength == 0
                      ? Text(
                          'No Data Available',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.viewDetailTableTextColor,
                          ),
                        )
                      : Container(),
                  dataLength == 0
                      ? Container()
                      : CustomButton(
                          leftIcon: Image(
                            image: AssetImage(LocalImages.downloadPdf),
                            width: 20,
                            // height: 170,
                          ),
                          //   borderColor: ColorsUtil.greenColor,
                          titleStr: 'Download File',
                          bgColor: ColorsUtil.blueColor,
                          textColor: ColorsUtil.white,
                          onPress: () {
                            switch (widget.viewTitle) {
                              case 'Risk':
                                makePdf(
                                    riskTableData,
                                    context.read<AppStateProvider>().customerId,
                                    context
                                            .read<AppStateProvider>()
                                            .userDetails
                                            ?.panDetails
                                            ?.fullName ??
                                        '',
                                    widget.viewTitle);

                                break;
                              case 'Interest Ratio':
                                makePdf(
                                    interestTableData,
                                    context.read<AppStateProvider>().customerId,
                                    context
                                            .read<AppStateProvider>()
                                            .userDetails
                                            ?.panDetails
                                            ?.fullName ??
                                        '',
                                    widget.viewTitle);

                                break;
                              case 'Delinquency':
                                makePdf(
                                    delinquencyTableData,
                                    context.read<AppStateProvider>().customerId,
                                    context
                                            .read<AppStateProvider>()
                                            .userDetails
                                            ?.panDetails
                                            ?.fullName ??
                                        '',
                                    widget.viewTitle);

                                break;
                              case 'Loan Tenure':
                                makePdf(
                                    loanTenureTableData,
                                    context.read<AppStateProvider>().customerId,
                                    context
                                            .read<AppStateProvider>()
                                            .userDetails
                                            ?.panDetails
                                            ?.fullName ??
                                        '',
                                    widget.viewTitle);

                                break;
                              case 'Remaining Tenure':
                                makePdf(
                                    remainingLoanTenureTableData,
                                    context.read<AppStateProvider>().customerId,
                                    context
                                            .read<AppStateProvider>()
                                            .userDetails
                                            ?.panDetails
                                            ?.fullName ??
                                        '',
                                    widget.viewTitle);

                                break;
                              default:
                                break;
                            }
                            // makePdf(
                            //     riskTableData,
                            //     context.read<AppStateProvider>().customerId,
                            //     context
                            //             .read<AppStateProvider>()
                            //             .userDetails
                            //             ?.panDetails
                            //             ?.fullName ??
                            //         '',
                            //     widget.viewTitle);
                          },
                        ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget tabWidget(context, name) {
    return Container(
      height: 40,
      constraints: BoxConstraints(minWidth: 100),
      // width: 120,
      decoration: BoxDecoration(
        color: selectedTab == name
            ? ColorsUtil.viewDetailTabColor.withOpacity(.1)
            : ColorsUtil.greyTabColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
            width: 1.5,
            color: selectedTab == name
                ? ColorsUtil.viewDetailTabColor
                : ColorsUtil.greyTabColor),
      ),
      // padding: EdgeInsets.all(8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: CustomFonts.nunito,
                fontSize: 14,
                color: selectedTab == name
                    ? ColorsUtil.viewDetailTabColor
                    : ColorsUtil.greyTabColor),
          ),
        ),
      ),
    );
  }
}

// class TabsWidget extends StatefulWidget {
//   TabsWidget({required this.text, required this.onTap});
//   String text;
//   Function onTap;
//
//
//   @override
//   State<TabsWidget> createState() => _TabsWidgetState();
// }
//
// class _TabsWidgetState extends State<TabsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         widget.onTap;
//       },
//       child: Container(
//         height: 40,
//         decoration: BoxDecoration(
//           color: ColorsUtil.greyTabColor.withOpacity(.1),
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(width: 1.5, color: ColorsUtil.greyTabColor),
//         ),
//         padding: EdgeInsets.all(8),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Text(
//               widget.text,
//               style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontFamily: CustomFonts.nunito,
//                   fontSize: 14,
//                   color: ColorsUtil.greyTabColor),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class PortfolioDataModel {
  String date;
  String amount;
  String xirr;
  String status;

  PortfolioDataModel({
    required this.date,
    required this.amount,
    required this.xirr,
    required this.status,
  });
}
