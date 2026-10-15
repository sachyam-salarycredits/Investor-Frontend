import 'dart:convert';
import 'dart:typed_data';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as parser;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APICalling {
  static final REFRESH_KEY = "refresh_stamp";
  static final APICalling _apiService = APICalling._internal();

  static APICalling getApiClient(
      {required BuildContext context, bool checkSession = false}) {
    return APICalling(context, checkSession);
  }

  factory APICalling(BuildContext context, bool checkSession) {
    _apiService.context = context;
    _apiService.checkSession = checkSession;
    return _apiService;
  }

  Future<bool> checkSessionExpired(String url) async {
    if (url.contains(APIUrls.panDetails) ||
        url.contains(APIUrls.loginSendOtp)) {
      print("!!!!!!!!!!!!starting new session!!!!!!!!");
      setCurrentTimeStamp();
      return false;
    }

    print("!!!!!!!!!!!checking for session!!!!!!!!!!!!!");

    var pref = await SharedPreferences.getInstance();
    var currentTime = DateTime.now();

    var stamp = DateTime.fromMillisecondsSinceEpoch(
        await pref.getInt(REFRESH_KEY) ??
            DateTime.now().millisecondsSinceEpoch);

    if (currentTime.difference(stamp).inHours > 24) {
      return true;
    } else {
      await setCurrentTimeStamp();
      return false;
    }
  }

  setCurrentTimeStamp() async {
    var pref = await SharedPreferences.getInstance();
    await pref.setInt(REFRESH_KEY, DateTime.now().millisecondsSinceEpoch);
  }

  APICalling._internal();

  BuildContext? context;
  bool checkSession = false;
  final timeoutSeconds = 30;
  final timeoutCode = 20000;
  final microsoftLogin = 'https://login.microsoftonline.com';

  //for checking connection status
  bool _isConnected = true;
  Connectivity _connectivity = Connectivity();

  init() async {
    ///checking the connectivity status
    _isConnected =
        (await _connectivity.checkConnectivity()) != ConnectivityResult.none;

    ///adding stream for connectivity status
    _connectivity.onConnectivityChanged.listen((event) {
      print(event);
      if (event == ConnectivityResult.none)
        _isConnected = false;
      else
        _isConnected = true;
    });
  }

  log(data) {
    //prevent to loggin in release
    if (!kReleaseMode) {
      debugPrint(
          ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>START API LOG<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
      debugPrint(data.toString());
      debugPrint(
          ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>END API LOG<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n\n\n");
    }
  }

  void _applyNgrokHeaders(Map<String, String> headers, String url) {
    if (url.contains('ngrok-free.dev') || url.contains('ngrok.io')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
  }

  // final timeoutMessage = 'The connection has timed out, Please try again!';

  String getToken() {
    try {
      if (context == null) {
        return "";
      }

      if (context?.read<AppStateProvider>().token == null) {
        return "";
      }

      return 'Bearer ${context?.read<AppStateProvider>().token}';
    } catch (e) {
      return "";
    }
  }

  /// GET REQUEST ///
  Future<String> getRequest({
    required String url,
    required Map<String, String>? headers,
    bool addToken = true,
  }) async {
    if (!_isConnected) {
      log("No Internet");
      Utils.showToast(msg: LanguageHelper.textConnectToInternet);
      return "";
    }

    var finalHeader = headers;
    if (finalHeader == null) {
      finalHeader = Map<String, String>();
    }

    log("get requested url $url\n" + "header $finalHeader\n" + "");

    finalHeader['Content-Type'] = 'application/json';
    _applyNgrokHeaders(finalHeader, url);
    // finalHeader['X-Frame-Options'] = "DENY";
    // finalHeader['Content-Security-Policy'] = "frame-ancestors 'none'";

    if (addToken) { finalHeader['Authorization'] = getToken(); }

    var response = await http.get(Uri.parse(url), headers: finalHeader);

    log("requested url $url\n" +
        "header $finalHeader\n" +
        "result ${response.body}");

    if (response.statusCode == timeoutCode) {
      Utils.showBasicDialog(context, response.body);
      return response.body;
    }
    try {
      var isSessionExpired = await checkSessionExpired(url);

      if (isSessionExpired && addToken) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });
        return "";
      } else {
        setCurrentTimeStamp();
      }

      /// UnAuthorized
      if (response.statusCode == 401) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });
      }

      if (checkSession &&
          (response.statusCode == 400 || response.statusCode == 404)) {
        Utils.showToast(msg: response.body);
        return response.body;
      }
      if (response.statusCode == 200) {
        return response.body;
      } else {
        var postResponse = json.decode(response.body);
        if (postResponse.containsKey('message')) {
          Utils.showToast(msg: postResponse['message']);
          return '';
        }
        return response.body;
      }
    } catch (e) {
      log('Exception get request $e');
      return e.toString();
    }
  }

  /// POST REQUEST ////
  Future<String> postRequest({
    required String url,
    required Map<String, String>? headers,
    required parameters,
    bool isAlert = true,
    bool addToken = true,
  }) async {
    var finalHeader = headers;
    if (finalHeader == null) {
      finalHeader = Map<String, String>();
    }

    finalHeader['Content-Type'] = 'application/json';
    _applyNgrokHeaders(finalHeader, url);
    if (addToken) {
      finalHeader['Authorization'] = getToken();
    }

    if (!_isConnected) {
      log("No Internet");
      Utils.showToast(msg: LanguageHelper.textConnectToInternet);
      return "";
    }

    log("POST requested url $url\n" +
        "header $finalHeader\n" +
        "body ${parameters.toString()}\n" +
        "");
    var response = await http.post(Uri.parse(url),
        headers: finalHeader, body: json.encode(parameters));

    if (response.statusCode == timeoutCode) {
      if (isAlert && context != null)
        Utils.showAlert(
            context: context!, msg: LanguageHelper.textConnectionTimeout);
      return response.body;
    }

    log("POST requested url $url\n" +
        "header $finalHeader\n" +
        "body ${parameters.toString()}\n" +
        "result ${response.body}");

    try {
      var isSessionExpired = await checkSessionExpired(url);

      if (isSessionExpired && addToken) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });

        return "";
      }

      /// UnAuthorized
      if (response.statusCode == 401) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });
      }

      if (checkSession &&
          (response.statusCode == 400 || response.statusCode == 404)) {
        if (isAlert && context != null)
          Utils.showAlert(
              context: context!, msg: LanguageHelper.textSomethingWentWrong);
        return response.body;
      }
      if (response.statusCode == 200) {
        var apiRes = json.decode(response.body);
        if (apiRes["statusCode"] != "200" && apiRes.containsKey('message')) {
          if (isAlert && context != null)
            Utils.showAlert(context: context!, msg: apiRes["message"]);
        }
        return response.body;
      } else {
        var postResponse = json.decode(response.body);
        if (postResponse.containsKey('message')) {
          if (isAlert && context != null)
            Utils.showAlert(context: context!, msg: postResponse["message"]);
          return '';
        }
        return response.body;
      }
    } catch (e) {
      log("error on url $url error is ${e.toString()}");
      if (isAlert && context != null)
        Utils.showAlert(
            context: context!, msg: LanguageHelper.textSomethingWentWrong);
      return e.toString();
    }
  }

  /// DATA POST REQUEST ////
  Future<String> dataPostRequest({
    required String url,
    required Map<String, String>? headers,
    required Map<String, String>? parameters,
    required Map<String, String>? files,
  }) async {
    var finalHeader = headers;
    if (finalHeader == null) {
      finalHeader = Map<String, String>();
    }

    finalHeader['Content-Type'] = 'application/json';
    _applyNgrokHeaders(finalHeader, url);
    // finalHeader['X-Frame-Options'] = "DENY";
    // finalHeader['Content-Security-Policy'] = "frame-ancestors 'none'";
    finalHeader['Authorization'] = getToken();

    if (!_isConnected) {
      log("No Internet");
      Utils.showBasicDialog(context, LanguageHelper.textConnectToInternet);
      return "";
    }
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(finalHeader);
    if (parameters != null) {
      request.fields.addAll(parameters);
    }

    //adding headers to the request
    request.headers.addAll(finalHeader);
    files?.forEach((key, value) async {
      request.files.add(await http.MultipartFile.fromPath(key, value));
    });
    http.Response response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == timeoutCode) {
      Utils.showToast(msg: response.body);
      return response.body;
    }

    log("MULTIPART POST requested url $url\n" +
        "header $finalHeader\n" +
        "formData ${request.fields.toString()}\n" +
        "files ${request.files.length.toString()}\n" +
        "result ${response.body}");

    try {
      /// UnAuthorized
      if (response.statusCode == 401) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });
      }

      if (checkSession &&
          (response.statusCode == 400 || response.statusCode == 404)) {
        Utils.showToast(msg: response.body);
        return response.body;
      }
      if (response.statusCode == 200) {
        var apiRes = json.decode(response.body);
        if (apiRes["statusCode"] != "200" && apiRes.containsKey('message')) {
          Utils.showToast(msg: apiRes["message"]);
        }
        return response.body;
      } else {
        var postResponse = json.decode(response.body);
        if (postResponse.containsKey('message')) {
          Utils.showToast(msg: postResponse['message']);
          return '';
        }
        return response.body;
      }
    } catch (e) {
      log("error on url $url error is ${e.toString()}");
      return e.toString();
    }
  }

  Future<String> dataPostRequestAllPlatform({
    required String url,
    required Map<String, String>? headers,
    required Map<String, String>? parameters,
    required Map<String, PlatformFile>? files,
  }) async {
    var finalHeader = headers;
    if (finalHeader == null) {
      finalHeader = Map<String, String>();
    }

    finalHeader['Content-Type'] = 'application/json';
    _applyNgrokHeaders(finalHeader, url);
    // finalHeader['X-Frame-Options'] = "DENY";
    // finalHeader['Content-Security-Policy'] = "frame-ancestors 'none'";
    finalHeader['Authorization'] = getToken();

    if (!_isConnected) {
      log("No Internet");
      Utils.showBasicDialog(context, LanguageHelper.textConnectToInternet);
      return "";
    }
    var request = http.MultipartRequest('POST', Uri.parse(url));

    //adding headers to the request
    request.headers.addAll(finalHeader);
    if (parameters != null) {
      request.fields.addAll(parameters);
    }

    files?.forEach((key, value) async {
      // var file = http.MultipartFile.fromPath('image', "");
      request.files.add(http.MultipartFile.fromBytes(key, value.bytes!,
          filename: value.name,
          contentType: parser.MediaType("image", value.extension ?? "jpeg")));
    });
    http.Response response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == timeoutCode) {
      Utils.showToast(msg: response.body);
      return response.body;
    }

    log("MULTIPART POST requested url $url\n" +
        "header $finalHeader\n" +
        "formData ${request.fields.toString()}\n" +
        "files ${request.files.map((e) => e.filename).join(",")}\n" +
        "result ${response.body}");

    try {
      /// UnAuthorized
      if (response.statusCode == 401) {
        if (context != null)
          Utils.showAlert(
              context: context!,
              msg: LanguageHelper.textSessionExpired,
              onTap: () {
                context!.goNamed(RoutesName.LandingScreen);
              });
      }

      if (checkSession &&
          (response.statusCode == 400 || response.statusCode == 404)) {
        Utils.showToast(msg: response.body);
        return response.body;
      }
      if (response.statusCode == 200) {
        var apiRes = json.decode(response.body);
        if (apiRes["statusCode"] != "200" && apiRes.containsKey('message')) {
          Utils.showToast(msg: apiRes["message"]);
        }
        return response.body;
      } else {
        var postResponse = json.decode(response.body);
        if (postResponse.containsKey('message')) {
          Utils.showToast(msg: postResponse['message']);
          return '';
        }
        return response.body;
      }
    } catch (e) {
      log("error on url $url error is ${e.toString()}");
      return e.toString();
    }
  }
}

class FileData {
  String fileName;
  String fileType;
  Uint8List data;

  FileData(this.fileName, this.fileType, this.data);
}
