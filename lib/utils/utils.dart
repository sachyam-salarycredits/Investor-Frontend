import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'dart:ui';
import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/enums.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_information/device_information.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
// import 'package:open_file/open_file.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart'
//     as permissionHandler;
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

class Utils {
  static bool isFirstDepositVideoValidate = false;
  static double availableAmount = 0.0;
  static bool isWeb = osType() == OperatingSystem.web;
  static bool isAndroid = osType() == OperatingSystem.android;
  static bool isIos = osType() == OperatingSystem.ios;

  // Check operating system
  static OperatingSystem osType() {
    if (kIsWeb) {
      return OperatingSystem.web;
    } else {
      return Platform.isAndroid ? OperatingSystem.android : OperatingSystem.ios;
    }
  }

  static launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<String> getIpAddress() async {
    var ip = '';

    try {
      ip = await Ipify.ipv4();
    } catch (e) {
      print("failed to get ip ${e.toString()}");
    }

    if (!Utils.isWeb) {
      try {
        ip = await DeviceInformation.deviceIMEINumber;
      } catch (e) {
        print("failed to get ip ${e.toString()}");
      }
    }
    debugPrint('Ip Address is' + ip);
    return ip;
  }

  static Future<PlatformFile?> pickFile(
      {FileType fileType = FileType.custom,
      allowedExtensions = const ['png', 'jpeg', 'jpg', "pdf"]}) async {
    var result = await FilePicker.platform.pickFiles(
        allowedExtensions: allowedExtensions,
        allowCompression: true,
        type: fileType,
        allowMultiple: false,
        withData: true);

    if (result == null) return null;

    if (result.files.isEmpty) return null;

    var file = result.files.first;

    //checking the file size
    // print(file.size);
    // print("expecting file size ${2*1024*1024}");
    if (file.size == 0 || file.size > 2 * (1024 * 1024)) {
      Utils.showToast(msg: LanguageHelper.textSelectFileSize);
      return null;
    }

    return file;
  }

