import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/tpv_utils.dart';
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
        color: ColorsUtil.blueColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsUtil.blueColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageHelper.textTpvRegisteredBankTitle,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ColorsUtil.blueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$bankLabel • $masked',
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LanguageHelper.textTpvRegisteredBankBody,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 12,
              height: 1.35,
              color: ColorsUtil.black.withOpacity(0.72),
            ),
          ),
          if (upi != null && upi.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${LanguageHelper.textTpvRegisteredUpi}: $upi',
              style: TextStyle(
                fontFamily: CustomFonts.nunito,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
