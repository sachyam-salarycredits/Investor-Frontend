import 'dart:convert';

import 'package:peerbridge/supporting_file/hyperverge_api.dart';
import 'package:flutter/foundation.dart';
import 'dummy_js.dart' if (dart.library.js) 'package:js/js.dart';
import 'dummy_js.dart' if (dart.library.js) 'package:js/js_util.dart';

Future<HyperVerseWebData?> runOcr(bool isFront) async {
  var data = await promiseToFuture(_runOcrFutureJs(isFront));

  try {
    var result = json.decode(data);
    List docData = result["response"]["result"];
    if (docData.isNotEmpty) {
      return HyperVerseWebData(result["imgBase64"], docData.first);
    } else {
      debugPrint("i am found error");
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

Future<FaceDetails?> runFaceScanner() async {
  var data = await promiseToFuture(_runFaceFutureJs());

  try {
    var result = json.decode(data);
    var faceDetails = FaceDetails(
        live: result["response"]["result"]["live"],
        livenessScore: result["response"]["result"]["liveness-score"],
        faceUri: result["imgBase64"]);
    return faceDetails;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<int?> runFaceMatch(String faceUri, String docUri) async {
  var response = await promiseToFuture(_runFaceMatchFutureJs(faceUri, docUri));

  var data = json.decode(response);
  try {
    var result = {
      "match-score": data["response"]["result"]["match-score"],
      "conf": data["response"]["result"]["conf"],
      "match": data["response"]["result"]["match"]
    };
    if (result["match"] == "yes") {
      return result["match-score"];
    } else {
      return null;
    }
  } catch (e) {
    debugPrint(response);
    debugPrint(e.toString());
    return null;
  }
}

@JS("init")
external init(String token);

@JS("runOcrFuture")
external dynamic _runOcrFutureJs(bool isFront);

@JS("runFaceFuture")
external dynamic _runFaceFutureJs();

@JS("runFaceMatchApiFuture")
external dynamic _runFaceMatchFutureJs(String faceUri, String docUri);

class HyperVerseWebData {
  String image;
  Map data;

  HyperVerseWebData(this.image, this.data);
}
