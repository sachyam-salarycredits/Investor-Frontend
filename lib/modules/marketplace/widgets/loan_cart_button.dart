import 'package:peerbridge/modules/shell/main_shell.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'loan_cart_popup.dart';

/// Floating cart bar shown on the marketplace while loans are selected.
class LoanCartButton extends StatefulWidget {
  final Function onUpdate;
  final Function refreshData;
  const LoanCartButton({
    Key? key,
    required this.onUpdate,
    required this.refreshData,
  }) : super(key: key);

  @override
  LoanCartButtonState createState() => LoanCartButtonState();
}

class LoanCartButtonState extends State<LoanCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scale;

  animate() {
    _animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openSummary(AppStateProvider provider) {
    provider.sendOtpForUser();
    provider.getUserFundDetails();
    showPbBottomSheet<void>(
      context: context,
      builder: (_) => loanCartPopupDialog(
        onUpdate: widget.onUpdate,
        refreshData: widget.refreshData,
        onViewPortfolio: () {
          if (mounted) openShellTab(context, ShellTab.portfolio);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final cart = provider.getCurrentCart();

    if (cart.isEmpty) {
      return const SizedBox();
    }

    final total = provider.getTotalCartAmount();

    return ScaleTransition(
      scale: _scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openSummary(provider),
            child: Ink(
              height: 58,
              decoration: BoxDecoration(
                gradient: AppColors.greenGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.greenDeep.withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined,
                              color: Colors.white, size: 20),
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              gradient: AppColors.goldGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${cart.length}',
                                style: AppTextStyles.bold(10,
                                    color: AppColors.ink)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cart.length} ${cart.length == 1 ? 'loan' : 'loans'} selected',
                            style: AppTextStyles.medium(11,
                                color: Colors.white.withOpacity(0.72)),
                          ),
                          Text('₹${total.commaAddedValue()}',
                              style: AppTextStyles.semiBold(16,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    Text('Review',
                        style: AppTextStyles.semiBold(13,
                            color: AppColors.goldLight)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.goldLight, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
