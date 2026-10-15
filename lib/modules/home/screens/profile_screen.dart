import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/modules/profile/widgets/logoWidget.dart';
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
  bool _showStatements = false;

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final userData = provider.userDetails;
    if (userData == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PeerBridgeLoader(
        isLoading: isLoading,
        child: Scaffold(
          backgroundColor: AppColors.surface,
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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: mainWidget(context, userData, provider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainWidget(
      BuildContext context, UserDetails userData, AppStateProvider provider) {
    final kycDone = provider.stepsData?.kyc == '1';
    return Column(
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
            Expanded(child: Text('Profile', style: AppTextStyles.headline)),
            PbIconButton(
              icon: Icons.settings_outlined,
              onTap: () => context.pushNamed(RoutesName.SettingsScreen),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _identityPanel(userData, kycDone),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.account_balance_outlined,
                label: 'Withdraw funds',
                onTap: () => context.pushNamed(RoutesName.Withdraw),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAction(
                icon: Icons.currency_exchange_rounded,
                label: 'Redemption',
                onTap: () => context.pushNamed(RoutesName.Redemption),
              ),
            ),
          ],
        ),
        if (!Utils.isWeb) ...[
          const SizedBox(height: 22),
          const PbSectionTitle(
            title: 'Rewards & offers',
            subtitle: 'Earn while you invest',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RewardTile(
                  icon: Icons.emoji_events_outlined,
                  label: 'Rewards',
                  onTap: () => FlyyFlutterPlugin.openFlyyRewardsPage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RewardTile(
                  icon: Icons.local_offer_outlined,
                  label: 'Offers',
                  onTap: () => FlyyFlutterPlugin.openFlyyOffersPage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RewardTile(
                  icon: Icons.quiz_outlined,
                  label: 'Quiz',
                  onTap: () => FlyyFlutterPlugin.openFlyyQuizListPage(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        const PbSectionTitle(title: 'Account'),
        const SizedBox(height: 12),
        PbCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              _LinkRow(
                icon: Icons.pie_chart_outline_rounded,
                label: 'My investments',
                onTap: () => openShellTab(context, ShellTab.portfolio),
              ),
              const _LinkDivider(),
              _LinkRow(
                icon: Icons.receipt_long_outlined,
                label: 'Account statement',
                trailing: AnimatedRotation(
                  turns: _showStatements ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                ),
                onTap: () =>
                    setState(() => _showStatements = !_showStatements),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: getStatement(),
                crossFadeState: _showStatements
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
              const _LinkDivider(),
              _LinkRow(
                icon: Icons.manage_accounts_outlined,
                label: 'Account settings',
                onTap: () => context.pushNamed(RoutesName.SettingsScreen),
              ),
              const _LinkDivider(),
              _LinkRow(
                icon: Icons.support_agent_rounded,
                label: 'Call support',
                onTap: () => Utils.launchSupportCall(),
              ),
              const _LinkDivider(),
              _LinkRow(
                icon: Icons.logout_rounded,
                label: 'Log out',
                color: AppColors.error,
                showChevron: false,
                onTap: logOutTap,
              ),
            ],
          ),
        ),
        if (!Utils.isWeb) ...[
          const SizedBox(height: 18),
          ReferCard(
            title: 'Invite friends, earn rewards',
            subtitle: 'Share PeerBridge with people you trust.',
            onTap: () =>
                FlyyFlutterPlugin.openFlyyCustomInviteAndEarnPage(0, '#ffffff'),
          ),
        ],
        const SizedBox(height: 22),
        Center(
          child: Text(
            'PeerBridge · Version ${provider.appVersion}',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  Widget _identityPanel(UserDetails userData, bool kycDone) {
    final profile = userData.profileDetails;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withOpacity(0.2),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                  ),
                  child: LogoWidget(size: 60, url: profile?.profileUrl ?? ''),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiBold(18, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.regular(12,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            kycDone
                                ? Icons.verified_rounded
                                : Icons.error_outline_rounded,
                            size: 14,
                            color:
                                kycDone ? AppColors.greenLink : AppColors.goldLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            kycDone ? 'KYC verified' : 'KYC pending',
                            style: AppTextStyles.medium(11,
                                color: kycDone
                                    ? AppColors.greenLink
                                    : AppColors.goldLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pushNamed(RoutesName.ProfileDetail),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('Edit',
                            style: AppTextStyles.semiBold(12,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          BalanceStrip(
            amount: loadingAmount
                ? '…'
                : '₹${Utils.availableAmount.truncate().commaAddedValue()}',
            onAdd: () => context.pushNamed(RoutesName.NewFundTransferScreen),
          ),
        ],
      ),
    );
  }

  Widget getStatement() {
    final provider = Provider.of<AppStateProvider>(context);
    final rows = <Widget>[];
    for (final statement in provider.statementList) {
      final currentYear = int.tryParse(statement.year.trim()) ?? 0;
      if (currentYear == 0) continue;
      rows.add(InkWell(
        onTap: () {
          if (statement.statementUrl != null && statement.statementUrl != '') {
            Utils.launchURL(statement.statementUrl);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const SizedBox(width: 42),
              Expanded(
                child: Text('Financial year ${currentYear - 1}–$currentYear',
                    style: AppTextStyles.medium(13)),
              ),
              const Icon(Icons.download_rounded,
                  size: 18, color: AppColors.green),
            ],
          ),
        ),
      ));
    }
    if (rows.isEmpty) {
      rows.add(Padding(
        padding: const EdgeInsets.fromLTRB(58, 4, 16, 12),
        child: Text('No statements available yet.',
            style: AppTextStyles.caption),
      ));
    }
    return Column(children: rows);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PbCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PbIconTile(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                maxLines: 2, style: AppTextStyles.semiBold(13)),
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RewardTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PbCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          PbIconTile(
            icon: icon,
            size: 40,
            background: AppColors.goldSoft,
            color: AppColors.goldDark,
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.semiBold(12.5)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;
  final bool showChevron;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.green;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            PbIconTile(
              icon: icon,
              background: tint.withOpacity(0.1),
              color: tint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.medium(14,
                      color: color ?? AppColors.ink)),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _LinkDivider extends StatelessWidget {
  const _LinkDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 60, color: AppColors.line);
}
