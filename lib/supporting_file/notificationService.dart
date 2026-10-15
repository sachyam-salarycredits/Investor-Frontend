import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static initNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static displayNotification(RemoteMessage remoteMessage) async {
    BigPictureStyleInformation? bigPictureStyleInformation;
    bool isImage = remoteMessage.data["_mediaUrl"] != null;
    var title = remoteMessage.data["title"];
    var des = remoteMessage.data["subtitle"] ?? '';
    if (remoteMessage.data["subtitle"] == null ||
        remoteMessage.data["subtitle"] == '') {
      des = remoteMessage.data["alert"] ?? "";
    }

    if (isImage) {
      final String bigPicturePath = await _downloadAndSaveFile(
          remoteMessage.data["_mediaUrl"], 'bigPicture');
      bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: des,
          htmlFormatSummaryText: true);
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('Monexo', 'PeerBridge',
            channelDescription: 'Updates on your investments',
            styleInformation: isImage ? bigPictureStyleInformation : null,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, des, platformChannelSpecifics, payload: "");
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
