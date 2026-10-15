import 'dart:async';
import 'dart:convert';

import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/supporting_file/web_utils.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/webviewx.dart';

class DigilockerResult {
  final bool success;
  final String message;

  DigilockerResult({required this.success, this.message = ''});
}

/// Cashfree DigiLocker Aadhaar verification flow:
/// create-url (server resumes from DB) -> WebView consent -> poll -> complete.
class DigilockerKycSession {
  static Future<Map<String, dynamic>?> _createUrl(BuildContext context) async {
    final apiClient = APICalling.getApiClient(context: context);
    final customerId = context.read<AppStateProvider>().customerId;
    final body = await apiClient.postRequest(
      url: APIUrls.kycDigilockerCreateUrl,
      headers: null,
      parameters: {'customerId': customerId},
      isAlert: false,
    );
    return _dataOrNull(body);
  }

  static Future<String?> _pollStatus(
    BuildContext context,
    String verificationId,
  ) async {
    final apiClient = APICalling.getApiClient(context: context);
    final customerId = context.read<AppStateProvider>().customerId;
    final body = await apiClient.getRequest(
      url:
          '${APIUrls.kycDigilockerStatus}?customerId=$customerId&verificationId=$verificationId',
      headers: null,
    );
    final data = _dataOrNull(body);
    return data?['status']?.toString();
  }

  static Future<DigilockerResult> _complete(
    BuildContext context,
    String verificationId,
    String ip,
  ) async {
    final apiClient = APICalling.getApiClient(context: context);
    final customerId = context.read<AppStateProvider>().customerId;
    final body = await apiClient.postRequest(
      url: APIUrls.kycDigilockerComplete,
      headers: null,
      parameters: {
        'customerId': customerId,
        'verificationId': verificationId,
        'ip': ip,
      },
      isAlert: false,
    );
    if (body.isEmpty) {
      return DigilockerResult(success: false);
    }
    try {
      final decoded = json.decode(body);
      return DigilockerResult(
        success: decoded['statusCode'] == '200',
        message: decoded['message']?.toString() ?? '',
      );
    } catch (_) {
      return DigilockerResult(success: false);
    }
  }

  static Map<String, dynamic>? _dataOrNull(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = json.decode(body);
      if (decoded['statusCode'] == '200' && decoded['data'] != null) {
        return Map<String, dynamic>.from(decoded['data']);
      }
    } catch (_) {}
    return null;
  }

  /// Runs the full DigiLocker flow. Returns the final result, or null when
  /// the flow could not be started (caller should offer the OCR fallback).
  static Future<DigilockerResult?> runFlow(
    BuildContext context, {
    String ip = '',
  }) async {
    final created = await _createUrl(context);
    if (created == null ||
        created['digilockerUrl'] == null ||
        created['verificationId'] == null) {
      return null;
    }

    final verificationId = created['verificationId'].toString();
    final url = created['digilockerUrl'].toString();
    final initialStatus =
        created['status']?.toString().toUpperCase() ?? 'PENDING';

    String? status = initialStatus;
    if (status != 'AUTHENTICATED') {
      status = await Navigator.of(context, rootNavigator: true).push<String>(
        MaterialPageRoute(
          builder: (_) => DigilockerWebScreen(
            consentUrl: url,
            verificationId: verificationId,
          ),
        ),
      );
    }

    if (status != 'AUTHENTICATED') {
      return DigilockerResult(
        success: false,
        message: status == 'CONSENT_DENIED'
            ? 'DigiLocker consent was denied.'
            : status == 'EXPIRED'
                ? 'DigiLocker session expired. Please try again.'
                : 'DigiLocker verification was not completed.',
      );
    }

    return _complete(context, verificationId, ip);
  }
}

/// Opens the DigiLocker consent URL and polls the backend until the
/// verification reaches a terminal state. Pops with the final status string.
class DigilockerWebScreen extends StatefulWidget {
  final String consentUrl;
  final String verificationId;

  const DigilockerWebScreen({
    Key? key,
    required this.consentUrl,
    required this.verificationId,
  }) : super(key: key);

  @override
  _DigilockerWebScreenState createState() => _DigilockerWebScreenState();
}

class _DigilockerWebScreenState extends State<DigilockerWebScreen> {
  static const terminalStatuses = {
    'AUTHENTICATED',
    'EXPIRED',
    'CONSENT_DENIED',
    'FAILED',
    'INVALID',
  };

  Timer? timer;
  bool popped = false;

  @override
  void initState() {
    if (Utils.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();

    if (Utils.isWeb) {
      openWebWindow(widget.consentUrl);
    }

    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkStatus());
  }

  Future<void> checkStatus() async {
    final status =
        await DigilockerKycSession._pollStatus(context, widget.verificationId);
    if (status != null && terminalStatuses.contains(status)) {
      finish(status);
    }
  }

  void finish(String status) {
    if (popped) return;
    popped = true;
    timer?.cancel();
    if (Utils.isWeb) closeWindow();
    Navigator.of(context).pop(status);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiLocker Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => finish('CANCELLED'),
        ),
      ),
      body: Utils.isWeb
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Complete the DigiLocker verification in the opened window. '
                  'This screen will update automatically.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : WebViewX(
              height: size.height,
              width: size.width,
              initialContent: widget.consentUrl,
              initialSourceType: SourceType.url,
              webSpecificParams: WebSpecificParams(
                webAllowFullscreenContent: true,
                additionalSandboxOptions: [
                  'allow-forms',
                  'allow-scripts',
                  'allow-top-navigation',
                ],
              ),
              onWebViewCreated: (_) {},
            ),
    );
  }
}
