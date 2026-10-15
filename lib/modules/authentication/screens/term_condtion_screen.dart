import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx/webviewx.dart';

class TermWebScreen extends StatefulWidget {
  const TermWebScreen({Key? key}) : super(key: key);

  @override
  _TermWebScreenState createState() => _TermWebScreenState();
}

class _TermWebScreenState extends State<TermWebScreen> {
  late WebViewXController webViewController;
  var isLoading = ValueNotifier(true);
  final url = APIUrls.termsCondition;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    print(url);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: new Text('Terms & Condition'),
          backgroundColor: ColorsUtil.blueColor,
        ),
        body: Builder(builder: (context) {
          if (url.isEmpty) {
            return Center(
              child: Text("Something went wrong"),
            );
          }
          return Stack(
            children: [
              getWebView(size),
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

  Widget getWebView(Size size) {
    if (Utils.isWeb) {
      return WebViewX(
        height: size.height,
        width: size.width,
        initialContent: url,
        initialSourceType: SourceType.url,
        onPageStarted: (value) {
          print("started $value");
          isLoading.value = false;
        },
        onWebViewCreated: (controller) => webViewController = controller,
      );
    } else {
      return WebView(
        initialUrl: url,
        onPageStarted: (url) {
          isLoading.value = false;
        },
      );
    }
  }
}
