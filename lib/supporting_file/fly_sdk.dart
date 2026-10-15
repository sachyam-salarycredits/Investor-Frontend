import 'dart:io';

import 'package:peerbridge/supporting_file/appsFlyerSdk.dart';
import 'package:peerbridge/supporting_file/notificationService.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/enums.dart';
import 'package:peerbridge/utils/global_data.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';

class FlySdk {
  //event list for onboarding
  static final PENNY_DROP_COMPLETED = "penny_drop_completed";
  static final EKYC_COMPLETED = "e_kyc_completed";
  static final FUND_TRANSFER_COMPLETED = "fund_transfer_completed";
  static final AUTO_INVEST_COMPLETED = "auto_invest_completed";
  static final SIP_COMPLETED = "sip_completed";
  static final MIP_COMPLETED = "mip_completed";

  static final FlyyDevPartnerId = '68946ae3ce3f0c438a0e';
  static final FlyyProdPartnerId = 'b87e57052869425fc249';
  static final stage = Constants.isProd ? "PRODUCTION" : "STAGE";

  static final flyy = FlyyFlutterPlugin();

  static stopProcess() {
    if (Utils.isWeb) {
      return;
    }
    flyy.clearEventListeners();
  }

  static startFlySdkProcess() {
    if (Utils.isWeb) {
      return;
    }
    flyy.on(FlyyFlutterPlugin.FLYY_ON_SDK_CLOSED_LISTENER, onFlyySdkClosed);
    flyy.on(
        FlyyFlutterPlugin.FLYY_INIT_WITH_REFERRAL_CALLBACK, onReferralSuccess);
    initFlyySdk();
    setupFirebase();
  }

  static initFlyySdk() async {
    if (Utils.isWeb) {
      return;
    }
    print("init flyyy sdk");
    // GlobalData.referralCode = "LRW6QV3";
    FlyyFlutterPlugin.setPackageName("co.peerbridge.investor");
    FlyyFlutterPlugin.setThemeColor("#01503A", "#CC9C20");

    final stage = Constants.isProd
        ? FlyyFlutterPlugin.PRODUCTION
        : FlyyFlutterPlugin.STAGE;
    final partnerId = Constants.isProd ? FlyyProdPartnerId : FlyyDevPartnerId;

    debugPrint('Flyy setup');
    var refer = await FlyyFlutterPlugin.initFlyySDKWithReferralCallback(
        partnerId, stage);
    debugPrint('refer data ${refer.toString()}');
    if (refer != null) {
      if (refer.length > 1) {
        var xReferralCode = await FlyyFlutterPlugin.getFlyyReferralCode();
        debugPrint('xReferral data ${refer.toString()}');
        var mapResult =
            await FlyyFlutterPlugin.verifyReferralCode(xReferralCode);
        debugPrint('Referral mapResult data ${refer.toString()}');
        if (mapResult["is_valid"]) {
          GlobalData.referralCode = xReferralCode;
        }
      }
    }
  }

  static loginUser(String cid, String name) async {
    if (Utils.isWeb) {
      return;
    }

    await FlyyFlutterPlugin.setFlyyUser(cid);

    FlyyFlutterPlugin.setFlyyUserName(name);
  }

  static sendEvent(String eventKey, String value) async {
    if (Utils.isWeb) {
      return;
    }
    await FlyyFlutterPlugin.sendEvent(eventKey, value);
  }

  static signUpUser(String cid) async {
    if (Utils.isWeb) {
      return;
    }
    await FlyyFlutterPlugin.setFlyyNewUser(cid);
    // await FlyyFlutterPlugin.setFlyyNewUserWithSegment(cid, Constants.segmentID);
  }

  static void onFlyySdkClosed(String response) {
    if (Utils.isWeb) {
      return;
    }
    if (response != null) {
      getWalletBalance();
    }
  }

  static void onReferralSuccess(String referralData) {
    if (Utils.isWeb) {
      return;
    }
    if (referralData != null) {
      FlyyFlutterPlugin.verifyReferralCode(referralData);
    }
  }

  static getWalletBalance() async {
    if (Utils.isWeb) {
      return;
    }
    try {
      Map<String, dynamic> mapShareData =
          await FlyyFlutterPlugin.getWalletBalance("<your_currency>");

      //To get result
      print(mapShareData["balance"]);
      print(mapShareData["total_credit"]);
      print(mapShareData["total_debit"]);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // NotificationService.displayNotification(message);
    if (Platform.isAndroid) {
      handleAndroidNotification(message);
    } else if (Platform.isIOS) {
      handleiOSNotification(message);
    }
  }

  static setupFirebase() async {
    if (Utils.isWeb) {
      return;
    }
    await Firebase.initializeApp();
    // Code added to display user authorization for notifications

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    //   print('User granted permission');
    // } else if (settings.authorizationStatus ==
    //     AuthorizationStatus.provisional) {
    //   print('User granted provisional permission');
    // } else {
    //   print('User declined or has not accepted permission');
    // }

    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      print("FCM TOKEN :- $value");
      if (value != null) {
        AFSdk.updateUninstallToken(value);
      }
      //send fcm token to server only for ios
      FlyyFlutterPlugin.sendFCMTokenToServer(value!);
    });

    //adding firebase meesaging habdler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    //comes here when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      print("message received");
      print(remoteMessage.data);

      if (Platform.isAndroid) {
        handleAndroidNotification(remoteMessage);
      } else if (Platform.isIOS) {
        handleiOSNotification(remoteMessage);
      }
    });

    //comes here when clicked from notification bar
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      print('Message clicked!');
      if (Platform.isAndroid) {
        //do nothing for android
      } else if (Platform.isIOS) {
        handleiOSNotification(remoteMessage);
      }
    });
  }

  //handle flyy android notifications
  static handleAndroidNotification(RemoteMessage remoteMessage) {
    if (Utils.isWeb) {
      return;
    }

    try {
      // print('background message ${remoteMessage.notification!.body}');
      if (remoteMessage.data.containsKey("notification_source") &&
          remoteMessage.data["notification_source"] != null &&
          remoteMessage.data["notification_source"] == "flyy_sdk") {
        FlyyFlutterPlugin.handleNotification(remoteMessage.data);
      } else if (remoteMessage.data["title"] != null ||
          remoteMessage.data["subtitle"] != null) {
        NotificationService.displayNotification(remoteMessage);
      }
    } catch (e) {
      print('Fly_SDK_Init_Null_Message_Error: $e');
      // Commented below code to handle empty notification issue when installed app first time in Android
      // NotificationService.displayNotification(remoteMessage);
    }
  }

  //handle flyy ios notifications
  static handleiOSNotification(RemoteMessage remoteMessage) {
    if (Utils.isWeb) {
      return;
    }
    // print('background message ${remoteMessage.notification!.body}');
    if (remoteMessage.data.containsKey("notification_source") &&
        remoteMessage.data["notification_source"] != null &&
        remoteMessage.data["notification_source"] == "flyy_sdk") {
      FlyyFlutterPlugin.handleForegroundNotification(remoteMessage.data);
    }
  }
}
