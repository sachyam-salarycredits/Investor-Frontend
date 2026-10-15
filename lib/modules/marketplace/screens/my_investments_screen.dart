import 'package:peerbridge/modules/marketplace/models/my_investments_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/investment_row_card.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyInvestmentsScreen extends StatefulWidget {
  const MyInvestmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyInvestmentsScreen> createState() => _MyInvestmentsScreenState();
}

class _MyInvestmentsScreenState extends State<MyInvestmentsScreen> {
  bool isLoading = true;
  List<MyInvestmentLoan> loans = [];
  int selectedSection = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await context.read<AppStateProvider>().getMyInvestments();
    if (!mounted) return;
    setState(() {
      loans = data?.loanList ?? [];
      isLoading = false;
    });
  }

  List<MyInvestmentLoan> get _activeLoans =>
      loans.where((loan) => !isClosedInvestmentStatus(loan.status)).toList();

  List<MyInvestmentLoan> get _closedLoans =>
      loans.where((loan) => isClosedInvestmentStatus(loan.status)).toList();

  @override
  Widget build(BuildContext context) {
    final visible = selectedSection == 0 ? _activeLoans : _closedLoans;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: PbPageHeader(
          title: 'My investments',
          onBack: () => context.pop(),
        ),
        body: PeerBridgeLoader(
          isLoading: isLoading,
          child: RefreshIndicator(
            color: AppColors.green,
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                SegmentedTabs(
                  tabs: [
                    SegmentedTab('Active', count: _activeLoans.length),
                    SegmentedTab('Closed', count: _closedLoans.length),
                  ],
                  selectedIndex: selectedSection,
                  onChanged: (i) => setState(() => selectedSection = i),
                ),
                const SizedBox(height: 16),
                if (!isLoading && loans.isEmpty)
                  const PbEmptyState(
                    icon: Icons.savings_outlined,
                    message: "You haven't funded any loans yet.",
                  )
                else if (!isLoading && visible.isEmpty)
                  PbEmptyState(
                    message: selectedSection == 0
                        ? 'No active loans.'
                        : 'No closed loans.',
                  )
                else
                  for (var i = 0; i < visible.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    InvestmentRowCard(loan: visible[i]),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