  static Future<void> showToast({
    required String msg,
    Color? bgColor = Colors.black,
    Color textColor = Colors.white,
  }) async {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: bgColor,
        textColor: textColor,
        fontSize: 16.0);
  }

  static Future<void> showBasicDialog(BuildContext? context, String msg) async {
    if (context == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          scrollable: true,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  msg,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'OK',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: ColorsUtil.blueColor,
                      minimumSize: Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3), // <-- Radius
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String getOrderExpiryDate() {
    final date =
        DateTime.now().add(Duration(minutes: 17)).toUtc().toIso8601String();
    // var temp = date.month;
    //
    // var month ="";
    // if(temp<10)
    //   {
    //     month="0$temp";
    //   }
    //
    // String orderExpiry = "${date.year}-$month-${date.day}T11:06:51Z";
    //
    // debugPrint(orderExpiry);
    return date;
  }

  static String getTextForDataTable(String? text) {
    if (text == null) {
      return "-";
    }

    if (text.isEmpty) return "-";

    return text;
  }

  static saveAndOpenFile(Uint8List fileData) async {
    var dir = await getApplicationDocumentsDirectory();
    var file =
        File("${dir.path}\+${DateTime.now().toIso8601String()}application.pdf");

    file.writeAsBytesSync(fileData);

    OpenFile.open(file.path);
  }

  static Future<void> showDoubleBtnAlert({
    String? title,
    required BuildContext context,
    required String msg,
    String positiveButtonTitle = "Yes",
    Function? onTap,
  }) async {
    print("dialog called");
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title == null ? "PeerBridge" : title,
            style: TextStyle(
              fontSize: 22,
              color: ColorsUtil.blueColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(positiveButtonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                if (onTap != null) onTap();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAlert(
      {required BuildContext context,
      String title = "PeerBridge",
      required String msg,
      Function? onTap,
      String buttonTitle = "ok"}) async {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              color: ColorsUtil.blueColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  msg,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(buttonTitle),
              onPressed: () {
                Navigator.of(context).pop();
                if (onTap != null) onTap();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showRatingAlert({required BuildContext context}) async {
    if (Utils.isWeb) {
      return;
    }

    var dateStr = await context.read<AppStateProvider>().getRatingDate();
    if (dateStr != '') {
      var popupDate = DateTime.parse(dateStr);
      if (DateTime.now().isBefore(popupDate)) {
        return;
      }
    }

    var currentDate = DateTime.now();
    var rateVisibleDay = 15;
    var laterVisibleDay = 3;
    var noThanksVisibleDay = 10;
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Rate PeerBridge App",
            style: TextStyle(
              fontSize: 22,
              color: ColorsUtil.blueColor,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "If you enjoy using the PeerBridge app, would you mind taking a moment to rate it? It won't take more then a minute. Thanks for your support!",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Rate PeerBridge App"),
              onPressed: () async {
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                } else {
                  inAppReview.openStoreListing();
                }

                // inAppReview.openStoreListing(
                //   //     appStoreId: Constants.appStoreId, microsoftStoreId: '');

                var newDate = new DateTime(currentDate.year, currentDate.month,
                    currentDate.day + rateVisibleDay);
                debugPrint(newDate.toString());
                context
                    .read<AppStateProvider>()
                    .setRatingDate(newDate.toIso8601String());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remind me later"),
              onPressed: () {
                //Set next popup visible date
                var newDate = new DateTime(currentDate.year, currentDate.month,
                    currentDate.day + laterVisibleDay);
                debugPrint(newDate.toString());
                context
                    .read<AppStateProvider>()
                    .setRatingDate(newDate.toIso8601String());
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("No, Thanks"),
              onPressed: () {
                //Set next popup visible date

                var newDate = new DateTime(currentDate.year, currentDate.month,
                    currentDate.day + noThanksVisibleDay);
                debugPrint(newDate.toString());
                context
                    .read<AppStateProvider>()
                    .setRatingDate(newDate.toIso8601String());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static getFormattedDate(DateTime? date) {
    if (date == null) {
      return "";
    }

    return DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).format(date);
  }

  static PlatformFile? getPlatformFile(String path) {
    if (Utils.isWeb) {
      var size = base64Decode(path.replaceAll("data:image/jpeg;base64,", ""));
      return PlatformFile(
        name: DateTime.now().millisecondsSinceEpoch.toString() + ".jpeg",
        size: size.length,
        bytes: size,
      );
    } else {
      print("asd<<<<<<<<<<<<<<");
      print(path);
      print(">>>>>>>>>>>>>>>>>>.");
      var file = File(path);
      if (file.existsSync()) {
        final size = file.readAsBytesSync();
        return PlatformFile(
          name: file.path.split("/").last,
          size: size.length,
          bytes: size,
          path: file.path,
        );
      } else {
        return null;
      }
    }
  }

  static String getLoanCategory(String? category) {
    if (category == null) {
      return "";
    }
    if (category.contains("M1") ||
        category.contains("M2") ||
        category.contains("M3")) {
      return "C";
    }
    if (category.contains("M4") ||
        category.contains("M5") ||
        category.contains("M6")) {
      return "M";
    }
    if (category.contains("M7") ||
        category.contains("M8") ||
        category.contains("M9")) {
      return "H";
    }

    return "";
  }

  static launchSupportCall() {
    launch("tel:${Constants.callSupportNumber}");
  }

  static String buildTokenJson(String token, String customerId) {
    var data = {"customerId": customerId, "token": token};
    var bytes = utf8.encode(json.encode(data));
    return base64.encode(bytes);
  }

  static getCidFromUrl(String url) {
    var dataString = utf8.decode(base64.decode(url));
    return json.decode(dataString)["customerId"];
  }

  static getTokenFromUrl(String url) {
    var dataString = utf8.decode(base64.decode(url));
    return json.decode(dataString)["token"];
  }

  static getImeiPermission() async {
    var imei = await DeviceInformation.deviceIMEINumber;
    print("imei $imei");
  }

  static Future<LocationData?> getUserLocation(BuildContext context) async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Utils.showAlert(
            context: context, msg: LanguageHelper.textLocationRequired);
        return null;
      }
    }

    _locationData = await location.getLocation();

    return _locationData;
  }

  static getCurrentGreetings() {
    var currentDate = DateTime.now();
    var currentTime = currentDate.hour.toInt();
    var greetings = "Good Morning";
    if (currentTime < 12) {
      greetings = "Good Morning";
    } else if (currentTime >= 12 && currentTime <= 15) {
      greetings = "Good Afternoon";
    } else if (currentTime >= 16) {
      greetings = "Good Evening";
    }
    return greetings;
  }

  static getOfferOnTap(String type, int? id) {
    if (type == 'quiz_list') {
      FlyyFlutterPlugin.openFlyyQuizListPage();
    } else if (type == 'invite_earn') {
      FlyyFlutterPlugin.openFlyyInviteAndEarnPage(id ?? 0);
    } else if (type == 'challenge') {
      FlyyFlutterPlugin.openFlyyChallengeDetailsPage(id ?? 0);
    } else if (type == 'game_list') {
    } else if (type == 'stamp_campaign') {
      FlyyFlutterPlugin.openFlyyStampsPage();
    } else if (type == 'raffle') {
      FlyyFlutterPlugin.openFlyyRafflePage(id ?? 0);
    } else if (type == 'leaderboard') {
      FlyyFlutterPlugin.openFlyyBonanzaPage();
    } else if (type == 'spin_wheel') {
      FlyyFlutterPlugin.openFlyySpinTheWheelPage(id ?? 0);
    }
  }

  static String currencyCompactConverter(double value) {
    return NumberFormat.compactCurrency(
      decimalDigits: 2,
      locale: 'en_IN',
      symbol: '',
    ).format(value);
  }

  static bool showSocialImpactLoans = false;
  // static launchURL(String url) async {
  //   if (Platform.isIOS) {
  //     if (await canLaunch(url)) {
  //       await launch(url, forceSafariVC: false);
  //     } else {
  //       if (await canLaunch(url)) {
  //         await launch(url);
  //       } else {
  //         throw 'Could not launch $url';
  //       }
  //     }
  //   } else {
  //     if (await canLaunch(url)) {
  //       await launch(url);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   }
}
