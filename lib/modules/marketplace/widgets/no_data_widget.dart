import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';

class MarketNoDataWidget extends StatelessWidget {
  final bool isFilter;

  const MarketNoDataWidget({Key? key, this.isFilter = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: PbEmptyState(
        icon: Icons.search_off_rounded,
        message: isFilter
            ? 'No loans match this filter. Try a different risk level.'
            : 'No loans are open for funding right now. Check back soon.',
      ),
    );
  }
}
