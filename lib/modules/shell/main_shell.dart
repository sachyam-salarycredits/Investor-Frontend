import 'package:peerbridge/modules/home/screens/home_screen.dart';
import 'package:peerbridge/modules/home/screens/portfolio_analysis_screen.dart';
import 'package:peerbridge/modules/home/screens/profile_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/new_market_place_screen.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/pb/pb_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ShellTab {
  ShellTab._();

  static const home = 0;
  static const explore = 1;
  static const portfolio = 2;
  static const profile = 3;

  static int fromQuery(String? value) {
    switch (value) {
      case 'explore':
        return explore;
      case 'portfolio':
        return portfolio;
      case 'profile':
        return profile;
      default:
        return home;
    }
  }
}

/// Exposes tab switching to screens hosted inside [MainShell].
class MainShellScope extends InheritedWidget {
  final int currentIndex;
  final void Function(int index) switchTab;

  const MainShellScope({
    Key? key,
    required this.currentIndex,
    required this.switchTab,
    required Widget child,
  }) : super(key: key, child: child);

  static MainShellScope? maybeOf(BuildContext context) => context
      .getElementForInheritedWidgetOfExactType<MainShellScope>()
      ?.widget as MainShellScope?;

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      oldWidget.currentIndex != currentIndex;
}

/// Switches to [tab] when inside the shell, otherwise pushes the standalone
/// route for that tab.
void openShellTab(BuildContext context, int tab) {
  if (tab == ShellTab.explore) {
    context.read<AppStateProvider>().isPrimaryMarketSelected = true;
  }
  final scope = MainShellScope.maybeOf(context);
  if (scope != null) {
    scope.switchTab(tab);
    return;
  }
  final provider = context.read<AppStateProvider>();
  switch (tab) {
    case ShellTab.explore:
      context.pushNamed(RoutesName.NewMarketPlace, queryParams: {
        "data": Utils.buildTokenJson(provider.token ?? "", provider.customerId)
      });
      break;
    case ShellTab.portfolio:
      context.pushNamed(RoutesName.PortfolioAnalysis);
      break;
    case ShellTab.profile:
      context.pushNamed(RoutesName.ProfileScreen);
      break;
    default:
      context.pushNamed(RoutesName.HomeScreen);
  }
}

class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({Key? key, this.initialTab = ShellTab.home})
      : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  final Set<int> _visited = {};
  final Map<int, int> _reloadCount = {};

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab;
    _visited.add(_index);
  }

  void _switchTab(int index) {
    if (index == _index) {
      if (index == ShellTab.portfolio || index == ShellTab.explore) {
        setState(() => _reloadCount[index] = (_reloadCount[index] ?? 0) + 1);
      }
      return;
    }
    setState(() {
      _index = index;
      if (_visited.contains(index) &&
          (index == ShellTab.portfolio || index == ShellTab.explore)) {
        _reloadCount[index] = (_reloadCount[index] ?? 0) + 1;
      }
      _visited.add(index);
    });
  }

  Widget _buildTab(int index) {
    final key = ValueKey('shell-tab-$index-${_reloadCount[index] ?? 0}');
    switch (index) {
      case ShellTab.explore:
        return NewMarketPlace(key: key, embedded: true);
      case ShellTab.portfolio:
        return PortfolioAnalysis(key: key, embedded: true);
      case ShellTab.profile:
        return ProfileScreen(key: key, embedded: true);
      default:
        return HomeScreen(key: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_index != ShellTab.home) {
          _switchTab(ShellTab.home);
        }
        return false;
      },
      child: MainShellScope(
        currentIndex: _index,
        switchTab: _switchTab,
        child: Scaffold(
          backgroundColor: AppColors.screenBottom,
          body: DecoratedBox(
            decoration:
                const BoxDecoration(gradient: AppColors.screenGradient),
            child: IndexedStack(
              index: _index,
              children: [
                for (var i = 0; i < pbNavItems.length; i++)
                  _visited.contains(i)
                      ? _buildTab(i)
                      : const SizedBox.shrink(),
              ],
            ),
          ),
          bottomNavigationBar: PbBottomNav(
            currentIndex: _index,
            onTap: _switchTab,
          ),
        ),
      ),
    );
  }
}
