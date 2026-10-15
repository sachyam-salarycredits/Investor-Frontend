import 'dart:convert';

import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'dummy_js.dart' if (dart.library.js) 'dart:js' as js;

class HyperVerseWebDemo extends StatefulWidget {
  const HyperVerseWebDemo({Key? key}) : super(key: key);

  @override
  State<HyperVerseWebDemo> createState() => _HyperVerseWebDemoState();
}

class _HyperVerseWebDemoState extends State<HyperVerseWebDemo> {
  @override
  Widget build(BuildContext context) {
    var channel = js.context;
    return Scaffold(
      appBar: AppBar(),
      //
      // body:FutureBuilder(
      //   future: callOcr(),
      //   builder: (context,snap){
      //     if(snap.hasData)
      //       return Text(snap.data.toString());
      //     else
      //       return LinearProgressIndicator();
      //   },
      // )

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ElevatedButton(
          //     onPressed: () async {
          //       //  var data = await promiseToFuture(js.context.callMethod("runOcrPromise"));
          //
          //       channel.callMethod("runDocumentOcr", [
          //         true,
          //         (response) {
          //           print("response");
          //           print(response);
          //         },
          //         (error) {
          //           print("error");
          //           print(error);
          //         }
          //       ]);
          //     },
          //     child: Text("start doc front")),
          ElevatedButton(
              onPressed: () async {
                //  var data = await promiseToFuture(js.context.callMethod("runOcrPromise"));

                channel.callMethod("runDocumentOcr", [
                  true,
                  (response) {
                    var docImage = json.decode(response)["imgBase64"];

                    channel.callMethod("runFaceScanner", [
                      (response) {
                        print("response");

                        var faceImage = json.decode(response)["imgBase64"];

                        js.context.callMethod("matchFaceApi", [
                          faceImage,
                          docImage,
                          (response) {
                            print("response");
                            print(response);
                          },
                          (error) {
                            print("error");
                            print(error);
                          }
                        ]);

                        print(response);
                      },
                      (error) {
                        print("error");
                        print(error);
                      }
                    ]);
                  },
                  (error) {
                    print("error");
                    print(error);
                  }
                ]);
              },
              child: Text("start kyc ")),

//           ElevatedButton(
//               onPressed: () async {
//                 //  var data = await promiseToFuture(js.context.callMethod("runOcrPromise"));
//
//                 channel.callMethod("runFaceScanner", [
//                   (response) {
//                     print("response");
//                     print("""{
//     "response": {
//         "status": "success",
//         "statusCode": "200",
//         "result": {
//             "live": "yes",
//             "liveness-score": "0.9997",
//             "to-be-reviewed": "no"
//         }
//     },
//     "headers": {
//         "x-hv-request-id": "1641665883863-b654655b-d8fd-4140-a223-72ae9040f551"
//     },
//     "imgBase64": "",
//     "action": "",
//     "attemptsCount": 1
// }""");
//                     print(response);
//                   },
//                   (error) {
//                     print("error");
//                     print(error);
//                   }
//                 ]);
//               },
//               child: Text("start live face")),

          // ElevatedButton(
          //     onPressed: () async {
          //       //  var data = await promiseToFuture(js.context.callMethod("runOcrPromise"));
          //
          //       js.context.callMethod("matchFaceApi", [
          //         "",
          //         "",
          //         (response) {
          //           print("response");
          //           print(response);
          //         },
          //         (error) {
          //           print("error");
          //           print(error);
          //         }
          //       ]);
          //     },
          //     child: Text("match face api")),

          // ElevatedButton(
          //     onPressed: () async {
          //       //  var data = await promiseToFuture(js.context.callMethod("runOcrPromise"));
          //
          //       channel.callMethod("startKyc", [
          //             (response) {
          //           print(response);
          //         },
          //             (error) {
          //           print("error");
          //           print(error);
          //         }
          //       ]);
          //     },
          //     child: Text("start kyc")),

          // ElevatedButton(
          //     onPressed: () {
          //       var data = js.context.callMethod("runOCR", [true]);
          //       print(data);
          //     },
          //     child: Text("start document")),
          // ElevatedButton(
          //     onPressed: () {
          //       var data = js.context.callMethod("runLiveness");
          //       print(data);
          //     },
          //     child: Text("start face")),
          // ElevatedButton(
          //     onPressed: () {
          //     },
          //     child: Text("match face")),
        ],
      ),
    );
  }

  @override
  void initState() {
    //for generating web token for hyperverse sdk web
    generateWebToken();

    super.initState();
  }

  Future<void> generateWebToken() async {
    js.context.callMethod("init", [Constants.HYPERVISE_DEMO_TOKEN]);

    var code = await APICalling.getApiClient(context: context).postRequest(
        url: Constants.HYPERVISE_WEB_LOGIN_URL,
        headers: null,
        parameters: {
          "appId": Constants.hyperVergeAppId,
          "appKey": Constants.hyperVergeAppKey,
          "expiry": 6000
        });

    try {
      var data = json.decode(code);

      if (data["statusCode"] == "200") {
        js.context.callMethod("init", [data["result"]["token"]]);
      } else {
        debugPrint("failed to generateToken");
      }
    } catch (e) {}
  }
}
