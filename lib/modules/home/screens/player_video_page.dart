import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../utils/images.dart';

class PlayerVideoPage extends StatefulWidget {
  final String videoURL;
  final bool showNextButton;
  final String type;
  final int? id;
  bool? validateWatchTime;
  PlayerVideoPage({Key? key, required this.videoURL, this.validateWatchTime, this.showNextButton = false, this.id = 0, this.type = ''})
      : super(key: key);

  @override
  _PlayerVideoPage createState() => _PlayerVideoPage();
}

class _PlayerVideoPage extends State<PlayerVideoPage> {
  bool _isLoading = false;
  late YoutubePlayerController controller;
  bool isValidated = false;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoURL);
    controller = YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: true,
          loop: true,
          isLive: false,
          forceHD: false,
          enableCaption: false,
          showLiveFullscreenButton: false,
          controlsVisibleAtStart: false,
          hideThumbnail: true
        ));
  }

  void listener() {
    if (controller.value.position.inSeconds > 10) {
      Utils.isFirstDepositVideoValidate = true;
    }
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  child: Container(
                    alignment: Alignment.center,
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: controller,
                        showVideoProgressIndicator: true,
                        onReady: () {
                          if (widget.validateWatchTime ?? false) {
                            controller.addListener(listener);
                          }
                        },
                      ),
                      builder: (context, player) => Stack(
                        fit: StackFit.expand,
                        children: [player],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Image(
                        image: AssetImage(LocalImages.close),
                        width: 20,
                        height: 20,
                      )),
                ),
                Visibility(
                  visible: widget.showNextButton,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                                'Open',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
