import 'package:Monexo/modules/onboardingSteps/models/steps_data.dart';
import 'package:Monexo/modules/onboardingSteps/screens/whats_next_screen.dart';
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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../modules/home/screens/home_screen.dart';
import '../utils/constants.dart';
import 'custom_button.dart';
import 'header.dart';
import 'loader.dart';
import 'nav_bar_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NavBarWidget extends StatefulWidget {
  final Size? screenSize;

  NavBarWidget({this.screenSize});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  CustomPopupMenuController _controller = CustomPopupMenuController();
  bool isAddPressed = false;
  bool switchValue = false;
  bool isLoading = false;

  @override
  void initState() {
    //for getting always update state
    // context.read<AppStateProvider>().getStepsStatus();
    super.initState();
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
          context.goNamed(RoutesName.LandingScreen);
        });
  }

  _sendEmail() {
    final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: 'lend@monexo.co');
    launchUrlString(_emailLaunchUri.toString());
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
        backgroundColor: ColorsUtil.white,
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                toolbarHeight: 70,
                backgroundColor: ColorsUtil.blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                leading: BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            : null,
        body: MonexoLoader(
          isLoading: isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            // InkWell(
                            //   onTap: () {
                            //     context.pushNamed(RoutesName.ProfileDetail);
                            //   },
                            //   child: Container(
                            //     width: MediaQuery.of(context).size.width,
                            //     height: 115,
                            //     color: ColorsUtil.white,
                            //     margin: EdgeInsets.symmetric(horizontal: 16.0),
                            //     child: Column(
                            //       children: [
                            //         SizedBox(
                            //           height: 24.0,
                            //         ),
                            //         Row(
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.start,
                            //             children: [
                            //               Padding(
                            //                 padding:
                            //                     const EdgeInsets.only(top: 8.0),
                            //                 child: LogoWidget(
                            //                   size: 45,
                            //                   url: userData
                            //                       .profileDetails!.profileUrl,
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 width: 15.0,
                            //               ),
                            //               Expanded(
                            //                 child: Column(
                            //                     crossAxisAlignment:
                            //                         CrossAxisAlignment.start,
                            //                     children: [
                            //                       SizedBox(
                            //                         height: 5.0,
                            //                       ),
                            //                       Text(
                            //                         userData.profileDetails!
                            //                             .fullName,
                            //                         overflow:
                            //                             TextOverflow.ellipsis,
                            //                         textAlign: TextAlign.left,
                            //                         style: TextStyle(
                            //                           fontSize: 20.0,
                            //                           fontFamily:
                            //                               CustomFonts.nunito,
                            //                           fontWeight:
                            //                               FontWeight.w700,
                            //                         ),
                            //                       ),
                            //                       Text(
                            //                         userData.profileDetails
                            //                                 ?.email ??
                            //                             '',
                            //                         textAlign: TextAlign.left,
                            //                         overflow:
                            //                             TextOverflow.ellipsis,
                            //                         style: TextStyle(
                            //                             fontSize: 14.0,
                            //                             fontFamily:
                            //                                 CustomFonts.nunito,
                            //                             fontWeight:
                            //                                 FontWeight.w400,
                            //                             color: ColorsUtil
                            //                                 .lighterGrey),
                            //                       ),
                            //                       SizedBox(
                            //                         height: 10,
                            //                       ),
                            //                     ]),
                            //               ),
                            //               Padding(
                            //                 padding: const EdgeInsets.only(
                            //                     top: 10.0),
                            //                 child: InkWell(
                            //                   child: Row(
                            //                     children: [
                            //                       Icon(
                            //                         Icons.edit_outlined,
                            //                         size: 20.0,
                            //                         color: ColorsUtil.black,
                            //                       ),
                            //                       SizedBox(
                            //                         width: 6.0,
                            //                       ),
                            //                       Text(
                            //                         'Edit',
                            //                         style: TextStyle(
                            //                             fontWeight:
                            //                                 FontWeight.w700,
                            //                             fontSize: 16.0,
                            //                             fontFamily:
                            //                                 CustomFonts.nunito),
                            //                       )
                            //                     ],
                            //                   ),
                            //                 ),
                            //               ),
                            //             ]),
                            //         SizedBox(
                            //           height: 15.0,
                            //         ),
                            //         Divider(
                            //           thickness: 1.0,
                            //           height: 2.0,
                            //           color: ColorsUtil.circleGrey,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),

                            Builder(
                              builder: (context) {
                                return Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            16.0, 16, 16, 25),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Complete your account',
                                              style: TextStyle(
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontSize: 18,
                                                  color: ColorsUtil.blueColor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Text(
                                              'Please take a moment to complete the few remaining steps.',
                                              style: TextStyle(
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontSize: 14,
                                                  color: ColorsUtil.blueColor),
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Divider(
                                              thickness: 1.0,
                                              height: 2.0,
                                              color: ColorsUtil.circleGrey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 16.0),
                                        itemBuilder: (context, index) {
                                          // print('setpsList :${stepsList[index].title}');
                                          final step = stepsList[index];
                                          return NavBarBoxWidget(
                                            subText: index == 0
                                                ? 'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop'
                                                : 'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop',
                                            headingText: step.title,
                                            onPress: () {
                                              step.title == StepsContent.kyc &&
                                                      step.status
                                                              .removeSpace() ==
                                                          '2'
                                                  ? showDialog<void>(
                                                      context: context,
                                                      useRootNavigator: true,
                                                      barrierDismissible:
                                                          false, // user must tap button!
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Monexo',
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              color: ColorsUtil
                                                                  .blueColor,
                                                            ),
                                                          ),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: ListBody(
                                                              children: <
                                                                  Widget>[
                                                                RichText(
                                                                  // textAlign:
                                                                  //     TextAlign
                                                                  //         .justify,
                                                                  text:
                                                                      TextSpan(
                                                                    text:
                                                                        'Your e-KYC is incomplete because the Selfie doesn`t match with the Aadhar image. Please send the self attested image of the Aadhar card to ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: ColorsUtil
                                                                          .black,
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                          text:
                                                                              'lend@monexo.co',
                                                                          style:
                                                                              TextStyle(
                                                                            // height:
                                                                            //     1.9,
                                                                            color:
                                                                                Colors.blue,
                                                                            decoration:
                                                                                TextDecoration.underline,
                                                                            decorationColor:
                                                                                Colors.blue,
                                                                            decorationThickness:
                                                                                1.5,
                                                                            height:
                                                                                1.5,
                                                                          ),
                                                                          recognizer: TapGestureRecognizer()
                                                                            ..onTap =
                                                                                _sendEmail),
                                                                      TextSpan(
                                                                        text:
                                                                            ' for completing KYC process. If you have already send then your application will be completed soon.',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              ColorsUtil.black,
                                                                          height:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text('ok'),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    )
                                                  // Utils.showAlert(
                                                  //         context: context,
                                                  //
                                                  //         ///msg integrate
                                                  //         msg:
                                                  //             'Your e-KYC is incomplete because the Selfie doesn`t match with the Aadhar image. Please send the self attested image of the Aadhar card to lend@monexo.co to complete KYC process',
                                                  //         onTap: () {
                                                  //           // context.pop();
                                                  //         })
                                                  : context.pushNamed(
                                                      step.screenName);
                                            },

                                            status: step.status,
                                            // iconText: index == 0
                                            //     ? 'Add Money'
                                            //     : 'Edit',
                                            isDisabled: step.title ==
                                                    StepsContent.kyc &&
                                                step.status.removeSpace() ==
                                                    '1',
                                            whatsNextIcon:
                                                Icons.arrow_forward_ios,
                                            // index == 0
                                            //     ? Icons.add
                                            //     : Icons.edit_outlined,
                                          );
                                        },
                                        itemCount: stepsList.length,
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Advanced Settings',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            FlutterSwitch(
                                              activeColor: ColorsUtil.blueColor,
                                              width: 50.0,
                                              height: 25.0,
                                              // valueFontSize: 25.0,
                                              toggleSize: 20.0,
                                              value: switchValue,
                                              borderRadius: 30.0,
                                              // padding: 8.0,
                                              // showOnOff: true,
                                              onToggle: (val) {
                                                // switchValue = val;
                                                // print('switch$switchValue');
                                                setState(() {
                                                  switchValue = val;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       horizontal: 15, vertical: 5),
                                      //   child: Divider(),
                                      // ),
                                      // switchValue
                                      //     ?\
                                      SizedBox(height: 20),
                                      IgnorePointer(
                                        ignoring: !switchValue,
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 16.0),
                                          itemBuilder: (context, index) {
                                            print(
                                                'setpsList :${advanceStepsList[index].title}');

                                            final step =
                                                advanceStepsList[index];
                                            return NavBarBoxWidget(
                                              swithValue: !switchValue,
                                              headingText: step.title,
                                              onPress: () {
                                                if (step.title ==
                                                    StepsContent.sip) {
                                                  context.pushNamed(
                                                      RoutesName.IntroScreen,
                                                      params: {
                                                        Constants.forSIP: 'true'
                                                      });
                                                } else if (step.title ==
                                                    StepsContent.mip) {
                                                  context.pushNamed(
                                                      RoutesName.IntroScreen,
                                                      params: {
                                                        Constants.forSIP:
                                                            'false'
                                                      });
                                                } else {
                                                  context.pushNamed(
                                                      step.screenName);
                                                }
                                              },
                                              status: step.status,
                                              subText:
                                                  'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop',
                                              // isDisabled: step.title == StepsContent.kyc &&
                                              // step.status.removeSpace() == '1',
                                              whatsNextIcon:
                                                  Icons.arrow_forward_ios,
                                            );
                                          },
                                          itemCount: advanceStepsList.length,
                                        ),
                                      ),
                                      CustomButton(
                                          titleStr: 'Back to Home',
                                          horizontalMargin: 16,
                                          onPress: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeScreen()));
                                          }),

                                      // ListTile(
                                      //   title: Text(
                                      //     'Call Support',
                                      //     style: TextStyle(
                                      //       fontFamily: CustomFonts.nunito,
                                      //       fontSize: 16.0,
                                      //       fontWeight: FontWeight.w700,
                                      //       color: ColorsUtil.blueColor,
                                      //     ),
                                      //   ),
                                      //   onTap: () {
                                      //     Utils.launchSupportCall();
                                      //   },
                                      //   trailing: Icon(
                                      //     Icons.support_agent,
                                      //     color: ColorsUtil.blueColor,
                                      //   ),
                                      // ),
                                      // Divider(),
                                      // ListTile(
                                      //   title: Text(
                                      //     'LogOut',
                                      //     style: TextStyle(
                                      //       fontFamily: CustomFonts.nunito,
                                      //       fontSize: 16.0,
                                      //       fontWeight: FontWeight.w700,
                                      //       color: ColorsUtil.redColor,
                                      //     ),
                                      //   ),
                                      //   onTap: logOutTap,
                                      //   trailing: Icon(
                                      //     Icons.logout,
                                      //     color: ColorsUtil.redColor,
                                      //     size: 25.0,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 20),
                                      // Center(
                                      //     child: Text(
                                      //         "Version: ${context.read<AppStateProvider>().appVersion}",
                                      //         style: TextStyle(
                                      //           fontSize: 12.0,
                                      //           fontFamily: CustomFonts.nunito,
                                      //           fontWeight: FontWeight.w500,
                                      //         ))),
                                      // SizedBox(height: 20),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   child: Container(
                      //     padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                      //     child: SingleChildScrollView(
                      //       scrollDirection: Axis.vertical,
                      //       child: Column(
                      //         children: <Widget>[
                      //           InkWell(
                      //             onTap: () {
                      //               context.pushNamed(RoutesName.ProfileDetail);
                      //             },
                      //             child: Container(
                      //               width: MediaQuery.of(context).size.width,
                      //               height: 115,
                      //               color: ColorsUtil.white,
                      //               margin:
                      //                   EdgeInsets.symmetric(horizontal: 16.0),
                      //               child: Column(
                      //                 children: [
                      //                   SizedBox(
                      //                     height: 24.0,
                      //                   ),
                      //                   Row(
                      //                       crossAxisAlignment:
                      //                           CrossAxisAlignment.start,
                      //                       children: [
                      //                         Padding(
                      //                           padding: const EdgeInsets.only(
                      //                               top: 8.0),
                      //                           child: LogoWidget(
                      //                             size: 45,
                      //                             url: userData.profileDetails!
                      //                                 .profileUrl,
                      //                           ),
                      //                         ),
                      //                         SizedBox(
                      //                           width: 15.0,
                      //                         ),
                      //                         Expanded(
                      //                           child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               children: [
                      //                                 SizedBox(
                      //                                   height: 5.0,
                      //                                 ),
                      //                                 Text(
                      //                                   userData.profileDetails!
                      //                                       .fullName,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   textAlign:
                      //                                       TextAlign.left,
                      //                                   style: TextStyle(
                      //                                     fontSize: 20.0,
                      //                                     fontFamily:
                      //                                         CustomFonts
                      //                                             .nunito,
                      //                                     fontWeight:
                      //                                         FontWeight.w700,
                      //                                   ),
                      //                                 ),
                      //                                 Text(
                      //                                   userData.profileDetails
                      //                                           ?.email ??
                      //                                       '',
                      //                                   textAlign:
                      //                                       TextAlign.left,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                   style: TextStyle(
                      //                                       fontSize: 14.0,
                      //                                       fontFamily:
                      //                                           CustomFonts
                      //                                               .nunito,
                      //                                       fontWeight:
                      //                                           FontWeight.w400,
                      //                                       color: ColorsUtil
                      //                                           .lighterGrey),
                      //                                 ),
                      //                                 SizedBox(
                      //                                   height: 10,
                      //                                 ),
                      //                               ]),
                      //                         ),
                      //                         Padding(
                      //                           padding: const EdgeInsets.only(
                      //                               top: 10.0),
                      //                           child: InkWell(
                      //                             child: Row(
                      //                               children: [
                      //                                 Icon(
                      //                                   Icons.edit_outlined,
                      //                                   size: 20.0,
                      //                                   color: ColorsUtil.black,
                      //                                 ),
                      //                                 SizedBox(
                      //                                   width: 6.0,
                      //                                 ),
                      //                                 Text(
                      //                                   'Edit',
                      //                                   style: TextStyle(
                      //                                       fontWeight:
                      //                                           FontWeight.w700,
                      //                                       fontSize: 16.0,
                      //                                       fontFamily:
                      //                                           CustomFonts
                      //                                               .nunito),
                      //                                 )
                      //                               ],
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ]),
                      //                   SizedBox(
                      //                     height: 15.0,
                      //                   ),
                      //                   Divider(
                      //                     thickness: 1.0,
                      //                     height: 2.0,
                      //                     color: ColorsUtil.circleGrey,
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //           Builder(
                      //             builder: (context) {
                      //               return Expanded(
                      //                 child: ListView(
                      //                   shrinkWrap: true,
                      //                   children: [
                      //                     ListView.builder(
                      //                       physics:
                      //                           NeverScrollableScrollPhysics(),
                      //                       shrinkWrap: true,
                      //                       padding: EdgeInsets.symmetric(
                      //                           vertical: 0, horizontal: 16.0),
                      //                       itemBuilder: (context, index) {
                      //                         final step = stepsList[index];
                      //                         return NavBarBoxWidget(
                      //                           headingText: step.title,
                      //                           onPress: () {
                      //                             context.pushNamed(
                      //                                 step.screenName);
                      //                           },
                      //                           status: step.status,
                      //                           iconText: index == 0
                      //                               ? 'Add Money'
                      //                               : 'Edit',
                      //                           isDisabled: step.title ==
                      //                                   StepsContent.kyc &&
                      //                               step.status.removeSpace() ==
                      //                                   '1',
                      //                           whatsNextIcon: index == 0
                      //                               ? Icons.add
                      //                               : Icons.edit_outlined,
                      //                         );
                      //                       },
                      //                       itemCount: stepsList.length,
                      //                     ),
                      //                     Container(
                      //                       margin: EdgeInsets.symmetric(
                      //                           horizontal: 15),
                      //                       child: Row(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment
                      //                                 .spaceBetween,
                      //                         children: [
                      //                           Text(
                      //                             'Advanced Settings',
                      //                             textAlign: TextAlign.start,
                      //                             style: TextStyle(
                      //                               fontFamily:
                      //                                   CustomFonts.nunito,
                      //                               fontWeight: FontWeight.bold,
                      //                               fontSize: 18,
                      //                             ),
                      //                           ),
                      //                           FlutterSwitch(
                      //                             activeColor:
                      //                                 ColorsUtil.blueColor,
                      //                             width: 50.0,
                      //                             height: 25.0,
                      //                             // valueFontSize: 25.0,
                      //                             toggleSize: 20.0,
                      //                             value: switchValue,
                      //                             borderRadius: 30.0,
                      //                             // padding: 8.0,
                      //                             // showOnOff: true,
                      //                             onToggle: (val) {
                      //                               // switchValue = val;
                      //                               setState(() {
                      //                                 switchValue = val;
                      //                               });
                      //                             },
                      //                           )
                      //                         ],
                      //                       ),
                      //                     ),
                      //                     Padding(
                      //                       padding: const EdgeInsets.symmetric(
                      //                           horizontal: 15, vertical: 5),
                      //                       child: Divider(),
                      //                     ),
                      //                     switchValue
                      //                         ? ListView.builder(
                      //                             physics:
                      //                                 NeverScrollableScrollPhysics(),
                      //                             shrinkWrap: true,
                      //                             padding: EdgeInsets.symmetric(
                      //                                 vertical: 0,
                      //                                 horizontal: 16.0),
                      //                             itemBuilder:
                      //                                 (context, index) {
                      //                               final step =
                      //                                   advanceStepsList[index];
                      //                               return NavBarBoxWidget(
                      //                                 headingText: step.title,
                      //                                 onPress: () {
                      //                                   context.pushNamed(
                      //                                       step.screenName);
                      //                                 },
                      //                                 status: step.status,
                      //                                 iconText: 'Edit',
                      //                                 // isDisabled: step.title == StepsContent.kyc &&
                      //                                 // step.status.removeSpace() == '1',
                      //                                 whatsNextIcon:
                      //                                     Icons.edit_outlined,
                      //                               );
                      //                             },
                      //                             itemCount:
                      //                                 advanceStepsList.length,
                      //                           )
                      //                         : Container(),
                      //                     ListTile(
                      //                       onTap: () {
                      //                         context.pushNamed(
                      //                             RoutesName.Redemption);
                      //                       },
                      //                       title: Container(
                      //                         child: Column(
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment.start,
                      //                           children: [
                      //                             Text(
                      //                               'Redemption',
                      //                               style: TextStyle(
                      //                                   fontFamily:
                      //                                       CustomFonts.nunito,
                      //                                   fontSize: 16.0,
                      //                                   fontWeight:
                      //                                       FontWeight.w700),
                      //                             ),
                      //                             SizedBox(height: 15),
                      //                             Divider(
                      //                               thickness: 1.0,
                      //                               height: 2.0,
                      //                               color:
                      //                                   ColorsUtil.circleGrey,
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         margin: EdgeInsets.symmetric(
                      //                             vertical: 5),
                      //                         width: double.infinity,
                      //                       ),
                      //                     ),
                      //                     ListTile(
                      //                       onTap: () {
                      //                         context.pushNamed(
                      //                             RoutesName.Withdraw);
                      //                       },
                      //                       title: Container(
                      //                         child: Column(
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment.start,
                      //                           children: [
                      //                             Text(
                      //                               'Withdraw Funds',
                      //                               style: TextStyle(
                      //                                 fontFamily:
                      //                                     CustomFonts.nunito,
                      //                                 fontSize: 16.0,
                      //                                 fontWeight:
                      //                                     FontWeight.w700,
                      //                               ),
                      //                             ),
                      //                             SizedBox(height: 15),
                      //                             Divider(
                      //                               thickness: 1.0,
                      //                               height: 2.0,
                      //                               color:
                      //                                   ColorsUtil.circleGrey,
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         margin: EdgeInsets.symmetric(
                      //                             vertical: 5),
                      //                         width: double.infinity,
                      //                       ),
                      //                     ),
                      //                     ListTile(
                      //                       title: Theme(
                      //                         data: Theme.of(context).copyWith(
                      //                             dividerColor:
                      //                                 Colors.transparent),
                      //                         child: ExpansionTile(
                      //                           tilePadding:
                      //                               EdgeInsets.symmetric(
                      //                                   horizontal: 0,
                      //                                   vertical: 0),
                      //                           textColor: Colors.black,
                      //                           iconColor:
                      //                               ColorsUtil.dividerColor,
                      //                           title: Text(
                      //                             'Account Statement',
                      //                             textAlign: TextAlign.left,
                      //                             style: TextStyle(
                      //                               fontSize: 16.0,
                      //                               fontFamily:
                      //                                   CustomFonts.nunito,
                      //                               fontWeight: FontWeight.w700,
                      //                             ),
                      //                           ),
                      //                           children: [
                      //                             Align(
                      //                               alignment:
                      //                                   Alignment.topLeft,
                      //                               child: getStatement(),
                      //                             ),
                      //                             SizedBox(
                      //                               height: 15.0,
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     if (!Utils.isWeb)
                      //                       Column(
                      //                         children: [
                      //                           Container(
                      //                             padding: EdgeInsets.symmetric(
                      //                                 vertical: 0,
                      //                                 horizontal: 16.0),
                      //                             child: Row(
                      //                               mainAxisAlignment:
                      //                                   MainAxisAlignment
                      //                                       .spaceBetween,
                      //                               children: [
                      //                                 InkWell(
                      //                                   onTap: () {
                      //                                     FlyyFlutterPlugin
                      //                                         .openFlyyRewardsPage();
                      //                                   },
                      //                                   child: Container(
                      //                                     width: ResponsiveWidget
                      //                                             .isSmallScreen(
                      //                                                 context)
                      //                                         ? MediaQuery.of(
                      //                                                     context)
                      //                                                 .size
                      //                                                 .width /
                      //                                             3.6
                      //                                         : 105,
                      //                                     height: 92,
                      //                                     decoration: BoxDecoration(
                      //                                         borderRadius:
                      //                                             BorderRadius
                      //                                                 .circular(
                      //                                                     7.0),
                      //                                         border: Border.all(
                      //                                             color: ColorsUtil
                      //                                                 .blueColor),
                      //                                         color: ColorsUtil
                      //                                             .blueColor),
                      //                                     child: Column(
                      //                                       crossAxisAlignment:
                      //                                           CrossAxisAlignment
                      //                                               .center,
                      //                                       mainAxisAlignment:
                      //                                           MainAxisAlignment
                      //                                               .center,
                      //                                       children: [
                      //                                         Image.asset(
                      //                                           LocalImages
                      //                                               .rewards,
                      //                                           width: 30,
                      //                                           height: 34,
                      //                                         ),
                      //                                         SizedBox(
                      //                                           height: 12,
                      //                                         ),
                      //                                         Text(
                      //                                           'Rewards',
                      //                                           style: TextStyle(
                      //                                               fontSize:
                      //                                                   13.0,
                      //                                               fontFamily:
                      //                                                   CustomFonts
                      //                                                       .nunito,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: ColorsUtil
                      //                                                   .white),
                      //                                         ),
                      //                                       ],
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                                 InkWell(
                      //                                   onTap: () {
                      //                                     FlyyFlutterPlugin
                      //                                         .openFlyyOffersPage();
                      //                                   },
                      //                                   child: Container(
                      //                                     width: ResponsiveWidget
                      //                                             .isSmallScreen(
                      //                                                 context)
                      //                                         ? MediaQuery.of(
                      //                                                     context)
                      //                                                 .size
                      //                                                 .width /
                      //                                             3.6
                      //                                         : 105,
                      //                                     height: 92,
                      //                                     decoration: BoxDecoration(
                      //                                         borderRadius:
                      //                                             BorderRadius
                      //                                                 .circular(
                      //                                                     7.0),
                      //                                         border: Border.all(
                      //                                             color: ColorsUtil
                      //                                                 .blueColor),
                      //                                         color: ColorsUtil
                      //                                             .blueColor),
                      //                                     child: Column(
                      //                                       crossAxisAlignment:
                      //                                           CrossAxisAlignment
                      //                                               .center,
                      //                                       mainAxisAlignment:
                      //                                           MainAxisAlignment
                      //                                               .center,
                      //                                       children: [
                      //                                         Image.asset(
                      //                                           LocalImages
                      //                                               .offers,
                      //                                           width: 30,
                      //                                           height: 34,
                      //                                         ),
                      //                                         SizedBox(
                      //                                           height: 12,
                      //                                         ),
                      //                                         Text(
                      //                                           'Offers',
                      //                                           style: TextStyle(
                      //                                               fontSize:
                      //                                                   13.0,
                      //                                               fontFamily:
                      //                                                   CustomFonts
                      //                                                       .nunito,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: ColorsUtil
                      //                                                   .white),
                      //                                         ),
                      //                                       ],
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                                 InkWell(
                      //                                   onTap: () {
                      //                                     FlyyFlutterPlugin
                      //                                         .openFlyyQuizListPage();
                      //                                   },
                      //                                   child: Container(
                      //                                     width: ResponsiveWidget
                      //                                             .isSmallScreen(
                      //                                                 context)
                      //                                         ? MediaQuery.of(
                      //                                                     context)
                      //                                                 .size
                      //                                                 .width /
                      //                                             3.6
                      //                                         : 105,
                      //                                     height: 92,
                      //                                     decoration: BoxDecoration(
                      //                                         borderRadius:
                      //                                             BorderRadius
                      //                                                 .circular(
                      //                                                     7.0),
                      //                                         border: Border.all(
                      //                                             color: ColorsUtil
                      //                                                 .blueColor),
                      //                                         color: ColorsUtil
                      //                                             .blueColor),
                      //                                     child: Column(
                      //                                       crossAxisAlignment:
                      //                                           CrossAxisAlignment
                      //                                               .center,
                      //                                       mainAxisAlignment:
                      //                                           MainAxisAlignment
                      //                                               .center,
                      //                                       children: [
                      //                                         Image.asset(
                      //                                           LocalImages
                      //                                               .quiz,
                      //                                           width: 30,
                      //                                           height: 34,
                      //                                         ),
                      //                                         SizedBox(
                      //                                           height: 12,
                      //                                         ),
                      //                                         Text(
                      //                                           'Quiz',
                      //                                           style: TextStyle(
                      //                                               fontSize:
                      //                                                   13.0,
                      //                                               fontFamily:
                      //                                                   CustomFonts
                      //                                                       .nunito,
                      //                                               fontWeight:
                      //                                                   FontWeight
                      //                                                       .w500,
                      //                                               color: ColorsUtil
                      //                                                   .white),
                      //                                         ),
                      //                                       ],
                      //                                     ),
                      //                                   ),
                      //                                 ),
                      //                               ],
                      //                             ),
                      //                           ),
                      //                           SizedBox(
                      //                             height: 7,
                      //                           ),
                      //                           InkWell(
                      //                               onTap: () {
                      //                                 FlyyFlutterPlugin
                      //                                     .openFlyyCustomInviteAndEarnPage(
                      //                                         0, '#ffffff');
                      //                               },
                      //                               child: Padding(
                      //                                 padding: const EdgeInsets
                      //                                         .symmetric(
                      //                                     vertical: 5,
                      //                                     horizontal: 15),
                      //                                 child: Image.asset(
                      //                                   LocalImages.referBanner,
                      //                                   height: 120,
                      //                                 ),
                      //                               )),
                      //                         ],
                      //                       ),
                      //                     ListTile(
                      //                       title: Text(
                      //                         'Call Support',
                      //                         style: TextStyle(
                      //                           fontFamily: CustomFonts.nunito,
                      //                           fontSize: 16.0,
                      //                           fontWeight: FontWeight.w700,
                      //                           color: ColorsUtil.blueColor,
                      //                         ),
                      //                       ),
                      //                       onTap: () {
                      //                         Utils.launchSupportCall();
                      //                       },
                      //                       trailing: Icon(
                      //                         Icons.support_agent,
                      //                         color: ColorsUtil.blueColor,
                      //                       ),
                      //                     ),
                      //                     Divider(),
                      //                     ListTile(
                      //                       title: Text(
                      //                         'LogOut',
                      //                         style: TextStyle(
                      //                           fontFamily: CustomFonts.nunito,
                      //                           fontSize: 16.0,
                      //                           fontWeight: FontWeight.w700,
                      //                           color: ColorsUtil.redColor,
                      //                         ),
                      //                       ),
                      //                       onTap: logOutTap,
                      //                       trailing: Icon(
                      //                         Icons.logout,
                      //                         color: ColorsUtil.redColor,
                      //                         size: 25.0,
                      //                       ),
                      //                     ),
                      //                     SizedBox(height: 20),
                      //                     Center(
                      //                         child: Text(
                      //                             "Version: ${context.read<AppStateProvider>().appVersion}",
                      //                             style: TextStyle(
                      //                               fontSize: 12.0,
                      //                               fontFamily:
                      //                                   CustomFonts.nunito,
                      //                               fontWeight: FontWeight.w500,
                      //                             ))),
                      //                     SizedBox(height: 20),
                      //                   ],
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        child: Column(
                          children: [
                            Header(
                              backOnPressed: () {
                                context.pop();
                              },
                            ),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Container(
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 30),
                                        Builder(
                                          builder: (context) {
                                            return Expanded(
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            16.0, 16, 16, 25),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Complete your account',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontSize: 18,
                                                              color: ColorsUtil
                                                                  .blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          height: 7,
                                                        ),
                                                        Text(
                                                          'Please take a moment to complete the few remaining steps.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontSize: 14,
                                                              color: ColorsUtil
                                                                  .blueColor),
                                                        ),
                                                        SizedBox(
                                                          height: 7,
                                                        ),
                                                        Divider(
                                                          thickness: 1.0,
                                                          height: 2.0,
                                                          color: ColorsUtil
                                                              .circleGrey,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0,
                                                            horizontal: 16.0),
                                                    itemBuilder:
                                                        (context, index) {
                                                      // print('setpsList :${stepsList[index].title}');
                                                      final step =
                                                          stepsList[index];
                                                      return NavBarBoxWidget(
                                                        subText: index == 0
                                                            ? 'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop'
                                                            : 'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop',
                                                        headingText: step.title,
                                                        onPress: () {
                                                          context.pushNamed(
                                                              step.screenName);
                                                        },

                                                        status: step.status,
                                                        // iconText: index == 0
                                                        //     ? 'Add Money'
                                                        //     : 'Edit',
                                                        isDisabled: step
                                                                    .title ==
                                                                StepsContent
                                                                    .kyc &&
                                                            step.status
                                                                    .removeSpace() ==
                                                                '1',
                                                        whatsNextIcon: Icons
                                                            .arrow_forward_ios,
                                                        // index == 0
                                                        //     ? Icons.add
                                                        //     : Icons.edit_outlined,
                                                      );
                                                    },
                                                    itemCount: stepsList.length,
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Advanced Settings',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                CustomFonts
                                                                    .nunito,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        FlutterSwitch(
                                                          activeColor:
                                                              ColorsUtil
                                                                  .blueColor,
                                                          width: 50.0,
                                                          height: 25.0,
                                                          // valueFontSize: 25.0,
                                                          toggleSize: 20.0,
                                                          value: switchValue,
                                                          borderRadius: 30.0,
                                                          // padding: 8.0,
                                                          // showOnOff: true,
                                                          onToggle: (val) {
                                                            // switchValue = val;
                                                            // print('switch$switchValue');
                                                            setState(() {
                                                              switchValue = val;
                                                            });
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  // Padding(
                                                  //   padding: const EdgeInsets.symmetric(
                                                  //       horizontal: 15, vertical: 5),
                                                  //   child: Divider(),
                                                  // ),
                                                  // switchValue
                                                  //     ?\
                                                  SizedBox(height: 20),
                                                  IgnorePointer(
                                                    ignoring: !switchValue,
                                                    child: ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 0,
                                                              horizontal: 16.0),
                                                      itemBuilder:
                                                          (context, index) {
                                                        print(
                                                            'setpsList :${advanceStepsList[index].title}');

                                                        final step =
                                                            advanceStepsList[
                                                                index];
                                                        return NavBarBoxWidget(
                                                          swithValue:
                                                              !switchValue,
                                                          headingText:
                                                              step.title,
                                                          onPress: () {
                                                            if (step.title ==
                                                                StepsContent
                                                                    .sip) {
                                                              context.pushNamed(
                                                                  RoutesName
                                                                      .IntroScreen,
                                                                  params: {
                                                                    Constants
                                                                            .forSIP:
                                                                        'true'
                                                                  });
                                                            } else if (step
                                                                    .title ==
                                                                StepsContent
                                                                    .mip) {
                                                              context.pushNamed(
                                                                  RoutesName
                                                                      .IntroScreen,
                                                                  params: {
                                                                    Constants
                                                                            .forSIP:
                                                                        'false'
                                                                  });
                                                            } else {
                                                              context.pushNamed(
                                                                  step.screenName);
                                                            }
                                                          },
                                                          status: step.status,
                                                          subText:
                                                              'Letraset sheets containing Lorem Ipsum passages, and more recently with desktop',
                                                          // isDisabled: step.title == StepsContent.kyc &&
                                                          // step.status.removeSpace() == '1',
                                                          whatsNextIcon: Icons
                                                              .arrow_forward_ios,
                                                        );
                                                      },
                                                      itemCount:
                                                          advanceStepsList
                                                              .length,
                                                    ),
                                                  ),
                                                  CustomButton(
                                                      titleStr: 'Back to Home',
                                                      horizontalMargin: 16,
                                                      onPress: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        HomeScreen()));
                                                      }),

                                                  // ListTile(
                                                  //   title: Text(
                                                  //     'Call Support',
                                                  //     style: TextStyle(
                                                  //       fontFamily: CustomFonts.nunito,
                                                  //       fontSize: 16.0,
                                                  //       fontWeight: FontWeight.w700,
                                                  //       color: ColorsUtil.blueColor,
                                                  //     ),
                                                  //   ),
                                                  //   onTap: () {
                                                  //     Utils.launchSupportCall();
                                                  //   },
                                                  //   trailing: Icon(
                                                  //     Icons.support_agent,
                                                  //     color: ColorsUtil.blueColor,
                                                  //   ),
                                                  // ),
                                                  // Divider(),
                                                  // ListTile(
                                                  //   title: Text(
                                                  //     'LogOut',
                                                  //     style: TextStyle(
                                                  //       fontFamily: CustomFonts.nunito,
                                                  //       fontSize: 16.0,
                                                  //       fontWeight: FontWeight.w700,
                                                  //       color: ColorsUtil.redColor,
                                                  //     ),
                                                  //   ),
                                                  //   onTap: logOutTap,
                                                  //   trailing: Icon(
                                                  //     Icons.logout,
                                                  //     color: ColorsUtil.redColor,
                                                  //     size: 25.0,
                                                  //   ),
                                                  // ),
                                                  // SizedBox(height: 20),
                                                  // Center(
                                                  //     child: Text(
                                                  //         "Version: ${context.read<AppStateProvider>().appVersion}",
                                                  //         style: TextStyle(
                                                  //           fontSize: 12.0,
                                                  //           fontFamily: CustomFonts.nunito,
                                                  //           fontWeight: FontWeight.w500,
                                                  //         ))),
                                                  // SizedBox(height: 20),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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

    //   CustomPopupMenu(
    //   horizontalMargin: 0.0,
    //   verticalMargin: 0.0,
    //   showArrow: false,
    //   position: PreferredPosition.bottom,
    //   child: Align(
    //     alignment: Alignment.centerRight,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 15),
    //       child: Icon(
    //         Icons.menu,
    //         color: Colors.black,
    //       ),
    //     ),
    //   ),
    //   pressType: PressType.singleClick,
    //   controller: _controller,
    //   menuBuilder: () => Container(
    //     width: ResponsiveWidget.isSmallScreen(context)
    //         ? MediaQuery.of(context).size.width
    //         : 400,
    //     height: MediaQuery.of(context).size.height * .85,
    //     decoration: BoxDecoration(
    //       color: ColorsUtil.white,
    //       borderRadius: BorderRadius.all(
    //           Radius.circular(5.0) //                 <--- border radius here
    //           ),
    //     ),
    //     child: Column(
    //       children: <Widget>[
    //         InkWell(
    //           onTap: () {
    //             context.pushNamed(RoutesName.ProfileDetail);
    //           },
    //           child: Container(
    //             width: MediaQuery.of(context).size.width,
    //             height: 115,
    //             color: ColorsUtil.white,
    //             margin: EdgeInsets.symmetric(horizontal: 16.0),
    //             child: Column(
    //               children: [
    //                 SizedBox(
    //                   height: 24.0,
    //                 ),
    //                 Row(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Padding(
    //                         padding: const EdgeInsets.only(top: 8.0),
    //                         child: LogoWidget(
    //                           size: 45,
    //                           url: userData.profileDetails!.profileUrl,
    //                         ),
    //                       ),
    //                       SizedBox(
    //                         width: 15.0,
    //                       ),
    //                       Expanded(
    //                         child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                               SizedBox(
    //                                 height: 5.0,
    //                               ),
    //                               Text(
    //                                 userData.profileDetails!.fullName,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 textAlign: TextAlign.left,
    //                                 style: TextStyle(
    //                                   fontSize: 20.0,
    //                                   fontFamily: CustomFonts.nunito,
    //                                   fontWeight: FontWeight.w700,
    //                                 ),
    //                               ),
    //                               Text(
    //                                 userData.profileDetails?.email ?? '',
    //                                 textAlign: TextAlign.left,
    //                                 overflow: TextOverflow.ellipsis,
    //                                 style: TextStyle(
    //                                     fontSize: 14.0,
    //                                     fontFamily: CustomFonts.nunito,
    //                                     fontWeight: FontWeight.w400,
    //                                     color: ColorsUtil.lighterGrey),
    //                               ),
    //                               SizedBox(
    //                                 height: 10,
    //                               ),
    //                             ]),
    //                       ),
    //                       Padding(
    //                         padding: const EdgeInsets.only(top: 10.0),
    //                         child: InkWell(
    //                           child: Row(
    //                             children: [
    //                               Icon(
    //                                 Icons.edit_outlined,
    //                                 size: 20.0,
    //                                 color: ColorsUtil.black,
    //                               ),
    //                               SizedBox(
    //                                 width: 6.0,
    //                               ),
    //                               Text(
    //                                 'Edit',
    //                                 style: TextStyle(
    //                                     fontWeight: FontWeight.w700,
    //                                     fontSize: 16.0,
    //                                     fontFamily: CustomFonts.nunito),
    //                               )
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     ]),
    //                 SizedBox(
    //                   height: 15.0,
    //                 ),
    //                 Divider(
    //                   thickness: 1.0,
    //                   height: 2.0,
    //                   color: ColorsUtil.circleGrey,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         Builder(
    //           builder: (context) {
    //             return Expanded(
    //               child: ListView(
    //                 shrinkWrap: true,
    //                 children: [
    //                   ListView.builder(
    //                     physics: NeverScrollableScrollPhysics(),
    //                     shrinkWrap: true,
    //                     padding:
    //                         EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
    //                     itemBuilder: (context, index) {
    //                       final step = stepsList[index];
    //                       return NavBarBoxWidget(
    //                         headingText: step.title,
    //                         onPress: () {
    //                           context.pushNamed(step.screenName);
    //                         },
    //                         status: step.status,
    //                         iconText: index == 0 ? 'Add Money' : 'Edit',
    //                         isDisabled: step.title == StepsContent.kyc &&
    //                             step.status.removeSpace() == '1',
    //                         whatsNextIcon:
    //                             index == 0 ? Icons.add : Icons.edit_outlined,
    //                       );
    //                     },
    //                     itemCount: stepsList.length,
    //                   ),
    //                   Container(
    //                     margin: EdgeInsets.symmetric(horizontal: 15),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text(
    //                           'Advanced Settings',
    //                           textAlign: TextAlign.start,
    //                           style: TextStyle(
    //                             fontFamily: CustomFonts.nunito,
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 18,
    //                           ),
    //                         ),
    //                         FlutterSwitch(
    //                           activeColor: ColorsUtil.blueColor,
    //                           width: 50.0,
    //                           height: 25.0,
    //                           // valueFontSize: 25.0,
    //                           toggleSize: 20.0,
    //                           value: switchValue,
    //                           borderRadius: 30.0,
    //                           // padding: 8.0,
    //                           // showOnOff: true,
    //                           onToggle: (val) {
    //                             // switchValue = val;
    //                             setState(() {
    //                               switchValue = val;
    //                             });
    //                           },
    //                         )
    //                       ],
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 15, vertical: 5),
    //                     child: Divider(),
    //                   ),
    //                   switchValue
    //                       ? ListView.builder(
    //                           physics: NeverScrollableScrollPhysics(),
    //                           shrinkWrap: true,
    //                           padding: EdgeInsets.symmetric(
    //                               vertical: 0, horizontal: 16.0),
    //                           itemBuilder: (context, index) {
    //                             final step = advanceStepsList[index];
    //                             return NavBarBoxWidget(
    //                               headingText: step.title,
    //                               onPress: () {
    //                                 context.pushNamed(step.screenName);
    //                               },
    //                               status: step.status,
    //                               iconText: 'Edit',
    //                               // isDisabled: step.title == StepsContent.kyc &&
    //                               // step.status.removeSpace() == '1',
    //                               whatsNextIcon: Icons.edit_outlined,
    //                             );
    //                           },
    //                           itemCount: advanceStepsList.length,
    //                         )
    //                       : Container(),
    //                   ListTile(
    //                     onTap: () {
    //                       context.pushNamed(RoutesName.Redemption);
    //                     },
    //                     title: Container(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             'Redemption',
    //                             style: TextStyle(
    //                                 fontFamily: CustomFonts.nunito,
    //                                 fontSize: 16.0,
    //                                 fontWeight: FontWeight.w700),
    //                           ),
    //                           SizedBox(height: 15),
    //                           Divider(
    //                             thickness: 1.0,
    //                             height: 2.0,
    //                             color: ColorsUtil.circleGrey,
    //                           ),
    //                         ],
    //                       ),
    //                       margin: EdgeInsets.symmetric(vertical: 5),
    //                       width: double.infinity,
    //                     ),
    //                   ),
    //                   ListTile(
    //                     onTap: () {
    //                       context.pushNamed(RoutesName.Withdraw);
    //                     },
    //                     title: Container(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Text(
    //                             'Withdraw Funds',
    //                             style: TextStyle(
    //                               fontFamily: CustomFonts.nunito,
    //                               fontSize: 16.0,
    //                               fontWeight: FontWeight.w700,
    //                             ),
    //                           ),
    //                           SizedBox(height: 15),
    //                           Divider(
    //                             thickness: 1.0,
    //                             height: 2.0,
    //                             color: ColorsUtil.circleGrey,
    //                           ),
    //                         ],
    //                       ),
    //                       margin: EdgeInsets.symmetric(vertical: 5),
    //                       width: double.infinity,
    //                     ),
    //                   ),
    //                   ListTile(
    //                     title: Theme(
    //                       data: Theme.of(context)
    //                           .copyWith(dividerColor: Colors.transparent),
    //                       child: ExpansionTile(
    //                         tilePadding: EdgeInsets.symmetric(
    //                             horizontal: 0, vertical: 0),
    //                         textColor: Colors.black,
    //                         iconColor: ColorsUtil.dividerColor,
    //                         title: Text(
    //                           'Account Statement',
    //                           textAlign: TextAlign.left,
    //                           style: TextStyle(
    //                             fontSize: 16.0,
    //                             fontFamily: CustomFonts.nunito,
    //                             fontWeight: FontWeight.w700,
    //                           ),
    //                         ),
    //                         children: [
    //                           Align(
    //                             alignment: Alignment.topLeft,
    //                             child: getStatement(),
    //                           ),
    //                           SizedBox(
    //                             height: 15.0,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   if (!Utils.isWeb)
    //                     Column(
    //                       children: [
    //                         Container(
    //                           padding: EdgeInsets.symmetric(
    //                               vertical: 0, horizontal: 16.0),
    //                           child: Row(
    //                             mainAxisAlignment:
    //                                 MainAxisAlignment.spaceBetween,
    //                             children: [
    //                               InkWell(
    //                                 onTap: () {
    //                                   FlyyFlutterPlugin.openFlyyRewardsPage();
    //                                 },
    //                                 child: Container(
    //                                   width: ResponsiveWidget.isSmallScreen(
    //                                           context)
    //                                       ? MediaQuery.of(context).size.width /
    //                                           3.6
    //                                       : 105,
    //                                   height: 92,
    //                                   decoration: BoxDecoration(
    //                                       borderRadius:
    //                                           BorderRadius.circular(7.0),
    //                                       border: Border.all(
    //                                           color: ColorsUtil.blueColor),
    //                                       color: ColorsUtil.blueColor),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.center,
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.center,
    //                                     children: [
    //                                       Image.asset(
    //                                         LocalImages.rewards,
    //                                         width: 30,
    //                                         height: 34,
    //                                       ),
    //                                       SizedBox(
    //                                         height: 12,
    //                                       ),
    //                                       Text(
    //                                         'Rewards',
    //                                         style: TextStyle(
    //                                             fontSize: 13.0,
    //                                             fontFamily: CustomFonts.nunito,
    //                                             fontWeight: FontWeight.w500,
    //                                             color: ColorsUtil.white),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ),
    //                               InkWell(
    //                                 onTap: () {
    //                                   FlyyFlutterPlugin.openFlyyOffersPage();
    //                                 },
    //                                 child: Container(
    //                                   width: ResponsiveWidget.isSmallScreen(
    //                                           context)
    //                                       ? MediaQuery.of(context).size.width /
    //                                           3.6
    //                                       : 105,
    //                                   height: 92,
    //                                   decoration: BoxDecoration(
    //                                       borderRadius:
    //                                           BorderRadius.circular(7.0),
    //                                       border: Border.all(
    //                                           color: ColorsUtil.blueColor),
    //                                       color: ColorsUtil.blueColor),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.center,
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.center,
    //                                     children: [
    //                                       Image.asset(
    //                                         LocalImages.offers,
    //                                         width: 30,
    //                                         height: 34,
    //                                       ),
    //                                       SizedBox(
    //                                         height: 12,
    //                                       ),
    //                                       Text(
    //                                         'Offers',
    //                                         style: TextStyle(
    //                                             fontSize: 13.0,
    //                                             fontFamily: CustomFonts.nunito,
    //                                             fontWeight: FontWeight.w500,
    //                                             color: ColorsUtil.white),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ),
    //                               InkWell(
    //                                 onTap: () {
    //                                   FlyyFlutterPlugin.openFlyyQuizListPage();
    //                                 },
    //                                 child: Container(
    //                                   width: ResponsiveWidget.isSmallScreen(
    //                                           context)
    //                                       ? MediaQuery.of(context).size.width /
    //                                           3.6
    //                                       : 105,
    //                                   height: 92,
    //                                   decoration: BoxDecoration(
    //                                       borderRadius:
    //                                           BorderRadius.circular(7.0),
    //                                       border: Border.all(
    //                                           color: ColorsUtil.blueColor),
    //                                       color: ColorsUtil.blueColor),
    //                                   child: Column(
    //                                     crossAxisAlignment:
    //                                         CrossAxisAlignment.center,
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.center,
    //                                     children: [
    //                                       Image.asset(
    //                                         LocalImages.quiz,
    //                                         width: 30,
    //                                         height: 34,
    //                                       ),
    //                                       SizedBox(
    //                                         height: 12,
    //                                       ),
    //                                       Text(
    //                                         'Quiz',
    //                                         style: TextStyle(
    //                                             fontSize: 13.0,
    //                                             fontFamily: CustomFonts.nunito,
    //                                             fontWeight: FontWeight.w500,
    //                                             color: ColorsUtil.white),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: 7,
    //                         ),
    //                         InkWell(
    //                             onTap: () {
    //                               FlyyFlutterPlugin
    //                                   .openFlyyCustomInviteAndEarnPage(
    //                                       0, '#ffffff');
    //                             },
    //                             child: Padding(
    //                               padding: const EdgeInsets.symmetric(
    //                                   vertical: 5, horizontal: 15),
    //                               child: Image.asset(
    //                                 LocalImages.referBanner,
    //                                 height: 120,
    //                               ),
    //                             )),
    //                       ],
    //                     ),
    //                   ListTile(
    //                     title: Text(
    //                       'Call Support',
    //                       style: TextStyle(
    //                         fontFamily: CustomFonts.nunito,
    //                         fontSize: 16.0,
    //                         fontWeight: FontWeight.w700,
    //                         color: ColorsUtil.blueColor,
    //                       ),
    //                     ),
    //                     onTap: () {
    //                       Utils.launchSupportCall();
    //                     },
    //                     trailing: Icon(
    //                       Icons.support_agent,
    //                       color: ColorsUtil.blueColor,
    //                     ),
    //                   ),
    //                   Divider(),
    //                   ListTile(
    //                     title: Text(
    //                       'LogOut',
    //                       style: TextStyle(
    //                         fontFamily: CustomFonts.nunito,
    //                         fontSize: 16.0,
    //                         fontWeight: FontWeight.w700,
    //                         color: ColorsUtil.redColor,
    //                       ),
    //                     ),
    //                     onTap: logOutTap,
    //                     trailing: Icon(
    //                       Icons.logout,
    //                       color: ColorsUtil.redColor,
    //                       size: 25.0,
    //                     ),
    //                   ),
    //                   SizedBox(height: 20),
    //                   Center(
    //                       child: Text(
    //                           "Version: ${context.read<AppStateProvider>().appVersion}",
    //                           style: TextStyle(
    //                             fontSize: 12.0,
    //                             fontFamily: CustomFonts.nunito,
    //                             fontWeight: FontWeight.w500,
    //                           ))),
    //                   SizedBox(height: 20),
    //                 ],
    //               ),
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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
              ),
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
