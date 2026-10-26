import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/utils/tpv_utils.dart';
import 'package:peerbridge/widgets/pb/pb.dart';
import 'package:flutter/material.dart';

class TpvRegisteredBankBanner extends StatelessWidget {
  const TpvRegisteredBankBanner({
    Key? key,
    required this.bankName,
    required this.accountNumber,
    this.upiId,
  }) : super(key: key);

  final String bankName;
  final String accountNumber;
  final String? upiId;

  @override
  Widget build(BuildContext context) {
    final masked = TpvUtils.maskAccountNumber(accountNumber);
    final bankLabel = bankName.trim().isEmpty ? 'Registered bank' : bankName.trim();
    final upi = upiId?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageHelper.textTpvRegisteredBankTitle,
            style: AppTextStyles.semiBold(13, color: AppColors.greenDeep),
          ),
          const SizedBox(height: 6),
          Text(
            '$bankLabel • $masked',
            style: AppTextStyles.medium(14),
          ),
          const SizedBox(height: 4),
          Text(
            LanguageHelper.textTpvRegisteredBankBody,
            style: AppTextStyles.regular(12, color: AppColors.muted)
                .copyWith(height: 1.35),
          ),
          if (upi != null && upi.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${LanguageHelper.textTpvRegisteredUpi}: $upi',
              style: AppTextStyles.medium(12, color: AppColors.ink),
            ),
          ],
        ],
      ),
    );
  }
}
