import 'dart:convert';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/onboardingSteps/models/cashfree_response.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/web_payment.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/enums.dart';

class CashFreeParams {
  String orderID;
  String orderAmount;
  String? paymentSessionId;
  String? orderToken;
  String tokenData;
  String customerName;
  String customerPhone;
  String customerEmail;
  String? paymentCode;
  String? upiID;
  String? paymentLink;

  CashFreeParams({
    required this.orderID,
    required this.orderAmount,
    required this.tokenData,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    this.paymentSessionId,
    this.orderToken,
    this.paymentCode = '',
    this.upiID = '',
  });

  String get sessionId =>
      (paymentSessionId?.isNotEmpty == true
          ? paymentSessionId
          : orderToken) ??
      '';
}

class PaymentOptions {
  String typeLabel;
  PaymentType type;

  PaymentOptions({
    required this.type,
    required this.typeLabel,
  });
}

class CashFreeApi {
  static String currency = 'INR';
  static String stage = Constants.isProd ? "PROD" : "TEST";

  static var paymentTypes = <PaymentOptions>[
    PaymentOptions(type: PaymentType.upi, typeLabel: 'UPI'),
    PaymentOptions(type: PaymentType.netBanking, typeLabel: 'Internet Banking'),
  ];

  static Future<bool> doNetBankingPayment(CashFreeParams params) async {
    debugPrint('LOCAL MODE: Cashfree native SDK disabled');
    Utils.showToast(msg: 'Payments disabled in local dev mode');
    return false;
  }

  static Future<bool> doUpiPayment(CashFreeParams params) async {
    debugPrint('LOCAL MODE: Cashfree native SDK disabled');
    Utils.showToast(msg: 'Payments disabled in local dev mode');
    return false;
  }
}

class CashFreeApiWeb {
  static const String apiVersion = '2025-01-01';

  static final cashFreeBaseUrl = Constants.isProd
      ? "https://api.cashfree.com/pg"
      : "https://sandbox.cashfree.com/pg";
  static final paySessionsUrl = "$cashFreeBaseUrl/orders/sessions";

  static var paymentTypes = <PaymentOptions>[
    PaymentOptions(type: PaymentType.upi, typeLabel: 'UPI'),
    PaymentOptions(type: PaymentType.netBanking, typeLabel: 'Internet Banking'),
  ];

  static Map<String, String> _clientEnvironmentHeaders() {
    final device = Utils.isWeb ? 'desktop' : 'mobile';
    final os = Utils.isAndroid
        ? 'android'
        : Utils.isIos
            ? 'ios'
            : 'others';
    final rendering = Utils.isWeb ? 'mweb' : 'webview';
    const browser = 'chrome';

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-version': apiVersion,
      'x-client-device': device,
      'x-client-os': os,
      'x-client-browser': browser,
    };
    if (device == 'mobile') {
      headers['x-client-rendering-type'] = rendering;
    }
    return headers;
  }

  static Future<Map<String, dynamic>?> _postOrderSessions(
      Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(paySessionsUrl),
        headers: _clientEnvironmentHeaders(),
        body: json.encode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      debugPrint(
          'Cashfree /orders/sessions failed: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('Cashfree /orders/sessions error: $e');
    }
    return null;
  }

  static void _openPaymentScreen(
    BuildContext context,
    CashFreeParams params,
    String amount,
    Map<String, dynamic> result,
  ) {
    final response = CashFreeResponse.fromJson(result);
    response.orderId = params.orderID;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentWebScreen(
          cashFreeResponse: response,
          amount: amount,
        ),
      ),
    );
  }

  static Future<void> doNetBankingPayment(
      CashFreeParams params, BuildContext context, String amount) async {
    final sessionId = params.sessionId;
    if (sessionId.isEmpty) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textSomethingWentWrong);
      return;
    }

    final bankCode = int.tryParse(params.paymentCode ?? '') ?? 0;
    if (bankCode <= 0) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textNetBankingUnavailable);
      return;
    }

    final body = {
      'payment_session_id': sessionId,
      'payment_method': {
        'netbanking': {
          'channel': 'link',
          'netbanking_bank_code': bankCode,
        }
      }
    };

    final result = await _postOrderSessions(body);
    if (result != null && context.mounted) {
      _openPaymentScreen(context, params, amount, result);
    } else if (context.mounted) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textSomethingWentWrong);
    }
  }

  static Future<void> doUpiPayment(
      CashFreeParams params, BuildContext context, String amount) async {
    final sessionId = params.sessionId;
    if (sessionId.isEmpty) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textSomethingWentWrong);
      return;
    }

    // TPV: use collect only for profile-linked UPI; otherwise link/intent so the
    // payer uses a UPI app tied to the registered bank account on the order.
    final upiId = (params.upiID ?? '').trim();
    final upiChannel = upiId.isNotEmpty ? 'collect' : 'link';
    final upiBody = <String, dynamic>{'channel': upiChannel};
    if (upiId.isNotEmpty) {
      upiBody['upi_id'] = upiId;
    }

    final body = {
      'payment_session_id': sessionId,
      'payment_method': {
        'upi': upiBody,
      }
    };

    final result = await _postOrderSessions(body);
    if (result != null && context.mounted) {
      _openPaymentScreen(context, params, amount, result);
    } else if (context.mounted) {
      Utils.showAlert(
          context: context, msg: LanguageHelper.textSomethingWentWrong);
    }
  }
}
