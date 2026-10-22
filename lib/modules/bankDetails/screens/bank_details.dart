import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/bankDetails/models/bank_detail.dart';
import 'package:peerbridge/modules/bankDetails/models/penny_drop_response.dart';
import 'package:peerbridge/modules/bankDetails/models/user_bank_detail.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/modules/bankDetails/screens/penny_drop_screen.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/supporting_file/api_calling.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/global_data.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/user_preferences.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/steps_widget.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:universal_html/html.dart';

class BankDetailScreen extends StatefulWidget {
  const BankDetailScreen({Key? key}) : super(key: key);

  @override
  _BankDetailScreenState createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen> {
  var nameController = TextEditingController();
  var ifscController = TextEditingController();
  var acNoController = TextEditingController();
  var bankController = TextEditingController();
  var branchController = TextEditingController();

  bool isIFSCValid = false;
  bool isIFSCError = false;
  bool isAcNoValid = false;
  bool isAcNoError = false;
  bool isPopupShown = false;
  BankDetail? bankDetails;
  String? id;

  bool _isLoading = false;
  var isOtpVerified = false;
  // final storage = window.sessionStorage;

  @override
  void initState() {
    super.initState();
    final userData = context.read<AppStateProvider>().userDetails;
    nameController.text = userData?.profileDetails?.fullName ?? '';
    context.read<AppStateProvider>().getFlyyWebToken();
    if (Utils.isWeb) {
      getReferValuesFromSession();
      setWylthReferWeb();
    }
  }
  Future<void> getReferValuesFromSession() async {
    // id = storage['customerId'];
  }

  Future<void> setWylthReferWeb() async {
    await context.read<AppStateProvider>().setWylthyReferWeb(id ?? '');
    // storage.clear();
  }

  bool checkValidation() {
    if (!ifscController.text.isIFSCValid) {
      setState(() {
        isIFSCError = true;
      });
      return false;
    }
    if (!acNoController.text.isBAccountValid) {
      setState(() {
        isAcNoError = true;
      });
      return false;
    }

    if (bankDetails == null) {
      Utils.showAlert(context: context, msg: LanguageHelper.textValidIfsc);
      return false;
    }

    return true;
  }

  /// Fetch Bank details related to IFSC code
  void fetchBankDetail() async {
    setLoading(true);
    var bankDetail = await context
        .read<AppStateProvider>()
        .getBankDetails(ifscController.text);
    setLoading(false);

    setState(() {
      bankDetails = bankDetail;
      bankController.text = bankDetail?.bankName ?? '';
      branchController.text = bankDetail?.branch ?? '';
    });
  }

  /// Save user Bank Details
  void saveBankDetails() async {
    if (checkValidation()) {
      navigateToPennyDrop();
    }
  }

  void navigateToPennyDrop() {
    context.read<AppStateProvider>().userBankDetail = UserBankDetail(
      acountNumber: acNoController.text,
      fullName: nameController.text,
      ifscCode: ifscController.text,
      bankName: bankController.text,
      branchnName: branchController.text,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PennyDropScreen(),
      ),
    ).then(
      (isPennyDropError) =>
          {handlePennyDrop(isPennyDropError as PennyDropRes?)},
    );
  }

