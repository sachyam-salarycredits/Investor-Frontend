import 'package:peerbridge/theme/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/app_router.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //checking for app update
      Future.delayed(Duration(seconds: 7)).then((value) {
        context.read<AppStateProvider>().checkForAppUpdate(context);
      });
      checkUserLogged();
      //asking for permission

      if (!Utils.isWeb) Utils.getImeiPermission();
    });

    initFirebase();
    getYoutubeVideos();
  }

  Future<void> getYoutubeVideos() async {
    await context.read<AppStateProvider>().getVideosData();
  }

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> checkUserLogged() async {
    await context.read<AppStateProvider>().getUserState();
    if (Utils.isWeb) {
      context.moveInitialPage();
    } else {
      var pref = await SharedPreferences.getInstance();
      var showOnbaordingStatus = await pref.getBool('show_onboarding') ?? true;
      print('showonboarding:$showOnbaordingStatus');
      if (showOnbaordingStatus) {
        context.goNamed(RoutesName.LandingScreen);
      } else {
        context.goNamed(RoutesName.Login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //uploading context to other pages
    context.read<AppStateProvider>().context = context;
    return Scaffold(
      // appBar: AppBar(
      //   actions: [IconButton(onPressed: (){
      //     Utils.showAlert(context: context, msg: "msg");
      //
      //     //context.pushNamed(RoutesName.Dialog);
      //
      //   }, icon: Icon(Icons.eleven_mp))],
      // ),
      backgroundColor: AppColors.surface,
      body: Center(
        child: Container(
          color: AppColors.surface,
          child: Image(
            height: 52,
            width: 280,
            image: AssetImage(LocalImages.peerbridge_logo),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
