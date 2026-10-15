import 'dart:convert';
import 'dart:io';
import 'package:peerbridge/language/language_en.dart';
import 'package:http/http.dart' as http;

import 'package:peerbridge/supporting_file/hyperverse_web_sdk.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';

class HyperVergeData {
  String frontUri;
  String backUri;
  FaceDetails? faceDetails;

  HyperVergeData({
    required this.frontUri,
    required this.backUri,
    required this.faceDetails,
  });
}

class FaceDetails {
  String live;
  String livenessScore;
  String faceUri;

  FaceDetails({
    required this.live,
    required this.livenessScore,
    required this.faceUri,
  });
}

class HyperVergeSession {
  static var name = 'name';
  static var gender = 'gender';
  static var dob = 'dob';
  static var aadhaar = 'aadhaar';
  static var yob = 'yob';
  static var address = 'address';
  static var pin = 'pin';

  static Map? adhaarFront, adhaarBack;

  static Future<HyperVergeData?> startKYC() async {
    if (!Utils.isWeb) {
      Utils.showToast(msg: 'KYC disabled in local dev mode');
      return null;
    }

    var frontUri;
    adhaarFront = null;
    adhaarBack = null;

    var output = await runOcr(true);
    if (output != null) {
      frontUri = output.image;
      adhaarFront = output.data;
    }

    if (frontUri == null) {
      Utils.showToast(msg: LanguageHelper.textNeedToScanFrontDocAgain);
      return null;
    }
    debugPrint('Front uri done');
    var backUri;

    output = await runOcr(false);
    if (output != null) {
      backUri = output.image;
      adhaarBack = output.data;
    }

    if (backUri == null) {
      Utils.showToast(msg: LanguageHelper.textNeedToScanFrontBackAgain);
      return null;
    }
    debugPrint('Back uri done');
    var faceDetails = await runFaceScanner();
    if (faceDetails == null) {
      Utils.showToast(msg: LanguageHelper.textNeedToScanFaceAgain);
      return null;
    }
    debugPrint('Face uri done');

    return HyperVergeData(
        frontUri: frontUri, backUri: backUri, faceDetails: faceDetails);
  }

  static Future<String?> openDocumentCaptureScreen(bool isFront) async {
    Utils.showToast(msg: 'KYC disabled in local dev mode');
    return null;
  }

  static Future<FaceDetails?> openFaceCaptureScreen() async {
    Utils.showToast(msg: 'KYC disabled in local dev mode');
    return null;
  }

  static Future<int?> callFaceMatchApi(faceUri, documentUriFront) async {
    Utils.showToast(msg: 'KYC disabled in local dev mode');
    return null;
  }

  static Future<Map?> callOCRApi(docUri, isFront) async {
    if (Utils.isWeb) {
      return getAadharDetails(
          isFront ? adhaarFront as Map : adhaarBack as Map, isFront);
    }

    Utils.showToast(msg: 'KYC disabled in local dev mode');
    return null;
  }

  static Future<String?> generateWebTokenHyperverse(
      BuildContext context) async {
    var code = await http.post(Uri.parse(APIUrls.hyperverseToken),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader:
              APICalling.getApiClient(context: context).getToken(),
        },
        body: json.encode({
          "appId": Constants.hyperVergeAppId,
          "appKey": Constants.hyperVergeAppKey,
          "expiry": 18000
        }));

    var data = json.decode(code.body);

    print(data);
    var token = data["result"]["token"];
    return token;
  }

  static Map? getAadharDetails(aadharDetail, isFront) {
    if (!aadharDetail.containsKey('details')) {
      return null;
    }
    var aadharMap = Map<String, String>();
    var details = aadharDetail['details'];
    if (isFront) {
      if (details.containsKey(name)) {
        aadharMap[name] = details[name]['value'];
      }
      if (details.containsKey(gender)) {
        aadharMap[gender] = details[gender]['value'];
      }
      if (details.containsKey(dob) && details[dob]['value'] != null) {
        aadharMap[dob] = details[dob]['value'];
      } else if (details.containsKey(yob) && details[yob]['value'] != null) {
        aadharMap[dob] = details[yob]['value'];
      }
      if (details.containsKey(aadhaar)) {
        aadharMap[aadhaar] = details[aadhaar]['value'];
      }
    } else {
      if (details.containsKey(address)) {
        aadharMap[address] = details[address]['value'];
      }
      if (details.containsKey(pin)) {
        aadharMap[pin] = details[pin]['value'];
      }
    }
    return aadharMap;
  }
}
