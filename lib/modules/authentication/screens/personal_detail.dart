import 'dart:async';

import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:peerbridge/modules/authentication/models/personal_detail.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/steps_widget.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonalDetailScreen extends StatefulWidget {
  const PersonalDetailScreen({Key? key}) : super(key: key);

  @override
  _PersonalDetailScreenState createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var adharController = TextEditingController();

  bool isEmailValid = false;
  bool isEmailError = false;
  bool isPhoneValid = false;
  bool isPhoneError = false;
  bool isAdharValid = false;
  bool isAdharError = false;
  int currentIndex = 0;
  PageController? _controller;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);

    setTextFields();
  }

  setTextFields() {
    final panDetails = context.read<AppStateProvider>().panDetails!;
    nameController.text = panDetails.fullName;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    adharController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  bool checkValidation() {
    if (!emailController.text.isEmailValid) {
      setState(() {
        isEmailError = true;
      });
      return false;
    }
    if (!phoneController.text.isMobileNumberValid) {
      setState(() {
        isPhoneError = true;
      });
      return false;
    }
    if (!adharController.text.isAdharCardValid) {
      setState(() {
        isAdharError = true;
      });
      return false;
    }
    return true;
  }

  Future<void> savePersonalDetails() async {
    if (checkValidation()) {
      var param = Map<String, String>();
      param[ApiParams.pan] =
          context.read<AppStateProvider>().panDetails?.pan ?? '';
      param[ApiParams.fullName] = nameController.text;
      param[ApiParams.email] = emailController.text;
      param[ApiParams.phoneNo] = phoneController.text;
      param[ApiParams.aadharNumber] = adharController.text;
      final provider = context.read<AppStateProvider>();
      provider.personalDetail = PersonalDetail(
        fullName: nameController.text,
        email: emailController.text,
        mobileNo: phoneController.text,
        aadharNo: adharController.text,
      );
      setState(() {
        _isLoading = true;
      });
      var otpSent = await provider.signupSendOTP(param);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (otpSent) {
        context.pushNamed(RoutesName.OTPVerification, params: {
          Constants.fromLogin: "false",
          Constants.mobileNumber: phoneController.text,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Personal Details',
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
                    context.pop();
                  },
                ),
              )
            : null,
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        mainWidget(context)
                        // Header(
                        //   backOnPressed: () {
                        //     context.pop();
                        //   },
                        // ),
                        // Container(
                        //   width: double.infinity,
                        //   height: 60,
                        //   color: Colors.white,
                        //   padding: EdgeInsets.symmetric(horizontal: 15),
                        //   child: Align(
                        //     alignment: Alignment.centerLeft,
                        //     child: Text(
                        //       'Personal Details',
                        //       style: TextStyle(
                        //         fontFamily: CustomFonts.nunito,
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 20,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // StepsWidget(
                        //   currentStep: 1,
                        // ),
                        // Expanded(
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.vertical,
                        //     child: Column(
                        //       children: [
                        //         SizedBox(height: 30),
                        //         mainWidget(context),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        height: screenSize.height,
                        color: ColorsUtil.white,
                        child: Column(
                          children: [
                            Header(
                              backOnPressed: () {
                                context.pop();
                              },
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Container(
                                    width: screenSize.width * .4,
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    constraints: BoxConstraints(maxWidth: 500),
                                    child: Column(
                                      children: [
                                        // SizedBox(height: 30),
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 15),
                                        //   child: Align(
                                        //     alignment: Alignment.centerLeft,
                                        //     child: Text(
                                        //       'Personal Details',
                                        //       style: TextStyle(
                                        //         fontFamily:
                                        //             CustomFonts.nunito,
                                        //         fontWeight: FontWeight.bold,
                                        //         fontSize: 20,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        // SizedBox(height: 20),
                                        mainWidget(context)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SideImageWidget(
                        screenSize: screenSize,
                        controller: _controller!,
                        currentIndex: currentIndex,
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget mainWidget(context) {
    // final provider = Provider.of<AppStateProvider>(context);
    //
    // final panDetails = provider.panDetails;
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputWidget(
                    controller: nameController,
                    heading: 'Name',
                    isEditable: false,
                    titleColor: Colors.grey,
                    textColor: Colors.grey,
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: emailController,
                    //  initialValue: provider.panDetails!.emailId,
                    isValid: isEmailValid,
                    isError: isEmailError,
                    keyboardType: TextInputType.emailAddress,
                    alertStr: isEmailError ? 'Please enter Valid Email ID' : '',
                    leftIcon: Icon(
                      Icons.email,
                      color: ColorsUtil.lightBlack,
                    ),
                    hintStr: 'Email',
                    heading: 'E-Mail',
                    onChange: (String input) {
                      //  provider.panDetails!.emailId = input;
                      setState(() {
                        isEmailValid = input.isEmailValid;
                        isEmailError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: phoneController,
                    isValid: isPhoneValid,
                    isError: isPhoneError,
                    keyboardType: TextInputType.phone,
                    alertStr:
                        'Please edit the number manually if it is incorrect!',
                    leftIcon: Icon(
                      Icons.phone_android_outlined,
                      color: ColorsUtil.lightBlack,
                    ),
                    hintStr: 'Phone Number',
                    heading: 'Phone Number',
                    maxLength: 10,
                    onChange: (String input) {
                      setState(() {
                        isPhoneValid = input.isMobileNumberValid;
                        isPhoneError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: adharController,
                    hintStr: 'Aadhar Card Number',
                    heading: 'Aadhar Card Number',
                    alertColor: ColorsUtil.lightBlack,
                    alertStr:
                        'In case of non-individuals please enter aadhar card number of authorised signatory',
                    isValid: isAdharValid,
                    isError: isAdharError,
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    onChange: (String input) {
                      setState(() {
                        isAdharValid = input.isAdharCardValid;
                        isAdharError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomButton(
              titleStr: 'Continue',
              onPress: savePersonalDetails,
            ),
          ),
          // SizedBox(height: 20),
        ],
      ),
    );
  }
}

class SideImageWidget extends StatefulWidget {
  SideImageWidget(
      {required this.screenSize,
      required this.controller,
      required this.currentIndex});

  final Size screenSize;

  int currentIndex;
  PageController controller;

  @override
  _SideImageWidgetState createState() => _SideImageWidgetState();
}

class _SideImageWidgetState extends State<SideImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.screenSize.width * .44,
      color: ColorsUtil.blueColor,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.2,
            child: PageView.builder(
              controller: widget.controller,
              itemCount: content.length,
              onPageChanged: (int index) {
                setState(() {
                  widget.currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Stack(
                  children: [
                    Container(
                      color: ColorsUtil.blueColor,
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image(
                              height: MediaQuery.of(context).size.height * 0.40,
                              width: double.infinity,
                              image: AssetImage(content[i].image),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: i == 1,
                                  child: Icon(
                                    Icons.check,
                                    color: ColorsUtil.white,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  content[i].title1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: i == 1 ? 20 : 24,
                                      fontFamily: CustomFonts.nunito,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsUtil.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: i != 0,
                                  child: Icon(
                                    Icons.check,
                                    color: ColorsUtil.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  content[i].title2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: i == 1 ? 20 : 16,
                                      fontFamily: i == 1
                                          ? CustomFonts.nunito
                                          : CustomFonts.nunito,
                                      fontWeight: i == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: ColorsUtil.white),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: i == 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: ColorsUtil.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    content[i].title3,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: CustomFonts.nunito,
                                        fontWeight: FontWeight.bold,
                                        color: ColorsUtil.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                content.length,
                (index) => InkWell(
                    onTap: () {
                      widget.controller.jumpToPage(index);
                    },
                    child: buildDot(index, context)),
              ),
            ),
          ),
        ],
      ),

      // Stack(
      //   children: [
      //     Container(
      //       color: ColorsUtil.greenColor,
      //     ),
      //     Center(
      //       child: Expanded(
      //         child: SingleChildScrollView(
      //           child: Container(
      //             margin: EdgeInsets.symmetric(vertical: 15),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 Image(
      //                   width: 417,
      //                   height: 326,
      //                   // fit: BoxFit.cover,
      //                   image:
      //                       AssetImage(LocalImages.onboarding2),
      //                 ),
      //                 SizedBox(
      //                   height: 40,
      //                 ),
      //                 Text('Earn up to 13% p.a',
      //                     style: TextStyle(
      //                         fontFamily: CustomFonts.nunito,
      //                         fontSize: 24,
      //                         color: ColorsUtil.white,
      //                         fontWeight: FontWeight.w700)),
      //                 SizedBox(
      //                   height: 20,
      //                 ),
      //                 Text(
      //                     '1. Passive Income. 2. Low Volatility \n3. Beat Inflation',
      //                     textAlign: TextAlign.center,
      //                     style: TextStyle(
      //                       fontFamily: CustomFonts.roboto,
      //                       fontWeight: FontWeight.w400,
      //                       fontSize: 16,
      //                       color: ColorsUtil.white,
      //                     )),
      //                 SizedBox(
      //                   height: 60,
      //                 ),
      //                 Container(
      //                   child: Row(
      //                     mainAxisAlignment:
      //                         MainAxisAlignment.center,
      //                     children: List.generate(
      //                       3,
      //                       (index) => buildDot(index, context),
      //                     ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Padding buildDot(int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Image(
        width: 10,
        height: 10,
        color: ColorsUtil.white,
        image: AssetImage(widget.currentIndex == index
            ? LocalImages.selected_circle
            : LocalImages.page_unselected),
      ),
    );
  }
}

class OnboardingContent {
  String image;
  String title1;
  String title2;
  String title3;

  OnboardingContent(
      {required this.image,
      required this.title1,
      required this.title2,
      required this.title3});
}

List<OnboardingContent> content = [
  // OnboardingContent(
  //   image: LocalImages.onboarding1,
  //   title1: "Delivering Financial\nHappiness",
  //   title2: "RBI Registered NBFC",
  //   title3: "",
  // ),
  OnboardingContent(
    image: LocalImages.onboarding2,
    title1: "Earn up to 13% p.a",
    title2: "1. Passive Income  2. Low Volatility\n3. Beat Inflation",
    title3: "",
  ),
  OnboardingContent(
    image: LocalImages.onboarding3,
    title1: "Invest up to 50 Lakh",
    title2: "Diversity in units up to 1000",
    title3: "Monthly Income",
  ),
];
