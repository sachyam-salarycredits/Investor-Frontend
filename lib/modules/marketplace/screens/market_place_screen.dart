import 'dart:async';

import 'package:peerbridge/modules/marketplace/models/filter_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/loan_cart_button.dart';
import 'package:peerbridge/modules/marketplace/widgets/no_data_widget.dart';
import 'package:peerbridge/modules/marketplace/widgets/secondary_loan_details_dialog.dart';
import 'package:peerbridge/modules/marketplace/widgets/secondary_market_card.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/supporting_file/web_utils.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/modules/marketplace/widgets/loan_cart_popup.dart';
import 'package:peerbridge/modules/marketplace/widgets/market_place_grid_cards.dart';
import 'package:peerbridge/modules/marketplace/widgets/marketplace_filter.dart';
import 'package:peerbridge/modules/marketplace/widgets/view_detail.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/shimmer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({
    Key? key,
  }) : super(key: key);

  @override
  _MarketPlaceState createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  bool isHide = true;
  bool isFilter = false;
  bool isClose = false;
  bool isLoader = false;
  bool initialExpanded = true;
  ScrollController scrollController = ScrollController();
  bool isFirstCall = true;
  bool isFirstTab = true;
  // Timer? timer;

  @override
  void initState() {
    getFundsDetails();
    super.initState();

    scrollController.addListener(scrollEndNotifier);
    // timer =
    //     Timer.periodic(Duration(seconds: 30), (Timer t) => reloadAmountData());

    Future.delayed(Duration(seconds: 10)).then((value) {
      setState(() {
        isHide = false;
        initialExpanded = false;
      });
    });

    // context.read<AppStateProvider>().getFlyyWebToken();
  }

  void reloadAmountData() {
    context.read<AppStateProvider>().getUserFundDetails();
  }

  void scrollEndNotifier() async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !isFilter &&
        isFirstCall) {
      isFirstCall = false;
      await context.read<AppStateProvider>().getNextMarketPlaceData();
      setState(() {
        isFirstCall = true;
      });
    }
  }

  /// Get user funds details
  Future<void> getFundsDetails() async {
    setLoader(true);
    context.read<AppStateProvider>().getCustomerDetails();
    // context.read<AppStateProvider>().getStepsStatus();

    await context.read<AppStateProvider>().getMarketPlaceData();
    // context.read<AppStateProvider>().getStatement();

    await context.read<AppStateProvider>().getUserFundDetails();
    setLoader(false);
  }

  void setLoader(loader) {
    setState(() {
      isLoader = loader;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _crossAxisCount = ResponsiveWidget.isLargeScreen(context)
        ? 3
        : ResponsiveWidget.isMediumScreen(context)
            ? 2
            : 1;
    var _aspectRatio = ResponsiveWidget.isLargeScreen(context)
        ? 3 / 2
        : ResponsiveWidget.isMediumScreen(context)
            ? 3 / 2
            : 2 / 1;
    var _secondaryRatio = ResponsiveWidget.isLargeScreen(context)
        ? 0.9
        : ResponsiveWidget.isMediumScreen(context)
            ? 1 / 1.07
            : 1 / 1.20;
    var _axisSpacing = ResponsiveWidget.isLargeScreen(context)
        ? 12.0
        : ResponsiveWidget.isMediumScreen(context)
            ? 8.0
            : 4.0;

    final screenPadding = ResponsiveWidget.isLargeScreen(context)
        ? 40.0
        : ResponsiveWidget.isMediumScreen(context)
            ? 20.0
            : 8.0;

    // final provider = Provider.of<AppStateProvider>(context);

    return Consumer<AppStateProvider>(builder: (context, provider, child) {
      final isPrimaryMarket = provider.isPrimaryMarketSelected;
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: ColorsUtil.circleGrey,
          floatingActionButton: getFloatingWidget(),
          body: PeerBridgeLoader(
            isLoading: isLoader || provider.isMarketPlaceLoading.value,
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  provider.filterData = FilterDetails();
                  provider.getUserFundDetails();
                  // provider.getStepsStatus();
                  // provider.getCustomerDetails();
                  provider.getStatement();
                  await provider.getMarketPlaceData(isFilter: true);
                  return;
                },
                child: Column(
                  children: [
                    Header(
                      isBackBtnVisible: true,
                      isReload: false,
                      isMenuVisible: true,
                      backOnPressedMarket: () {
                        context.pop();
                      },
                      backOnPressed: () async {
                        // debugPrint('reload taped');
                        // provider.filterData = FilterDetails();
                        // provider.getUserFundDetails();
                        // provider.getStepsStatus();
                        // provider.getCustomerDetails();
                        // provider.getStatement();
                        // await provider.getMarketPlaceData(isFilter: true);
                        // return;
                        context.pop();
                      },
                    ),
                    Visibility(
                      visible: isHide,
                      child: Card(
                        elevation: 2,
                        shadowColor: ColorsUtil.lighterGrey,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenPadding, vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection:
                                ResponsiveWidget.isMediumScreen(context)
                                    ? Axis.horizontal
                                    : Axis.vertical,
                            child: ResponsiveWidget.isLargeScreen(context) ||
                                    ResponsiveWidget.isMediumScreen(context)
                                ? WebViewDetailWidget()
                                : MobileViewDetailWidget(
                                    isExpended: initialExpanded,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          isHide = !isHide;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(0),
                        width: isHide ? 79 : 120,
                        child: Card(
                          elevation: 2,
                          shadowColor: ColorsUtil.lighterGrey,
                          margin: EdgeInsets.all(0),
                          // margin: isHide == true
                          //     ? EdgeInsets.symmetric(horizontal: 160)
                          //     : EdgeInsets.symmetric(horizontal: 140),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SizedBox(
                                //   width: 10.0,
                                // ),
                                isHide == true
                                    ? Text(
                                        'Hide',
                                        maxLines: 1,
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: CustomFonts.nunito,
                                            color: ColorsUtil.dividerColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                      )
                                    : Text(
                                        'View overview',
                                        maxLines: 1,
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsUtil.dividerColor,
                                            fontSize: 12),
                                      ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                isHide == true
                                    ? Icon(
                                        Icons.keyboard_arrow_up,
                                        size: 15,
                                        color: ColorsUtil.dividerColor,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 15,
                                        color: ColorsUtil.dividerColor,
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenPadding, vertical: 8),
                      child: Column(children: [
                        Row(
                          children: [
                            //primary secondary tab
                            Container(
                              decoration: BoxDecoration(
                                  color: ColorsUtil.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                      color: ColorsUtil.lighterGrey)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Row(
                                children: [
                                  getSelectableContainer(
                                      "Primary Market", isPrimaryMarket,
                                      onTap: () async {
                                    provider.isPrimaryMarketSelected = true;
                                    setState(() {
                                      isFirstTab = true;
                                    });
                                    if (provider.primaryMarketLoans == null) {
                                      setLoader(true);
                                      await provider.getMarketPlaceData();
                                      setLoader(false);
                                    }
                                  }),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  getSelectableContainer(
                                      "Secondary Market", !isPrimaryMarket,
                                      onTap: () async {
                                    provider.isPrimaryMarketSelected = false;
                                    setState(() {
                                      isFirstTab = true;
                                    });
                                    if (provider.secondaryMarketLoans == null) {
                                      setLoader(true);
                                      await provider.getMarketPlaceData();
                                      setLoader(false);
                                    }
                                  }),
                                ],
                              ),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isFilter = !isFilter;
                                });
                              },
                              child: Container(
                                // width: MediaQuery.of(context).size.width / 7,
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                decoration: BoxDecoration(
                                    color: ColorsUtil.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: isFilter
                                          ? ColorsUtil.greenText
                                          : ColorsUtil.lighterGrey,
                                    )),
                                child: Center(
                                    child: ResponsiveWidget.isLargeScreen(
                                                context) ||
                                            ResponsiveWidget.isMediumScreen(
                                                context)
                                        ? Row(
                                            children: [
                                              Text(
                                                'Filter options ${provider.filterData.getFilterCountStr()}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              Icon(Icons.arrow_drop_down)
                                            ],
                                          )
                                        : Stack(
                                            children: [
                                              Icon(
                                                Icons.filter_list_outlined,
                                                color: ColorsUtil.blackish,
                                              ),
                                              Visibility(
                                                visible: provider.filterData
                                                        .getFilterCount() >
                                                    0,
                                                child: Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: ColorsUtil.green),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                              ),
                            )
                          ],
                        ),
                        ResponsiveWidget.isLargeScreen(context) ||
                                ResponsiveWidget.isMediumScreen(context)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: ColorsUtil.lighterGrey,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ]),
                    ),
                    Expanded(
                      child: AnimatedCrossFade(
                        crossFadeState: isFilter
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 700),
                        secondChild: ListView(
                          shrinkWrap: true,
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenPadding, vertical: 0),
                          children: [
                            Builder(builder: (context) {
                              var marketPlaceList = isPrimaryMarket
                                  ? provider.primaryMarketLoans ?? []
                                  : provider.secondaryMarketLoans ?? [];

                              if (marketPlaceList.length == 0 &&
                                  !provider.isMarketPlaceLoading.value) {
                                return Center(
                                  child: MarketNoDataWidget(
                                    isFilter: !provider.isFilterClear(),
                                  ),
                                );
                              }

                              if (marketPlaceList.length == 0) {
                                return Center(
                                  child: SizedBox(),
                                );
                              }

                              return Container(
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: !isClose,
                                      child: Card(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        color: ColorsUtil.blueContainerColor,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${provider.overViewDetail.numberOfLoan.commaAddedValue()} loans worth for ₹' +
                                                    '${provider.overViewDetail.totalLoanAmount.commaAddedValue()}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: ColorsUtil.greenText,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isClose = true;
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.close,
                                                  color: ColorsUtil.greenText,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 60.0),
                                      child: GridView.builder(
                                          shrinkWrap: true,
                                          itemCount: marketPlaceList.length,
                                          physics: NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: _crossAxisCount,
                                            crossAxisSpacing: _axisSpacing,
                                            mainAxisSpacing: _axisSpacing,
                                            childAspectRatio: isPrimaryMarket
                                                ? _aspectRatio
                                                : _secondaryRatio,
                                          ),
                                          itemBuilder: (context, index) {
                                            return Card(
                                              margin: const EdgeInsets.symmetric(
                                                  vertical: 3, horizontal: 0),
                                              semanticContainer: true,
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              elevation: 1,
                                              child: Hero(
                                                  tag: "$index",
                                                  child: getCardWidget(index)),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                // child: ListView.builder(
                                //     physics: NeverScrollableScrollPhysics(),
                                //     shrinkWrap: true,
                                //     itemBuilder: (context, index) {
                                //       return Card(
                                //           margin: const EdgeInsets.symmetric(
                                //               vertical: 3, horizontal: 0),
                                //           semanticContainer: true,
                                //           clipBehavior: Clip.antiAliasWithSaveLayer,
                                //           shape: RoundedRectangleBorder(
                                //             borderRadius: BorderRadius.circular(5.0),
                                //           ),
                                //           elevation: 1,
                                //           child: MarketPlaceCard());
                                //     }),
                              );
                            }),
                            ValueListenableBuilder<bool>(
                              valueListenable: provider.isMarketPlaceLoading,
                              builder: (_, loading, __) {
                                if (loading &&
                                    provider.filterData.pageNo != 0) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      CupertinoActivityIndicator(),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text("Please wait"),
                                      SizedBox(
                                        height: 4,
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            )
                          ],
                        ),
                        firstChild: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenPadding, vertical: 0),
                          children: [
                            MarketPlaceFilter(
                              key: UniqueKey(),
                              onClose: () async {
                                isFilter = !isFilter;
                                setLoader(true);
                                await provider.getMarketPlaceData(
                                    isFilter: true);
                                setLoader(false);
                              },
                            ),
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
      );
    });
  }

  Widget? getFloatingWidget() {
    final provider = Provider.of<AppStateProvider>(context);
    final primaryCartList = provider.primaryCartList;
    final secondaryCartList = provider.secondaryCartList;
    if (provider.isPrimaryMarketSelected) {
      return LoanCartButton(
        key: provider.loanButtonState,
        onUpdate: () {
          setState(() {});
        },
        refreshData: () async {
          setLoader(true);
          provider.filterData = FilterDetails();
          provider.getUserFundDetails();
          provider.getStepsStatus();
          provider.getCustomerDetails();
          provider.getStatement();
          await provider.getMarketPlaceData(isFilter: true);
          setLoader(false);
          // setState(() {});
        },
      );
    } else {
      return LoanCartButton(
        key: provider.loanButtonState,
        onUpdate: () {
          setState(() {});
        },
        refreshData: () async {
          setLoader(true);
          provider.filterData = FilterDetails();
          provider.getUserFundDetails();
          provider.getStepsStatus();
          provider.getCustomerDetails();
          provider.getStatement();
          await provider.getMarketPlaceData(isFilter: true);
          setLoader(false);
          // setState(() {});
        },
      );
    }
  }

  Widget getSelectableContainer(String title, bool selected,
      {void Function()? onTap}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: selected ? ColorsUtil.blackish : ColorsUtil.circleGrey,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: CustomFonts.nunito,
              color: selected ? ColorsUtil.white : ColorsUtil.blackish,
            ),
          ),
        ),
      ),
    );
  }

  Widget getCardWidget(index) {
    if (context.read<AppStateProvider>().isPrimaryMarketSelected) {
      return ResponsiveWidget.isLargeScreen(context) ||
              ResponsiveWidget.isMediumScreen(context)
          ? WebMarketPlaceCard(
              index: index,
              onUpdate: () {
                setState(() {});
              },
            )
          : MarketPlaceCard(
              index: index,
              onUpdate: () {
                setState(() {});
              },
            );
    } else {
      return SecondaryMarketPlaceCard(
        index: index,
        onUpdate: () {
          setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollEndNotifier);
    //  timer?.cancel();
    super.dispose();
  }
}
