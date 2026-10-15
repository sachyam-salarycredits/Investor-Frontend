import 'package:peerbridge/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class PeerBridgeLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const PeerBridgeLoader({
    Key? key,
    required this.child,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      opacity: 0.45,
      color: AppColors.scrim,
      progressIndicator: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.softShadow(0.12),
        ),
        child: const CircularProgressIndicator(
          color: AppColors.green,
          strokeWidth: 2.6,
        ),
      ),
      child: child,
    );
  }
}
