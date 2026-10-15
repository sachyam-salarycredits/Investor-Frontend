import 'dart:io';

import 'package:peerbridge/modules/onboardingSteps/models/steps_data.dart';
import 'package:peerbridge/modules/profile/widgets/logoWidget.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/modules/marketplace/screens/redemption_screen.dart';
import 'package:peerbridge/modules/onboardingSteps/screens/whats_next_screen.dart';
import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/modules/onboardingSteps/widgets/whats_next_widget.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/profile_end_nav_bar.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'nav_bar_widget.dart';

class Header extends StatelessWidget {
  bool isBackBtnVisible;
  bool isLogoVisible;
  bool isDownloadBarVisible;
  bool isMenuVisible;
  bool isReload;
  bool isLogout;
  VoidCallback? backOnPressed;
  VoidCallback? backOnPressedMarket;
  VoidCallback? menuOnPressed;

  Header({
    Key? key,
    this.isBackBtnVisible = true,
    this.isLogoVisible = true,
    this.isMenuVisible = false,
    this.isDownloadBarVisible = false,
    this.isReload = false,
    this.isLogout = false,
    this.backOnPressed,
    this.backOnPressedMarket,
    this.menuOnPressed,
  }) : super(key: key);

  Widget getLeading() {
    if (isBackBtnVisible) {
      return IconButton(
        icon: Icon(Icons.keyboard_backspace),
        onPressed: backOnPressed,
      );
    } else if (isReload) {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_backspace),
            onPressed: backOnPressedMarket,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: backOnPressed,
          ),
        ],
      );
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.greenDeep),
          foregroundColor: AppColors.greenDeep,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: ColorsUtil.headerGray,
          leading: getLeading(),
          leadingWidth: isReload ? 88 : null,
          centerTitle: true,
          // bottom: PreferredSize(
          //   child: Container(
          //     height: 80,
          //   ),
          //   preferredSize: Size.fromHeight(80),
          // ),
          actions: [
            (isMenuVisible)
                ? IconButton(
                    padding: EdgeInsets.only(right: 10),
                    onPressed: () {
                      context.pushNamed(RoutesName.SettingsScreen);
                      // context.pushNamed(RoutesName.ProfileScreen);
                    },
                    icon: Icon(Icons.menu))
                // NavBarWidget()
                : IconButton(
                    padding: EdgeInsets.only(right: 10),
                    onPressed: () {
                      Utils.launchSupportCall();
                    },
                    icon: Icon(Icons.support_agent)),
            (isLogout)
                ? IconButton(
                    padding: EdgeInsets.only(right: 10),
                    onPressed: () {
                      Utils.showDoubleBtnAlert(
                          context: context,
                          title: "Logout",
                          msg: 'Are you sure want to Logout?',
                          onTap: () {
                            context.read<AppStateProvider>().clearUserState();
                            context.goNamed(RoutesName.LandingScreen);
                          });
                    },
                    icon: Icon(Icons.logout))
                : SizedBox(),
          ],
          title: Visibility(
            visible: isLogoVisible,
            child: Image(
              image: AssetImage(LocalImages.peerbridge_logo),
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Visibility(
            visible: Utils.isWeb && isDownloadBarVisible,
            child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          insetPadding: EdgeInsets.all(2),
                          contentPadding: EdgeInsets.all(2),
                          titlePadding: EdgeInsets.all(2),
                          title: ListTile(
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ),
                              title: Text(
                                "Download the PeerBridge app",
                                style: Theme.of(context).textTheme.headline6,
                              )),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 12,
                              ),
                              CustomButton(
                                bgColor: AppColors.greenDeep,
                                titleStr: "IOS",
                                onPress: () {
                                  launch(Constants.appStoreUrl);
                                },
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              CustomButton(
                                bgColor: AppColors.greenDeep,
                                titleStr: "ANDROID",
                                onPress: () {
                                  launch(Constants.playStoreUrl);
                                },
                              ),
                            ],
                          ),
                          actions: [],
                        ));
              },
              tileColor: AppColors.greenDeep,
              textColor: Colors.white,
              title: Text("Download the PeerBridge mobile app"),
              trailing: Icon(
                Icons.download,
                color: Colors.white,
              ),
            ))
      ],
    );

    var screenSize = MediaQuery.of(context).size;
  }
}
