import 'dart:async';

import 'package:Monexo/modules/marketplace/models/filter_data.dart';
import 'package:Monexo/modules/marketplace/widgets/loan_cart_button.dart';
import 'package:Monexo/modules/marketplace/widgets/no_data_widget.dart';
import 'package:Monexo/modules/marketplace/widgets/secondary_loan_details_dialog.dart';
import 'package:Monexo/modules/marketplace/widgets/secondary_market_card.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/supporting_file/web_utils.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/modules/marketplace/widgets/loan_cart_popup.dart';
import 'package:Monexo/modules/marketplace/widgets/market_place_grid_cards.dart';
import 'package:Monexo/modules/marketplace/widgets/marketplace_filter.dart';
import 'package:Monexo/modules/marketplace/widgets/view_detail.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/shimmer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../routes_management/routes_list.dart';
import '../../../utils/images.dart';
import '../../../widgets/custom_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class NewMarketPlace extends StatefulWidget {
  bool showSocialImpactLoans;
  NewMarketPlace({
    Key? key,
    this.showSocialImpactLoans = false,
  }) : super(key: key);

  @override
  _NewMarketPlaceState createState() => _NewMarketPlaceState();
}

class _NewMarketPlaceState extends State<NewMarketPlace> {
  bool isHide = true;
  bool isFilter = false;
  bool isClose = false;
  bool isLoader = false;
  bool initialExpanded = true;
  ScrollController scrollController = ScrollController();
  bool isFirstCall = true;
  bool isFirstTab = true;
  // Timer? timer;
  List<String> marketList = ['Primary Market', 'Secondary Market'];
  List<String> riskList = [
    'Show All',
    'Conservative',
    'Moderate',
    'High',
    'Social Impact Loan'
  ];
  String? selectedMarket = 'Primary Market';
  String? selectedRisk = 'Show All';

  @override
  void initState() {
    // getFundsDetails();
    super.initState();
    scrollController.addListener(scrollEndNotifier);
    // timer =
    //     Timer.periodic(Duration(seconds: 30), (Timer t) => reloadAmountData());
    getFundDetails();
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    provider.filterData = FilterDetails();
    getFundsDetails();

    // Future.delayed(Duration(seconds: 10)).then((value) {
    //   setState(() {
    //     isHide = false;
    //     initialExpanded = false;
    //   });
    // });

    // context.read<AppStateProvider>().getFlyyWebToken();
  }

  bool loadingAmount = false;
  void loadMarkets(String? selectedMarket, bool isFilter) async {
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    print('here${provider.isPrimaryMarketSelected}');
    provider.filterData = FilterDetails();
    if (isFilter) {
      provider.filterData = FilterDetails();
      print('filter===');
      if (selectedRisk == 'Show All') {
        print('selectedRisk1$selectedRisk');
        provider.filterData = FilterDetails();
        print(provider.filterData);
      } else if (selectedRisk == 'Social Impact Loan') {
        print('selectedRisk2$selectedRisk');
        provider.filterData.grade = [];
        provider.filterData.products = [selectedRisk ?? ''];
        print(provider.filterData.products);
      } else {
        print('selectedRisk3$selectedRisk');
        provider.filterData.products = [];
        provider.filterData.grade = [selectedRisk ?? ''];
        print(provider.filterData.grade);

        // provider.filterData =
        //     FilterDetails(grade: [
        //   selectedRisk ?? ''
        // ]);
      }
    }
    print('else');
    if (selectedMarket == marketList[1]) {
      provider.isPrimaryMarketSelected = false;
      setLoader(true);

      isFilter
          ? await provider.getMarketPlaceData(isFilter: true)
          : await provider.getMarketPlaceData();
      setLoader(false);

      // if (provider.secondaryMarketLoans == null) {
      //   setLoader(true);
      //   print('herejijijijuhuh');
      //   isFilter
      //       ? await provider.getMarketPlaceData(isFilter: true)
      //       : await provider.getMarketPlaceData();
      //   setLoader(false);
      // }
    } else {
      print('hellloooo');
      provider.isPrimaryMarketSelected = true;
      setLoader(true);

      isFilter
          ? await provider.getMarketPlaceData(isFilter: true)
          : await provider.getMarketPlaceData();
      setLoader(false);
      // if (provider.primaryMarketLoans == null) {
      //   setLoader(true);
      //   print('hellloooojijij');
      //   isFilter
      //       ? await provider.getMarketPlaceData(isFilter: true)
      //       : await provider.getMarketPlaceData();
      //   setLoader(false);
      // }
    }
  }

