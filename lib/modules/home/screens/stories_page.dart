import 'dart:async';

import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

// import 'main.dart';

class StoriesPage extends StatefulWidget {
  final String storyUrl;
  final String thumbNailUrl;
  final String title;
  final String type;
  final int? id;

  const StoriesPage(
      {Key? key,
      required this.storyUrl,
      required this.title,
      required this.thumbNailUrl,
      required this.id,
      required this.type})
      : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>
    with TickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.2),
        body: Container(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Utils.getOfferOnTap(widget.type, widget.id);
                },
                child: Center(
                    child: Image.network(widget.storyUrl.isEmpty
                        ? widget.thumbNailUrl
                        : widget.storyUrl)),
              ),
              Positioned(
                top: 40,
                left: 15,
                right: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.network(widget.thumbNailUrl),
                        )),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                        child: Text(
                      widget.title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0,
                          fontFamily: CustomFonts.nunito,
                          color: Colors.white),
                    )),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
