import 'dart:io';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/webviewx.dart';
import 'package:go_router/go_router.dart';

import '../../../supporting_file/appsFlyerSdk.dart';

class SipWebView extends StatefulWidget {
  final String url;
  final String returnUrl;
  final String amount;

  const SipWebView({
    Key? key,
    required this.url,
    required this.returnUrl,
    required this.amount,
  }) : super(key: key);

  @override
  _SipWebViewState createState() => _SipWebViewState();
}

class _SipWebViewState extends State<SipWebView> {
  late WebViewXController webViewController;

  var sourceId = '';

  var isLoading = ValueNotifier(true);

  @override
  void initState() {
    if (Utils.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  /// Get Sip details
  Future<void> getSipDetails() async {
    if (sourceId == '') {
      return;
    }
    // setLoading(true);
    // sleep(const Duration(seconds: 3));
    final provider = context.read<AppStateProvider>();
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = provider.customerId;
    param[ApiParams.sourceId] = sourceId;
    var sipDetail = await context.read<AppStateProvider>().getSipDetails(param);
    // setLoading(false);

    if (sipDetail != null) {
      var value = Map<String, dynamic>();
      value["af_revenue"] = widget.amount.doubleValue().ceil();
      value["af_currency"] = "INR";
      // AFSdk.logEvent(AFSdk.af_sip, value);

      Utils.showAlert(
          context: context,
          msg: sipDetail.status == 'submitted'
              ? LanguageHelper.textSipCreatedSuccessfully
              : sipDetail.redirect?.response?.mndtAccptResp?.undrlygAccptncDtls
                      ?.accptncRslt?.rjctRsn?.reasonDesc ??
                  LanguageHelper.textSipEmandatePending,
          onTap: () async {
            await context.read<AppStateProvider>().getCustomerDetails();
            context.pop();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final url = widget.url;
    print(url);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: new Text('E-Mandate'),
          backgroundColor: ColorsUtil.blueColor,
        ),
        body: Builder(builder: (context) {
          if (widget.url.isEmpty) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          return Stack(
            children: [
              WebViewX(
                onPageFinished: (url) {
                  print("finished $url");
                },
                height: size.height,
                width: size.width,
                initialContent: url,
                // javascriptMode: JavascriptMode.unrestricted,
                initialSourceType: SourceType.url,
                onPageStarted: (value) {
                  print("started $value");
                  isLoading.value = false;

                  if (value.contains(widget.returnUrl)) {
                    final uri = Uri.dataFromString(value);
                    final id = uri.queryParameters['source_id'];
                    if (id != null) {
                      sourceId = id;
                      getSipDetails();
                    }
                  }
                },
                onWebViewCreated: (controller) =>
                    webViewController = controller,
              ),
              WebViewAware(
                child: ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, loading, child) {
                    if (loading) {
                      return Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
