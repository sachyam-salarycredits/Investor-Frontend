import 'dart:io';

import 'package:peerbridge/modules/home/models/YoutubeVediosModel.dart';
import 'package:peerbridge/modules/home/screens/player_video_page.dart';
import 'package:peerbridge/modules/home/screens/stories_page.dart';
import 'package:peerbridge/modules/shell/main_shell.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes_management/routes_list.dart';
import '../../../utils/images.dart';
import '../models/NewOfferModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NewOfferModel? offerModelResponse;
  PageController? _controller;
  int currentIndex = 0;
  List<VideoData>? youtubevideos = [];

  bool loadingAmount = false;
  bool loading = false;

  Future<void> resetOnbaordingScreenStatus() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setBool('show_onboarding', false);
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    Utils.isFirstDepositVideoValidate = false;
    resetOnbaordingScreenStatus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setLoader(true);
      // checkstatus first — it writes StatusTable; getuserDetails reads
      // enableDialogFiled from that table (E-KYC / SIP / MIP banners).
      await context.read<AppStateProvider>().getStepsStatus();
      await context.read<AppStateProvider>().getCustomerDetails();
      await context.read<AppStateProvider>().getStatement();
      context.read<AppStateProvider>().getFlyyWebToken();
      setLoader(false);
      getPortfolioSummary();
    });
    getFundDetails();
    setOsType();
    setAppsFlyId();
    getOfferData();
    getYoutubeVideosLocaly();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

  Future<void> getPortfolioSummary() async {
    try {
      await context.read<AppStateProvider>().getPortfolioAnalysisData();
    } catch (e) {
      debugPrint('Home portfolio summary failed: $e');
    }
  }

  setOsType() async {
    if (Utils.isWeb) return;
    context
        .read<AppStateProvider>()
        .setOsType(Platform.isIOS ? 'IOS' : 'ANDROID');
  }

  setAppsFlyId() async {
    context.read<AppStateProvider>().setappsFlyIdUpdate(AFSdk.appFlyId);
  }

  getOfferData() async {
    setLoader(true);
    offerModelResponse = (await context.read<AppStateProvider>().getOffer());
    setLoader(false);
  }

  getYoutubeVideosLocaly() async {
    final youtubeVideo = context.read<AppStateProvider>().youtubeVideos;
    youtubevideos = youtubeVideo?.data
        ?.where((element) => element.videoType == Constants.homeScreenKey)
        .toList();
  }

  setLoader(bool value) {
    if (!mounted) return;
    setState(() {
      loading = value;
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<AppStateProvider>();
    await Future.wait([
      provider.getUserFundDetails(),
      getPortfolioSummary(),
    ]);
    if (mounted) setState(() {});
  }

  void _openAddFunds() => context.pushNamed(RoutesName.NewFundTransferScreen);

  void _openOffers() {
    if (Utils.isWeb) {
      context.pushNamed(RoutesName.SettingsScreen);
    } else {
      FlyyFlutterPlugin.openFlyyOffersPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PeerBridgeLoader(
        isLoading: loading,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.green,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: mainWidget(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainWidget(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final userDetails = provider.userDetails;
    final active = provider.portfolioSummary?.active;
    final closed = provider.portfolioSummary?.closed;
    final fullName = userDetails?.panDetails?.fullName ?? '';
    final firstName = fullName.trim().split(' ').first;
    final kycDone = provider.stepsData?.kyc == '1';

    final available = Utils.availableAmount;
    final outstanding = active?.principalOutstanding ?? 0;
    final totalValue = available + outstanding;
    final earned = active?.interestEarned ?? 0;
    final percent = active?.percentageEarned ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PbBrandHeader(onBellTap: _openOffers),
        const SizedBox(height: 22),
        _greeting(context, firstName, kycDone),
        if (!Utils.isWeb && (offerModelResponse?.data?.count ?? 0) > 0) ...[
          const SizedBox(height: 18),
          _offersRow(),
        ],
        const SizedBox(height: 20),
        PortfolioValueCard(
          value: '₹${totalValue.truncate().commaAddedValue()}',
          changeBadge: percent > 0 ? '+${percent.toStringAsFixed(2)}%' : null,
          changeNote: earned > 0
              ? '₹${earned.commaAddedValue()} interest earned'
              : 'Start earning with your first loan',
          periodLabel: 'Last 6 months',
          chartPoints: _chartPoints(provider),
          onPrimary: () => openShellTab(context, ShellTab.explore),
          onSecondary: _openAddFunds,
        ),
        const SizedBox(height: 26),
        PbSectionTitle(
          title: 'At a glance',
          subtitle: (active?.loanCount ?? 0) > 0
              ? 'Across ${active!.loanCount} active loans'
              : 'Your money, at work',
          actionLabel: 'Details',
          onAction: () => openShellTab(context, ShellTab.portfolio),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.account_balance_wallet_outlined,
                value: loadingAmount
                    ? '…'
                    : '₹${available.truncate().commaAddedValue()}',
                label: 'Available to invest',
                onTap: _openAddFunds,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.trending_up_rounded,
                value: '${active?.loanCount ?? 0}',
                label: (closed?.loanCount ?? 0) > 0
                    ? 'Active · ${closed!.loanCount} closed'
                    : 'Active loans',
                iconBg: AppColors.goldSoft,
                iconColor: AppColors.goldDark,
                onTap: () => openShellTab(context, ShellTab.portfolio),
              ),
            ),
          ],
        ),
        ..._actionBanners(context, userDetails?.enableDialogFiled),
        const SizedBox(height: 22),
        _socialImpactCard(context),
        if ((youtubevideos?.length ?? 0) > 0) ...[
          const SizedBox(height: 26),
          const PbSectionTitle(
            title: 'Learn with PeerBridge',
            subtitle: 'Short videos on P2P lending',
          ),
          const SizedBox(height: 12),
          _videoCarousel(context),
        ],
        const SizedBox(height: 22),
        ReferCard(
          title: 'Refer a friend',
          subtitle: 'Invite friends to PeerBridge and earn rewards.',
          onTap: () {
            if (!Utils.isWeb) FlyyFlutterPlugin.openFlyyInviteAndEarnPage(0);
          },
        ),
      ],
    );
  }

  List<double> _chartPoints(AppStateProvider provider) {
    final earned = provider.portfolioAnalysis?.data?.interestEarned;
    if (earned == null) return const [];
    final months = <dynamic>[
      earned.interestEarned6,
      earned.interestEarned5,
      earned.interestEarned4,
      earned.interestEarned3,
      earned.interestEarned2,
      earned.interestEarned1,
    ];
    final points = <double>[];
    for (final month in months) {
      final double? value = month?.totalInvestement as double?;
      if (value != null) points.add(value);
    }
    final hasSignal = points.where((p) => p > 0).length >= 2;
    return hasSignal ? points : const [];
  }

  Widget _greeting(BuildContext context, String firstName, bool kycDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstName.isEmpty
              ? '${Utils.getCurrentGreetings()}'
              : '${Utils.getCurrentGreetings()}, $firstName',
          style: AppTextStyles.regular(14, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'Make your money move. ',
            style: AppTextStyles.medium(28)
                .copyWith(height: 1.3, letterSpacing: -0.5),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: kycDone
                      ? null
                      : () => context.pushNamed(RoutesName.AadharVerification),
                  child: _KycPill(verified: kycDone),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _offersRow() {
    final items = offerModelResponse?.data?.items ?? [];
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => _openOffer(index),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: item.iconUrl == null
                            ? Image.asset(LocalImages.offer_icon)
                            : FadeInImage(
                                image: NetworkImage(item.iconUrl ?? ''),
                                placeholder:
                                    AssetImage(LocalImages.offer_icon),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title ?? '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTextStyles.medium(11, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openOffer(int index) {
    final item = offerModelResponse?.data?.items?[index];
    if (item == null) return;
    if (item.fly_vedio_url != null && item.fly_vedio_url != '') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerVideoPage(
            videoURL: item.fly_vedio_url ?? '',
            validateWatchTime: false,
            id: item.id,
            showNextButton: true,
            type: item.screenCode ?? '',
          ),
        ),
      ).then((value) {
        if (value == true) {
          Utils.getOfferOnTap(item.screenCode ?? '', item.id);
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => StoriesPage(
            storyUrl: item.gifUrl ?? '',
            thumbNailUrl: item.iconUrl ?? '',
            title: item.title ?? '',
            type: item.screenCode ?? '',
            id: item.id,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  List<Widget> _actionBanners(BuildContext context, String? field) {
    Widget? banner;
    switch (field) {
      case 'E-KYC':
        banner = _ActionBanner(
          icon: Icons.verified_user_outlined,
          title: 'Complete your e-KYC',
          message: 'Verify your identity to start investing.',
          onTap: () => context.pushNamed(RoutesName.AadharVerification),
        );
        break;
      case 'SIP':
        banner = _ActionBanner(
          icon: Icons.event_repeat_rounded,
          title: 'Enable your SIP',
          message: 'Invest a fixed amount automatically every month.',
          onTap: () => context.pushNamed(RoutesName.IntroScreen,
              params: {Constants.forSIP: 'true'}),
        );
        break;
      case 'MIP':
        banner = _ActionBanner(
          icon: Icons.savings_outlined,
          title: 'Enable your MIP',
          message:
              'Monthly Income Plan lets you receive passive income every month.',
          onTap: () => context.pushNamed(RoutesName.MIPSetUp),
        );
        break;
    }
    if (banner == null) return const [];
    return [const SizedBox(height: 16), banner];
  }

  Widget _socialImpactCard(BuildContext context) {
    return PbCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      radius: 22,
      onTap: () {
        Utils.showSocialImpactLoans = true;
        openShellTab(context, ShellTab.explore);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SOCIAL IMPACT', style: AppTextStyles.eyebrow),
                const SizedBox(height: 6),
                Text('Invest to change lives and livelihoods',
                    style: AppTextStyles.cardTitle),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Invest now',
                        style:
                            AppTextStyles.semiBold(13, color: AppColors.green)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.green),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(LocalImages.socialImpactLoan, width: 120),
        ],
      ),
    );
  }

  Widget _videoCarousel(BuildContext context) {
    final videos = youtubevideos ?? [];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: _controller,
              itemCount: videos.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    if (Utils.isWeb) {
                      Utils.launchURL(videos[i].videoUrl);
                    } else {
                      context.pushNamed(RoutesName.VideoPlayerPage, params: {
                        Constants.videoUrl: videos[i].videoUrl ?? '',
                        Constants.validateWatchTime: 'false'
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        videos[i].thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.sage),
                      ),
                      Container(color: AppColors.scrim.withOpacity(0.18)),
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              size: 34, color: AppColors.green),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (videos.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < videos.length; i++) SlideDots(i == currentIndex)
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onTap;

  const _ActionBanner({
    required this.icon,
    required this.title,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.greenGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow(0.12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.goldLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.semiBold(15, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(message,
                      style: AppTextStyles.regular(12,
                          color: Colors.white.withOpacity(0.72))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Enable',
                  style: AppTextStyles.semiBold(12, color: AppColors.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycPill extends StatelessWidget {
  final bool verified;

  const _KycPill({required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.green : AppColors.goldDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: verified ? AppColors.mint : AppColors.goldSoft,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_user_outlined : Icons.info_outline_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            verified ? 'Verified' : 'Complete KYC',
            style: AppTextStyles.medium(13, color: color),
          ),
        ],
      ),
    );
  }
}

/// Page indicator dot for the home video carousel.
class SlideDots extends StatelessWidget {
  final bool isActive;
  const SlideDots(this.isActive, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.green : AppColors.sage,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