  void handlePennyDrop(PennyDropRes? status) {
    if (status == null) return;

    final userStage =
        context.read<AppStateProvider>().userDetails?.userStage ?? 1;
    if (status.isSuccess && userStage > 3) {
      context.pop();
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          // <-- SEE HERE
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15.0),
          ),
        ),
        builder: (BuildContext context) =>
            PennyDropPopupDialog(context, status, nameController.text),
      );
      // showBottomSheet(
      //   context: context,
      //   builder: (BuildContext context) =>
      //       PennyDropPopupDialog(context, nameController.text),
      // );
    }
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification() async {
    if (!checkValidation()) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationWidget(
        onFailed: () {
          //do something
        },
        onVerified: () {
          setState(() {
            isOtpVerified = true;
          });
          navigateToPennyDrop();
        },
      ),
    );
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final userStage =
        context.read<AppStateProvider>().userDetails?.userStage ?? 1;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Bank Details',
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
                ? Column(
                    children: [
                      mainWidgets(context)
                      // Header(
                      //   isBackBtnVisible: userStage > 3,
                      //   backOnPressed: () {
                      //     context.pop();
                      //   },
                      //   isLogout: userStage < 3,
                      // ),
                      // Container(
                      //   width: double.infinity,
                      //   height: 60,
                      //   color: Colors.white,
                      //   padding: EdgeInsets.symmetric(horizontal: 15),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //       'Bank Details',
                      //       style: TextStyle(
                      //         fontFamily: CustomFonts.nunito,
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 20,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // StepsWidget(
                      //   currentStep: 2,
                      // ),
                      // Expanded(
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.vertical,
                      //     child: Column(
                      //       children: [
                      //         SizedBox(height: 10),
                      //         mainWidgets(context),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                : Container(
                    child: Row(
                      children: [
                        Container(
                          width: screenSize.width * .56,
                          color: ColorsUtil.white,
                          child: Column(
                            children: [
                              Header(
                                isBackBtnVisible: userStage > 3,
                                backOnPressed: () {
                                  context.pop();
                                },
                                isLogout: userStage < 3,
                              ),
                              SizedBox(height: 50),
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      children: [
                                        // StepsWidget(
                                        //   currentStep: 2,
                                        // ),
                                        // SizedBox(height: 30),
                                        // Padding(
                                        //   padding: const EdgeInsets.symmetric(
                                        //       horizontal: 15),
                                        //   child: Align(
                                        //     alignment: Alignment.centerLeft,
                                        //     child: Text(
                                        //       'Bank Details',
                                        //       style: TextStyle(
                                        //         fontFamily: CustomFonts.nunito,
                                        //         fontWeight: FontWeight.bold,
                                        //         fontSize: 20,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        mainWidgets(context),
                                      ],
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
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  InputWidget(
                    controller: nameController,
                    heading: 'Full Name',
                    isEditable: false,
                    titleColor: Colors.grey,
                    textColor: Colors.grey,
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: ifscController,
                    isValid: isIFSCValid,
                    autoCaps: true,
                    isError: isIFSCError,
                    maxLength: 11,
                    textCapitalization: TextCapitalization.characters,
                    rightIcon: InkWell(
                      child: Icon(
                        Icons.approval_outlined,
                      ),
                      onTap: () {
                        if (ifscController.text.isIFSCValid) {
                          fetchBankDetail();
                        }
                      },
                    ),
                    alertStr: isIFSCError ? 'Please enter Valid IFSC Code' : '',
                    hintStr: 'IFSC Code',
                    heading:
                        'IFSC Code', //ifscController.text.isEmpty ? '' : 'IFSC Code',
                    onChange: (String input) {
                      setState(() {
                        isIFSCValid = input.isIFSCValid;
                        isIFSCError = false;
                        if (input.isIFSCValid) {
                          fetchBankDetail();
                        }
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: acNoController,
                    isValid: isAcNoValid,
                    isError: isAcNoError,
                    hintStr: 'Account Number',
                    heading: 'Account Number',
                    // acNoController.text.isEmpty ? '' : 'Account Number',
                    keyboardType: TextInputType.number,
                    maxLength: 18,
                    onChange: (String input) {
                      setState(() {
                        isAcNoValid = input.isBAccountValid;
                        isAcNoError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Visibility(
                    visible: bankDetails != null,
                    child: Column(
                      children: [
                        InputWidget(
                          controller: bankController,
                          heading: 'Bank Name',
                          isEditable: false,
                          titleColor: Colors.grey,
                          textColor: Colors.grey,
                        ),
                        SizedBox(height: 30),
                        InputWidget(
                          controller: branchController,
                          heading: 'Branch Name',
                          isEditable: false,
                          titleColor: Colors.grey,
                          textColor: Colors.grey,
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomButton(
            titleStr: 'Continue',
            onPress: () {
              final userStage =
                  context.read<AppStateProvider>().userDetails?.userStage ?? 1;
              if (!isOtpVerified && userStage > 3) {
                startOtpVerification();
              } else {
                saveBankDetails();
              }
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

Widget PennyDropPopupDialog(
    BuildContext context, PennyDropRes pennyDropRes, String name) {
  bool isChecked = false;
  bool pressedFirst = false;
  bool pressedSecond = false;
  var screenSize = MediaQuery.of(context).size;

  return Container(
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
          topLeft: Radius.circular(40.0),
          bottomLeft: Radius.circular(40.0)),
    ),
    child: Container(
      child: Container(
        //290,
        width: ResponsiveWidget.isSmallScreen(context)
            ? screenSize.width * .8
            : screenSize.width * .35, //320,// height: 290,
        // width: 320,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   height: 15.0,
            // ),
            Image.asset(
              LocalImages.caution_icon,
              width: 44,
              height: 35,
              color: ColorsUtil.blueColor,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Penny Drop process was Unsuccessful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: CustomFonts.nunito,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              // '$name',
              '${name},${pennyDropRes.message}',
              maxLines: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: CustomFonts.nunito,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  height: 1.4),
            ),
            SizedBox(
              height: 15.0,
            ),
            // CustomButton(
            //   leftIcon: Icon(
            //     Icons.support_agent,
            //     color: ColorsUtil.blueColor,
            //   ),
            //   //   borderColor: ColorsUtil.greenColor,
            //   titleStr: 'Call Helpline',
            //   bgColor: ColorsUtil.white,
            //   textColor: ColorsUtil.blueColor,
            //   onPress: () {
            //     Utils.launchSupportCall();
            //   },
            // ),
            // SizedBox(
            //   height: 10.0,
            // ),
            CustomButton(
              borderColor: ColorsUtil.blueColor,
              titleStr: 'Dismiss',
              bgColor: ColorsUtil.blueColor,
              textColor: ColorsUtil.white,
              onPress: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
  //   AlertDialog(
  //   shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(5.0),
  //       side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
  //   title: Container(
  //     //290,
  //     width: ResponsiveWidget.isSmallScreen(context)
  //         ? screenSize.width * .8
  //         : screenSize.width * .35, //320,// height: 290,
  //     // width: 320,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         SizedBox(
  //           height: 15.0,
  //         ),
  //         Image.asset(
  //           LocalImages.red_alert,
  //           width: 44,
  //           height: 38,
  //         ),
  //         SizedBox(
  //           height: 16.0,
  //         ),
  //         Text(
  //           'Penny Drop process was Unsuccessful!',
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //               color: Colors.black,
  //               fontFamily: CustomFonts.nunito,
  //               fontSize: 16.0,
  //               fontWeight: FontWeight.w700),
  //         ),
  //         SizedBox(
  //           height: 10.0,
  //         ),
  //         Text(
  //           '${name},${pennyDropRes.message}',
  //           maxLines: 4,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //               color: Colors.black,
  //               fontFamily: CustomFonts.nunito,
  //               fontSize: 14.0,
  //               fontWeight: FontWeight.w400,
  //               height: 1.4),
  //         ),
  //         SizedBox(
  //           height: 10.0,
  //         ),
  //         CustomButton(
  //           leftIcon: Icon(
  //             Icons.support_agent,
  //             color: ColorsUtil.blueColor,
  //           ),
  //           //   borderColor: ColorsUtil.greenColor,
  //           titleStr: 'Call Helpline',
  //           bgColor: ColorsUtil.white,
  //           textColor: ColorsUtil.blueColor,
  //           onPress: () {
  //             Utils.launchSupportCall();
  //           },
  //         ),
  //         SizedBox(
  //           height: 10.0,
  //         ),
  //         CustomButton(
  //           borderColor: ColorsUtil.blueColor,
  //           titleStr: 'Dismiss',
  //           bgColor: ColorsUtil.white,
  //           textColor: ColorsUtil.blueColor,
  //           onPress: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ],
  //     ),
  //   ),
  //   actions: <Widget>[],
  // );
}
