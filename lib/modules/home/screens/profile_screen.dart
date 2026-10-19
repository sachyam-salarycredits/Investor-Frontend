import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/modules/shell/main_shell.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final Size? screenSize;
  final bool embedded;

  ProfileScreen({Key? key, this.screenSize, this.embedded = false})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool loadingAmount = false;

  @override
  void initState() {
    super.initState();
    getFundDetails();
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

  void logOutTap() {
    Utils.showDoubleBtnAlert(
        context: context,
        title: "Logout",
        msg: 'Are you sure want to Logout?',
        onTap: () {
          context.read<AppStateProvider>().logout();
          context.read<AppStateProvider>().clearUserState();
          context.goNamed(RoutesName.Login);
        });
  }

  void _openOffers() {
    if (Utils.isWeb) {
      context.pushNamed(RoutesName.SettingsScreen);
    } else {
      FlyyFlutterPlugin.openFlyyOffersPage();
    }
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final userData = provider.userDetails;
    final background = widget.embedded ? Colors.transparent : AppColors.surface;
    if (userData == null) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PeerBridgeLoader(
        isLoading: isLoading,
        child: Scaffold(
          backgroundColor: background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.green,
              onRefresh: () async {
                await Future.wait([
                  provider.getUserFundDetails(),
                  provider.getCustomerDetails(),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _centered(_topSection(userData)),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.forest,
                      child: _centered(_panel(provider)),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(color: AppColors.forest),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centered(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }

  Widget _topSection(UserDetails userData) {
    final profile = userData.profileDetails;
    final name = profile?.fullName ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (!widget.embedded) ...[
                PbIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(child: PbBrandHeader(onBellTap: _openOffers)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _Avatar(
                initials: _initials(name),
                url: profile?.profileUrl ?? '',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.medium(22)
                          .copyWith(letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regular(13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.pushNamed(RoutesName.ProfileDetail),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_outlined,
                          size: 15, color: AppColors.green),
                      const SizedBox(width: 5),
                      Text('Edit',
                          style: AppTextStyles.semiBold(13,
                              color: AppColors.green)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel(AppStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BalanceStrip(
            amount: loadingAmount
                ? '…'
                : '₹${Utils.availableAmount.truncate().commaAddedValue()}',
            onAdd: () => context.pushNamed(RoutesName.NewFundTransferScreen),
          ),
          const SizedBox(height: 18),
          _PanelLink(
            label: 'Account statement',
            onTap: () => context.pushNamed(RoutesName.AccountStatement),
          ),
          const SizedBox(height: 10),
          _PanelLink(
            label: 'My investments',
            onTap: () => openShellTab(context, ShellTab.portfolio),
          ),
          const SizedBox(height: 10),
          _PanelLink(
            label: 'Redemptions',
            onTap: () => context.pushNamed(RoutesName.Redemption),
          ),
          const SizedBox(height: 10),
          _PanelLink(
            label: 'Withdraw funds',
            onTap: () => context.pushNamed(RoutesName.Withdraw),
          ),
          const SizedBox(height: 10),
          _PanelLink(
            label: 'Account settings',
            onTap: () => context.pushNamed(RoutesName.SettingsScreen),
          ),
          const SizedBox(height: 10),
          _PanelLink(
            label: 'Call support',
            onTap: () => Utils.launchSupportCall(),
          ),
          if (!Utils.isWeb) ...[
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _PanelTile(
                    icon: Icons.emoji_events_outlined,
                    label: 'Rewards',
                    onTap: () => FlyyFlutterPlugin.openFlyyRewardsPage(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PanelTile(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers',
                    onTap: () => FlyyFlutterPlugin.openFlyyOffersPage(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PanelTile(
                    icon: Icons.quiz_outlined,
                    label: 'Quiz',
                    onTap: () => FlyyFlutterPlugin.openFlyyQuizListPage(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ReferBanner(
              onTap: () => FlyyFlutterPlugin.openFlyyCustomInviteAndEarnPage(
                  0, '#ffffff'),
            ),
          ],
          const SizedBox(height: 22),
          _PanelLink(
            label: 'Log out',
            color: const Color(0xffFFB4A8),
            trailing: const Icon(Icons.logout_rounded,
                size: 18, color: Color(0xffFFB4A8)),
            onTap: logOutTap,
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              'PeerBridge · Version ${provider.appVersion}',
              style: AppTextStyles.regular(11,
                  color: Colors.white.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

}

class _Avatar extends StatelessWidget {
  final String initials;
  final String url;

  const _Avatar({required this.initials, required this.url});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = url.startsWith('http://') || url.startsWith('https://');
    final fallback = Center(
      child: Text(
        initials,
        style: AppTextStyles.medium(20, color: Colors.white),
      ),
    );
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.greenGradient,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}

class _PanelLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color color;

  const _PanelLink({
    required this.label,
    required this.onTap,
    this.trailing,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.medium(13.5, color: color)),
            ),
            trailing ??
                Icon(Icons.arrow_forward_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

class _PanelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PanelTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.goldLight),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.medium(12.5, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _ReferBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ReferBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.greenDeep.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.card_giftcard_rounded,
                  color: AppColors.greenDeep, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Invite friends, earn rewards',
                      style: AppTextStyles.semiBold(13,
                          color: AppColors.greenDeep)),
                  const SizedBox(height: 2),
                  Text(
                    'Share PeerBridge with people you trust.',
                    style: AppTextStyles.regular(10.5,
                        color: AppColors.greenDeep.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.greenDeep, size: 18),
          ],
        ),
      ),
    );
  }
}
