import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/cupertino.dart';

import '../utils/enums.dart';

class AFSdk {
  static final devKey = "fhtyehx3ft4GLrb97RDqUU";
  static final androidAppId = "co.peerbridge.investor";
  static final iosAppId = "1614462026";

  //MARK:- Custom event
  static final af_login = "af_login";
  static final af_register = "af_register";
  static final af_validateAccount = "af_validateAccount";
  // static final af_fundTransfer = "af_fundTransfer";
  static final af_ekyc = "af_ekyc";
  static final af_autoInvest = "af_autoInvest";
  static final af_sip = "af_sip";
  static final af_mip = "af_mip";
  static final af_nominee = "af_nominee";
  static final af_redemption = "af_redemption";
  static final af_withdrawal = "af_withdrawal";
  static final af_manualFunding = "af_manualFunding";

  static AppsflyerSdk? appsflyerSdk;
  static String appFlyId = '';

  static Future<void> initSdk() async {
    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
        afDevKey: devKey,
        appId: Utils.isAndroid ? androidAppId : iosAppId,
        showDebug: Constants.isProd,
        timeToWaitForATTUserAuthorization: 50);

    appsflyerSdk = await AppsflyerSdk(appsFlyerOptions);

    appsflyerSdk?.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: false);

    debugPrint('Apps Flyer sdk ${appsflyerSdk.toString()}');
  }

  static void setUser(String cid) {
    appsflyerSdk?.setCustomerUserId(cid);
  }

  /// Resolves and caches AppsFlyer UID. Returns empty string if unavailable.
  static Future<String> ensureAppsFlyerId() async {
    if (appFlyId.isNotEmpty) {
      return appFlyId;
    }
    try {
      final id = await appsflyerSdk?.getAppsFlyerUID();
      appFlyId = id ?? '';
      if (appFlyId.isNotEmpty) {
        print("AppsFlyer ID: $appFlyId");
      }
    } catch (_) {}
    return appFlyId;
  }

  static Future<bool?> logEvent(String eventName, Map? eventValues) async {
    bool? result;
    try {
      result = await appsflyerSdk?.logEvent(eventName, eventValues);
      if (eventName == AFSdk.af_login || eventName == AFSdk.af_register) {
        await ensureAppsFlyerId();
      }
    } on Exception catch (e) {}
    print("Event name ${eventName} with status: ${result.toString()}");
  }

  static void updateUninstallToken(String token) {
    appsflyerSdk?.updateServerUninstallToken(token);
    print("AppsFlyer Uninstall token updated: $token}");
  }
}
