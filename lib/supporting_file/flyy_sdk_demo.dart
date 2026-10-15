import 'dart:io';

import 'package:peerbridge/supporting_file/fly_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';

class FlyySdkDemo extends StatefulWidget {


  const FlyySdkDemo({Key? key}) : super(key: key);

  @override
  _FlyySdkDemoState createState() => _FlyySdkDemoState();
}

class _FlyySdkDemoState extends State<FlyySdkDemo> {
  @override
  void initState() {

    super.initState();


   // initFlySdk();


   // FlySdk.startFlySdkProcess();
  }

  void initFlySdk(){
    FlyyFlutterPlugin.setPackageName("co.peerbridge.investor");

    FlyyFlutterPlugin.initFlyySDK(
        "68946ae3ce3f0c438a0e", FlyyFlutterPlugin.STAGE);
   // FlyyFlutterPlugin.setThemeColor("#2A9134", "#2A9134");
    FlyyFlutterPlugin.setFlyyUser("lander_sachin29021995").then((value) {
      FlyyFlutterPlugin.setFlyyUserName("Lender-Sachin");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                FlySdk.setupFirebase();
              },
              child: Text("init firebase")),
          ElevatedButton(
              onPressed: () {
                FlySdk.startFlySdkProcess();
              },
              child: Text("init sdk")),

          ElevatedButton(
              onPressed: () {
                FlyyFlutterPlugin.openFlyyOffersPage();
              },
              child: Text("open Offers")),
          // ElevatedButton(
          //     onPressed: () {
          //       FlyyFlutterPlugin.openFlyyGiftCardsPage();
          //     },
          //     child: Text("open gifts")),
          // ElevatedButton(
          //     onPressed: () {
          //       FlyyFlutterPlugin.openFlyyQuizListPage();
          //     },
          //     child: Text("open quiz")),
        ],
      ),
    );
  }
}

class DemoWidget extends StatefulWidget {
  const DemoWidget({Key? key}) : super(key: key);

  @override
  _DemoWidgetState createState() => _DemoWidgetState();
}

class _DemoWidgetState extends State<DemoWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FlySdk.startFlySdkProcess();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            child: Text("init flyy"),
            onPressed: () {
              FlySdk.startFlySdkProcess();
            },
          ),
        ),
      ),
    );
  }
}
