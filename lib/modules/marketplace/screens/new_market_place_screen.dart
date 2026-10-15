import 'dart:async';

import 'package:peerbridge/modules/marketplace/models/filter_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/loan_cart_button.dart';
import 'package:peerbridge/modules/marketplace/widgets/market_place_grid_cards.dart';
import 'package:peerbridge/modules/marketplace/widgets/no_data_widget.dart';
import 'package:peerbridge/modules/marketplace/widgets/secondary_market_card.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routes_management/routes_list.dart';

class NewMarketPlace extends StatefulWidget {
  bool showSocialImpactLoans;
  final bool embedded;
  NewMarketPlace({
    Key? key,
    this.showSocialImpactLoans = false,
    this.embedded = false,
  }) : super(key: key);

  @override
  _NewMarketPlaceState createState() => _NewMarketPlaceState();
}

class _NewMarketPlaceState extends State<NewMarketPlace> {
  bool isFilter = false;
  bool isLoader = false;
  ScrollController scrollController = ScrollController();
  bool isFirstCall = true;
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
  bool loadingAmount = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollEndNotifier);
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    if (!provider.isPrimaryMarketSelected) selectedMarket = marketList[1];
    getFundDetails();
    provider.filterData = FilterDetails();
    getFundsDetails();
  }

  void loadMarkets(String? selectedMarket, bool isFilter) async {
    var provider = Provider.of<AppStateProvider>(context, listen: false);
    provider.filterData = FilterDetails();
    if (isFilter) {
      provider.filterData = FilterDetails();
      if (selectedRisk == 'Show All') {
        provider.filterData = FilterDetails();
      } else if (selectedRisk == 'Social Impact Loan') {
        provider.filterData.grade = [];
        provider.filterData.products = [selectedRisk ?? ''];
      } else {
        provider.filterData.products = [];
        provider.filterData.grade = [selectedRisk ?? ''];
      }
    }
    provider.isPrimaryMarketSelected = selectedMarket != marketList[1];
    setLoader(true);
    isFilter
        ? await provider.getMarketPlaceData(isFilter: true)
        : await provider.getMarketPlaceData();
    setLoader(false);
  }

  void getFundDetails() async {
    setState(() {
      loadingAmount = true;
    });
    await context.read<AppStateProvider>().getUserFundDetails();
    if (!mounted) return;
    setState(() {
      loadingAmount = false;
    });
  }

  void scrollEndNotifier() async {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        !isFilter &&
        isFirstCall) {
      isFirstCall = false;
      await context.read<AppStateProvider>().getNextMarketPlaceData();
      if (!mounted) return;
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

    if (Utils.showSocialImpactLoans) {
      selectedRisk = 'Social Impact Loan';
      Utils.showSocialImpactLoans = false;
      provider.filterData.grade = [];
      provider.filterData.products = [selectedRisk ?? ''];

      await context.read<AppStateProvider>().getMarketPlaceData(isFilter: true);
    } else {
      await context.read<AppStateProvider>().getMarketPlaceData();
    }
    await context.read<AppStateProvider>().getUserFundDetails();
    setLoader(false);
  }

  void setLoader(loader) {
    if (!mounted) return;
    setState(() {
      isLoader = loader;
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<AppStateProvider>();
    provider.getUserFundDetails();
    provider.getStatement();
    await provider.getMarketPlaceData(isFilter: true);
  }

  Future<void> _refreshAfterCheckout() async {
    final provider = context.read<AppStateProvider>();
    setLoader(true);
    provider.filterData = FilterDetails();
    provider.getUserFundDetails();
    provider.getStepsStatus();
    provider.getCustomerDetails();
    provider.getStatement();
    await provider.getMarketPlaceData(isFilter: true);
    if (!mounted) return;
    setState(() => selectedRisk = 'Show All');
    setLoader(false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(builder: (context, provider, child) {
      final scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.embedded
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          appBar: widget.embedded
              ? null
              : PbPageHeader(
                  title: 'Explore loans',
                  onBack: () {
                    provider.filterData = FilterDetails();
                    context.pop();
                  },
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 528),
              child: LoanCartButton(
                key: provider.loanButtonState,
                onUpdate: () => setState(() {}),
                refreshData: _refreshAfterCheckout,
              ),
            ),
          ),
          body: PeerBridgeLoader(
            isLoading: isLoader || provider.isMarketPlaceLoading.value,
            child: SafeArea(
              top: widget.embedded,
              bottom: false,
              child: RefreshIndicator(
                color: AppColors.green,
                onRefresh: _refresh,
                child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (widget.embedded) ...[
                              _embeddedHeader(provider),
                              const SizedBox(height: 18),
                            ],
                            BalanceStrip(
                              amount: loadingAmount
                                  ? '…'
                                  : '₹${Utils.availableAmount.truncate().commaAddedValue()}',
                              note:
                                  '${provider.overViewDetail.numberOfLoan.commaAddedValue()} loans worth ₹${provider.overViewDetail.totalLoanAmount.commaAddedValue()} open',
                              onAdd: () => context
                                  .pushNamed(RoutesName.NewFundTransferScreen),
                            ),
                            const SizedBox(height: 18),
                            SegmentedTabs(
                              tabs: const [
                                SegmentedTab('Primary'),
                                SegmentedTab('Secondary'),
                              ],
                              selectedIndex:
                                  selectedMarket == marketList[1] ? 1 : 0,
                              onChanged: (i) {
                                final market = marketList[i];
                                if (market == selectedMarket) return;
                                setState(() {
                                  selectedMarket = market;
                                  selectedRisk = 'Show All';
                                });
                                loadMarkets(market, false);
                              },
                            ),
                            const SizedBox(height: 14),
                            _riskChips(),
                            const SizedBox(height: 16),
                            _loanList(provider),
                            ValueListenableBuilder<bool>(
                              valueListenable: provider.isMarketPlaceLoading,
                              builder: (_, loading, __) {
                                if (loading && provider.filterData.pageNo != 0) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      children: [
                                        const CupertinoActivityIndicator(),
                                        const SizedBox(height: 6),
                                        Text('Loading more loans',
                                            style: AppTextStyles.caption),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox();
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

      if (widget.embedded) return scaffold;
      return WillPopScope(
        onWillPop: () async {
          provider.filterData = FilterDetails();
          return true;
        },
        child: scaffold,
      );
    });
  }

  Widget _embeddedHeader(AppStateProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EXPLORE', style: AppTextStyles.eyebrow),
              const SizedBox(height: 4),
              Text('Find loans to fund', style: AppTextStyles.headline),
            ],
          ),
        ),
        PbIconButton(
          icon: Icons.refresh_rounded,
          onTap: () async {
            setLoader(true);
            await _refresh();
            setLoader(false);
          },
        ),
      ],
    );
  }

  Widget _riskChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: riskList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final risk = riskList[i];
          final selected = risk == selectedRisk;
          final label = risk == 'Show All'
              ? 'All loans'
              : risk == 'Social Impact Loan'
                  ? 'Social impact'
                  : risk;
          return GestureDetector(
            onTap: () {
              if (selected) return;
              setState(() => selectedRisk = risk);
              loadMarkets(selectedMarket, true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.greenDeep : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: selected ? AppColors.greenDeep : AppColors.line),
              ),
              child: Text(
                label,
                style: AppTextStyles.semiBold(12.5,
                    color: selected ? Colors.white : AppColors.ink),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _loanList(AppStateProvider provider) {
    final isPrimaryMarket = provider.isPrimaryMarketSelected;
    final loans = isPrimaryMarket
        ? provider.primaryMarketLoans ?? []
        : provider.secondaryMarketLoans ?? [];

    if (loans.isEmpty) {
      if (provider.isMarketPlaceLoading.value) return const SizedBox();
      return MarketNoDataWidget(isFilter: !provider.isFilterClear());
    }

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = width > 1000
          ? 3
          : width > 640
              ? 2
              : 1;
      const gap = 14.0;
      final cardWidth = (width - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var index = 0; index < loans.length; index++)
            SizedBox(width: cardWidth, child: getCardWidget(index)),
        ],
      );
    });
  }

  Widget getCardWidget(int index) {
    if (context.read<AppStateProvider>().isPrimaryMarketSelected) {
      return MarketPlaceCard(
        index: index,
        onUpdate: () {
          setState(() {});
        },
      );
    }
    return SecondaryMarketPlaceCard(
      index: index,
      onUpdate: () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollEndNotifier);
    scrollController.dispose();
    super.dispose();
  }
}