  void getFundDetails() async {
    setState(() {
      loadingAmount = true;
    });
    await context.read<AppStateProvider>().getUserFundDetails();
    setState(() {
      loadingAmount = false;
    });
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
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    setLoader(true);
    context.read<AppStateProvider>().getCustomerDetails();
    // context.read<AppStateProvider>().getStepsStatus();

    if (Utils.showSocialImpactLoans) {
      selectedRisk = 'Social Impact Loan';
      Utils.showSocialImpactLoans = false;
      provider.filterData.grade = [];
      provider.filterData.products = [selectedRisk ?? ''];

      await context.read<AppStateProvider>().getMarketPlaceData(isFilter: true);
    } else {
      await context.read<AppStateProvider>().getMarketPlaceData();
    }
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
          backgroundColor: ColorsUtil.white,
          floatingActionButton: getFloatingWidget(),
          appBar: ResponsiveWidget.isSmallScreen(context)
              ? AppBar(
                  title: Text(
                    'Marketplace',
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
                      provider.filterData = FilterDetails();
                      context.pop();
                    },
                  ),
                )
              : null,
          body: MonexoLoader(
            isLoading: isLoader || provider.isMarketPlaceLoading.value,
            child: SafeArea(
              child: Column(
                children: [
                  Utils.isWeb
                      ? Header(
                          isBackBtnVisible: true,
                          isReload: false,
                          isMenuVisible: true,
                          backOnPressedMarket: () {
                            provider.filterData = FilterDetails();
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
                            provider.filterData = FilterDetails();
                            context.pop();
                          },
                        )
                      : Container(),
                  Visibility(
                    visible: isHide,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: screenPadding,
                              top: 8,
                              right: screenPadding),
                          child: Card(
                            color: Utils.availableAmount == 0.0
                                ? ColorsUtil.redhomeCardColor
                                : ColorsUtil.marketCardContainer,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text('Balance Available To Invest',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        loadingAmount
                                            ? CircularProgressIndicator(
                                                backgroundColor:
                                                    ColorsUtil.blueColor,
                                                strokeWidth: 2.0,
                                              )
                                            : Text(
                                                Utils.availableAmount == 0.0
                                                    ? '₹  Nil'
                                                    : '₹  ${Utils.availableAmount.truncate().commaAddedValue()}',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                        Container(
                                            height: 40,
                                            width: 120,
                                            margin: EdgeInsets.all(8),
                                            child: CustomButton(
                                              textSize: 14,
                                              horizontalMargin: 0,
                                              titleStr: 'Add Money',
                                              onPress: () {
                                                context.pushNamed(RoutesName
                                                    .NewFundTransferScreen);
                                              },
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenPadding, vertical: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  color: ColorsUtil.marketCardContainer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${provider.overViewDetail.numberOfLoan.commaAddedValue()} loans worth for ' +
                                              '${provider.overViewDetail.totalLoanAmount.commaAddedValue()} INR',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: ColorsUtil.greyColorText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontFamily: CustomFonts.nunito,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            // provider.filterData =
                                            //     FilterDetails();
                                            provider.getUserFundDetails();
                                            // provider.getStepsStatus();
                                            // provider.getCustomerDetails();
                                            provider.getStatement();
                                            await provider.getMarketPlaceData(
                                                isFilter: true);
                                            return;
                                          },
                                          child: Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              LocalImages.refresh_blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Filter Investments Opportunitires',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorsUtil.blueColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: CustomFonts.nunito,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    //primary secondary tab
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Markets',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: ColorsUtil.blueColor,
                                                fontFamily: CustomFonts.nunito,
                                              ),
                                            ),
                                            Container(
                                              height: 30.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                color: ColorsUtil.circleGrey,
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton2(
                                                  buttonPadding:
                                                      EdgeInsetsDirectional
                                                          .zero,
                                                  itemPadding:
                                                      EdgeInsetsDirectional
                                                          .only(start: 5),
                                                  isExpanded: false,
                                                  value: selectedMarket,
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 3.0),
                                                    child: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: ColorsUtil
                                                          .greyPlaceHolder,
                                                    ),
                                                  ),
                                                  iconSize: 20,
                                                  // elevation: 16,
                                                  style: const TextStyle(
                                                    color: ColorsUtil.black,
                                                  ),
                                                  underline: Container(
                                                    height: 2,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  onChanged: (String? cause) {
                                                    loadMarkets(cause, false);
                                                    setState(() {
                                                      selectedMarket = cause;
                                                      selectedRisk = 'Show All';
                                                    });
                                                  },
                                                  hint: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15.0),
                                                      child: Text(
                                                        marketList[0],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                CustomFonts
                                                                    .nunito,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color: ColorsUtil
                                                                .greyDisable),
                                                      ),
                                                    ),
                                                  ),
                                                  items: marketList.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String? cause) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: cause,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          cause ?? '',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14.0,
                                                              color: ColorsUtil
                                                                  .greyDisable),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ), //primary secondary tab
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Risk & Returns',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                                color: ColorsUtil.blueColor,
                                                fontFamily: CustomFonts.nunito,
                                              ),
                                            ),
                                            Container(
                                              height: 30.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5),
                                                ),
                                                color: ColorsUtil.circleGrey,
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton2(
                                                  buttonPadding:
                                                      EdgeInsetsDirectional
                                                          .zero,
                                                  itemPadding:
                                                      EdgeInsetsDirectional
                                                          .only(start: 5),

                                                  isExpanded: false,
                                                  value: selectedRisk,
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 3.0),
                                                    child: Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: ColorsUtil
                                                          .greyPlaceHolder,
                                                    ),
                                                  ),
                                                  iconSize: 20,
                                                  // elevation: 16,
                                                  style: const TextStyle(
                                                    color: ColorsUtil.black,
                                                  ),
                                                  underline: Container(
                                                    height: 2,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  onChanged:
                                                      (String? cause) async {
                                                    setState(() {
                                                      selectedRisk = cause;
                                                      loadMarkets(
                                                          selectedMarket, true);
                                                      // if (selectedRisk == '') {
                                                      //   provider.filterData =
                                                      //       FilterDetails();
                                                      // } else if (selectedRisk ==
                                                      //     'Social Impact Loan') {
                                                      //   provider.filterData.products =
                                                      //       [selectedRisk ?? ''];
                                                      // } else {
                                                      //   provider.filterData.grade = [
                                                      //     selectedRisk ?? ''
                                                      //   ];
                                                      //
                                                      //   // provider.filterData =
                                                      //   //     FilterDetails(grade: [
                                                      //   //   selectedRisk ?? ''
                                                      //   // ]);
                                                      // }
                                                    });
                                                  },
                                                  hint: Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15.0),
                                                      child: Text(
                                                        riskList[0],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                CustomFonts
                                                                    .nunito,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color: ColorsUtil
                                                                .greyDisable),
                                                      ),
                                                    ),
                                                  ),
                                                  items: riskList.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String? cause) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: cause,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          cause ?? '',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14.0,
                                                              color: ColorsUtil
                                                                  .greyDisable),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ), //primary secondary tab
                                    //primary secondary tab
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //       color: ColorsUtil.white,
                                    //       borderRadius: BorderRadius.circular(5.0),
                                    //       border: Border.all(
                                    //           color: ColorsUtil.lighterGrey)),
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: 8, vertical: 8),
                                    //   child: Row(
                                    //     children: [
                                    //       getSelectableContainer(
                                    //           "Primary Market", isPrimaryMarket,
                                    //           onTap: () async {
                                    //             provider.isPrimaryMarketSelected = true;
                                    //             setState(() {
                                    //               isFirstTab = true;
                                    //             });
                                    //             if (provider.primaryMarketLoans == null) {
                                    //               setLoader(true);
                                    //               await provider.getMarketPlaceData();
                                    //               setLoader(false);
                                    //             }
                                    //           }),
                                    //       SizedBox(
                                    //         width: 8,
                                    //       ),
                                    //       getSelectableContainer(
                                    //           "Secondary Market", !isPrimaryMarket,
                                    //           onTap: () async {
                                    //             provider.isPrimaryMarketSelected = false;
                                    //             setState(() {
                                    //               isFirstTab = true;
                                    //             });
                                    //             if (provider.secondaryMarketLoans == null) {
                                    //               setLoader(true);
                                    //               await provider.getMarketPlaceData();
                                    //               setLoader(false);
                                    //             }
                                    //           }),
                                    //     ],
                                    //   ),
                                    // ),
                                    // Spacer(),
                                    // InkWell(
                                    //   onTap: () {
                                    //     setState(() {
                                    //       isFilter = !isFilter;
                                    //     });
                                    //   },
                                    //   child: Container(
                                    //     // width: MediaQuery.of(context).size.width / 7,
                                    //     height: 56,
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 15.0, vertical: 10),
                                    //     clipBehavior: Clip.antiAliasWithSaveLayer,
                                    //     decoration: BoxDecoration(
                                    //         color: ColorsUtil.white,
                                    //         borderRadius: BorderRadius.circular(5.0),
                                    //         border: Border.all(
                                    //           color: isFilter
                                    //               ? ColorsUtil.greenText
                                    //               : ColorsUtil.lighterGrey,
                                    //         )),
                                    //     child: Center(
                                    //         child: ResponsiveWidget.isLargeScreen(
                                    //             context) ||
                                    //             ResponsiveWidget.isMediumScreen(
                                    //                 context)
                                    //             ? Row(
                                    //           children: [
                                    //             Text(
                                    //               'Filter options ${provider.filterData.getFilterCountStr()}',
                                    //               textAlign: TextAlign.center,
                                    //               style: TextStyle(
                                    //                   fontSize: 16,
                                    //                   fontFamily:
                                    //                   CustomFonts.nunito,
                                    //                   fontWeight:
                                    //                   FontWeight.w700),
                                    //             ),
                                    //             Icon(Icons.arrow_drop_down)
                                    //           ],
                                    //         )
                                    //             : Stack(
                                    //           children: [
                                    //             Icon(
                                    //               Icons.filter_list_outlined,
                                    //               color: ColorsUtil.blackish,
                                    //             ),
                                    //             Visibility(
                                    //               visible: provider.filterData
                                    //                   .getFilterCount() >
                                    //                   0,
                                    //               child: Positioned(
                                    //                 right: 0,
                                    //                 top: 0,
                                    //                 child: Container(
                                    //                   width: 8,
                                    //                   height: 8,
                                    //                   decoration: BoxDecoration(
                                    //                       shape: BoxShape.circle,
                                    //                       color: Colors.green),
                                    //                 ),
                                    //               ),
                                    //             )
                                    //           ],
                                    //         )),
                                    //   ),
                                    // )
                                  ],
                                ),
                                // ResponsiveWidget.isLargeScreen(context) ||
                                //         ResponsiveWidget.isMediumScreen(context)
                                //     ? Padding(
                                //         padding: const EdgeInsets.symmetric(
                                //             horizontal: 20.0),
                                //         child: Column(
                                //           children: [
                                //             SizedBox(
                                //               height: 20,
                                //             ),
                                //             Divider(
                                //               thickness: 1,
                                //               height: 1,
                                //               color: ColorsUtil.lighterGrey,
                                //             ),
                                //           ],
                                //         ),
                                //       )
                                //     : Container(),
                              ]),
                        ),
                      ],
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
                        color: ColorsUtil.marketCardContainer,
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
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
                                    )
                                  : Text(
                                      'Expand',
                                      maxLines: 1,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontWeight: FontWeight.w500,
                                          color: ColorsUtil.blueColorCart,
                                          fontSize: 12),
                                    ),
                              SizedBox(
                                width: 5.0,
                              ),
                              isHide == true
                                  ? Icon(
                                      Icons.keyboard_arrow_up,
                                      size: 15,
                                      color: ColorsUtil.blueColorCart,
                                    )
                                  : Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 15,
                                      color: ColorsUtil.blueColorCart,
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
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
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 60.0),
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
                              if (loading && provider.filterData.pageNo != 0) {
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
                              await provider.getMarketPlaceData(isFilter: true);
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
