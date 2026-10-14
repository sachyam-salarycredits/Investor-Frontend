import 'package:Monexo/modules/onboardingSteps/models/steps_data.dart';
import 'package:Monexo/modules/onboardingSteps/screens/whats_next_screen.dart';
import 'package:Monexo/modules/profile/models/user_details.dart';
import 'package:Monexo/modules/profile/widgets/logoWidget.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../widgets/custom_button.dart';
import '../../../widgets/header.dart';
import '../../../widgets/loader.dart';
import '../../../widgets/nav_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  final Size? screenSize;

  ProfileScreen({this.screenSize});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CustomPopupMenuController _controller = CustomPopupMenuController();
  bool isLoading = false;
  bool isAddPressed = false;
  bool switchValue = false;
  bool loadingAmount = false;

  @override
  void initState() {
    //for getting always update state
    // context.read<AppStateProvider>().getStepsStatus();
    super.initState();
    getFundDetails();
  }

  void getFundDetails() async {
    setState(() {
      loadingAmount = true;
    });
    await context.read<AppStateProvider>().getUserFundDetails();
    setState(() {
      loadingAmount = false;
    });
  }

  void logOutTap() {
    _controller.hideMenu();
    Utils.showDoubleBtnAlert(
        context: context,
        title: "Logout",
        msg: 'Are you sure want to Logout?',
        onTap: () {
          context.read<AppStateProvider>().logout();
          context.read<AppStateProvider>().clearUserState();
          context.pushNamed(RoutesName.Login);
        });
  }

  @override
  Widget build(BuildContext context) {
    print("nav bar called");
    _controller.hideMenu();

    var provider = Provider.of<AppStateProvider>(context);
    var userData = provider.userDetails;
    var statusData = provider.stepsData ?? StepsData();
    var stepsList =
        StepsContent.getStepsList(statusData, userData?.panDetails?.gender);
    var advanceStepsList = StepsContent.getAdvanceStepsList(
        statusData, userData?.panDetails?.gender);
    if (userData == null) {
      return SizedBox();
    }
    // print('changed screen size');

    Future<String> getVersion() async {
      var packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    }

    var screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorsUtil.blueColor,
        // appBar: ResponsiveWidget.isSmallScreen(context)
        //     ? AppBar(
        //   title: Image(
        //     width: 100,
        //     height: 40,
        //     // fit: BoxFit.cover,
        //     image: AssetImage(
        //       LocalImages.monexo_logo,
        //     ),
        //   ),
        //   actions: [
        //     InkWell(
        //       onTap: (){
        //         Navigator.pop(context);
        //       },
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 10),
        //         child: Image(
        //           image: AssetImage(LocalImages.close),
        //           width: 15,
        //           height: 15,
        //         ),
        //       ),
        //     )
        //
        //   ],
        //   elevation: 0,
        //   toolbarHeight: 70,
        //   backgroundColor: ColorsUtil.white,
        //
        //   leading: Container(width: 10,)
        //     ,
        //
        // )
        //     : null,
        body: MonexoLoader(
          isLoading: isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Expanded(
                        child: mainWidget(context, userData),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        child: Column(
                          children: [
                            // Header(
                            //   backOnPressed: () {
                            //     context.pop();
                            //   },
                            // ),
                            Expanded(
                                child: Container(
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    child: mainWidget(context, userData))),
                            // Expanded(
                            //   child: Container(
                            //     child: Center(
                            //       child: Container(
                            //         width: screenSize.width * .4,
                            //         constraints: BoxConstraints(maxWidth: 500),
                            //         child: Column(
                            //           children: [
                            //             SizedBox(height: 30),
                            //             // mainWidget(context, userData),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width * .44,
                        color: ColorsUtil.blueColor,
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Column mainWidget(BuildContext context, UserDetails userData) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              // stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Color(0xffCEEFE9),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Image(
                      width: 130,
                      height: 60,
                      color: ColorsUtil.blueColor,
                      // fit: BoxFit.cover,
                      image: AssetImage(
                        LocalImages.monexo_logo,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Icon(
                            Icons.close,
                            color: ColorsUtil.blueColor,
                          )),
                    ),
                  )
                ],
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(RoutesName.ProfileDetail);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 115,
                  color: Colors.transparent,
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                child: LogoWidget(
                                  size: 60,
                                  url: userData.profileDetails!.profileUrl,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      userData.profileDetails!.fullName,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      userData.profileDetails?.email ?? '',
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: CustomFonts.nunito,
                                          fontWeight: FontWeight.w400,
                                          color: ColorsUtil.lighterGrey),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 20.0,
                                      color: ColorsUtil.black,
                                    ),
                                    SizedBox(
                                      width: 6.0,
                                    ),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.0,
                                          fontFamily: CustomFonts.nunito),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: ColorsUtil.blueColor),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text('Balance Available To Invest',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: ColorsUtil.white,
                                          fontFamily: CustomFonts.nunito,
                                          fontWeight: FontWeight.w700)),
                                ),
                                loadingAmount
                                    ? CircularProgressIndicator(
                                        backgroundColor: ColorsUtil.blueColor,
                                        strokeWidth: 2.0,
                                      )
                                    : Text(
                                        Utils.availableAmount == 0.0
                                            ? '₹  Nil'
                                            : '₹  ${Utils.availableAmount.truncate().commaAddedValue()}',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: ColorsUtil.white,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w700),
                                      ),
                              ],
                            ),
                            Container(
                                height: 40,
                                width: 120,
                                margin: EdgeInsets.all(8),
                                child: CustomButton(
                                  bgColor: ColorsUtil.white,
                                  horizontalMargin: 0,
                                  textSize: 13,
                                  leftIcon: Icon(
                                    Icons.add,
                                    size: 15,
                                    color: ColorsUtil.blueColor,
                                  ),
                                  titleStr: 'Add Funds',
                                  textColor: ColorsUtil.blueColor,
                                  onPress: () {
                                    context.pushNamed(
                                        RoutesName.NewFundTransferScreen);
                                  },
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        child: Divider(
                          thickness: 1.0,
                          height: 1.0,
                          color: ColorsUtil.circleGrey,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: Container(
                            // height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: ColorsUtil.blueColor,
                                borderRadius: BorderRadius.circular(8)),

                            child: ExpansionTile(
                              tilePadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              textColor: Colors.white,
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: ColorsUtil.arrowColor,
                              ),
                              iconColor: ColorsUtil.dividerColor,
                              title: Text(
                                'Account Statement',
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 15.0,
                                    color: ColorsUtil.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: getStatement(),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          context.pushNamed(RoutesName.PortfolioAnalysis);
                        },
                        title: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Investments',
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 15.0,
                                    color: ColorsUtil.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: ColorsUtil.arrowColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          context.pushNamed(RoutesName.Redemption);
                        },
                        title: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Redemption',
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 15.0,
                                    color: ColorsUtil.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: ColorsUtil.arrowColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          context.pushNamed(RoutesName.Withdraw);
                        },
                        title: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Withdraw Funds',
                                style: TextStyle(
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 15.0,
                                    color: ColorsUtil.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: ColorsUtil.arrowColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        title: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Call Support',
                                style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsUtil.white,
                                ),
                              ),
                              Icon(
                                Icons.support_agent,
                                color: ColorsUtil.white,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Utils.launchSupportCall();
                        },
                      ),
                      ListTile(
                        title: Container(
                          height: 50,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LogOut',
                                style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsUtil.white,
                                ),
                              ),
                              Icon(
                                Icons.logout,
                                color: ColorsUtil.white,
                                size: 25.0,
                              ),
                            ],
                          ),
                        ),
                        onTap: logOutTap,
                      ),
                    ],
                  ),
                  if (!Utils.isWeb)
                    Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  FlyyFlutterPlugin.openFlyyRewardsPage();
                                },
                                child: Container(
                                  width: ResponsiveWidget.isSmallScreen(context)
                                      ? MediaQuery.of(context).size.width / 3.6
                                      : 105,
                                  height: 92,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      border:
                                          Border.all(color: ColorsUtil.blueColor),
                                      color: ColorsUtil.blueColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        LocalImages.rewardsWhite,
                                        width: 30,
                                        height: 34,
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        'Rewards',
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w700,
                                            color: ColorsUtil.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FlyyFlutterPlugin.openFlyyOffersPage();
                                },
                                child: Container(
                                  width: ResponsiveWidget.isSmallScreen(context)
                                      ? MediaQuery.of(context).size.width / 3.6
                                      : 105,
                                  height: 92,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      border:
                                          Border.all(color: ColorsUtil.blueColor),
                                      color: ColorsUtil.blueColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        LocalImages.offersWhite,
                                        width: 30,
                                        height: 34,
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        'Offers',
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w700,
                                            color: ColorsUtil.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  FlyyFlutterPlugin.openFlyyQuizListPage();
                                },
                                child: Container(
                                  width: ResponsiveWidget.isSmallScreen(context)
                                      ? MediaQuery.of(context).size.width / 3.6
                                      : 105,
                                  height: 92,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7.0),
                                      border:
                                          Border.all(color: ColorsUtil.blueColor),
                                      color: ColorsUtil.blueColor),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        LocalImages.quizWhite,
                                        width: 30,
                                        height: 34,
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        'Quiz',
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w700,
                                            color: ColorsUtil.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        InkWell(
                            onTap: () {
                              FlyyFlutterPlugin.openFlyyCustomInviteAndEarnPage(
                                  0, '#ffffff');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 15),
                              child: Image.asset(
                                LocalImages.profileRect,
                                height: 120,
                              ),
                            )),
                        Center(
                            child: Text(
                                "Monexo Fintech Version: ${context.read<AppStateProvider>().appVersion} ",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: CustomFonts.nunito,
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.white))),
                        SizedBox(height: 20),
                      ],
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getStatement() {
    var provider = Provider.of<AppStateProvider>(context);
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
      itemBuilder: (context, index) {
        final statement = provider.statementList[index];
        final currentYear = int.tryParse(statement.year.trim()) ?? 0;
        if (currentYear == 0) {
          return const SizedBox.shrink();
        }
        return InkWell(
          onTap: () {
            if (statement.statementUrl != null &&
                statement.statementUrl != '') {
              Utils.launchURL(statement.statementUrl);
            }
          },
          child: Container(
            child: Text(
              'Financial Year ${currentYear - 1}-$currentYear',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: CustomFonts.nunito,
                  fontWeight: FontWeight.w500,
                  color: ColorsUtil.white),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
          ),
        );
      },
      itemCount: provider.statementList.length,
    );
  }
}
