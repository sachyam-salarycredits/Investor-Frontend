import 'dart:io';

import 'package:Monexo/language/language_en.dart';
import 'package:Monexo/modules/onboardingSteps/models/cashFree_details.dart';
import 'package:Monexo/modules/onboardingSteps/models/cashfree_web_token_response.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/modules/onboardingSteps/screens/fund_transfer_process_screen.dart';
import 'package:Monexo/supporting_file/cashfree_api.dart';
import 'package:Monexo/supporting_file/api_calling.dart';
import 'package:Monexo/utils/api_constant.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/enums.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/image_picker.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/user_preferences.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/checkbox_widget.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/input_widget.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../supporting_file/appsFlyerSdk.dart';
import 'package:Monexo/modules/bankDetails/screens/welcome_screen.dart';

import '../../../utils/constants.dart';

class ChequeDepositScreen extends StatefulWidget {
  const ChequeDepositScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ChequeDepositScreenState createState() => _ChequeDepositScreenState();
}

class _ChequeDepositScreenState extends State<ChequeDepositScreen> {
  String? fileName;
  PlatformFile? selectedFile;

  var iFSCCodeController = TextEditingController();
  var accountNoController = TextEditingController();
  var chequeNoController = TextEditingController();
  var amountController = TextEditingController();

  PaymentOptions selectedPaymentMode = CashFreeApi.paymentTypes.first;

  bool isAmountValid = false;
  bool isAmountError = false;
  bool isChequeValid = false;
  bool isChequeError = false;

  bool _isLoading = false;
  bool isBankCodeAvailable = true;

  @override
  void initState() {
    super.initState();
    amountController.text = '10000';

    // getCashFreeToken();
    final userData = context.read<AppStateProvider>().userDetails;
    iFSCCodeController.text = userData?.bankAccountDetails?.ifscCode ?? '';
    accountNoController.text =
        userData?.bankAccountDetails?.accountNumber ?? '';
  }

  @override
  void dispose() {
    iFSCCodeController.dispose();
    iFSCCodeController.dispose();
    accountNoController.dispose();
    chequeNoController.dispose();
    amountController.dispose();
    super.dispose();
    // Clean up the controller when the widget is disposed.
  }

  bool checkValidation() {
    if (chequeNoController.text.length < 6) {
      setState(() {
        isChequeError = true;
      });
      return false;
    }
    if ((Utils.isWeb && selectedFile == null) ||
        (!Utils.isWeb && fileName == null)) {
      setState(() {
        isAmountError = true;
        Utils.showAlert(context: context, msg: "Please upload the Cheque.");
      });
      return false;
    }

    if (amountController.text.doubleValue() < 5000 ||
        amountController.text.doubleValue() > 1000000) {
      setState(() {
        isAmountError = true;
        Utils.showAlert(
            context: context, msg: "Amount should be at least 5000");
      });
      return false;
    }

    return true;
  }

  makePayment() {
    if (checkValidation()) {
      try {
        if (amountController.text.doubleValue() < 25000 &&
            context
                .read<AppStateProvider>()
                .userFundTransferDetails!
                .totalFundsTransferred!
                .statement
                .isEmpty) {
          Utils.showAlert(
              context: context,
              msg:
                  "You are adding funds for first time, Please add at least 25000 rupees");
        }
      } catch (e) {}
      makeChequePayment();
    }
  }

  Future<void> openCamera() async {
    var pickedImg = await ImgPicker.pickAndCropFromCamera();
    if (pickedImg != null) {
      setState(() {
        fileName = pickedImg.path;
      });
    }
  }

  Future<void> openFiles() async {
    final filePicked = await Utils.pickFile(
        allowedExtensions: ["pdf", "png", "jpg", "jpeg"],
        fileType: FileType.custom);
    if (filePicked == null) return;
    debugPrint('file selected');
    setState(() {
      fileName = filePicked.name;
      selectedFile = filePicked;
    });
  }

  /// Make payment using Cheque
  Future<void> makeChequePayment() async {
    setLoading(true);
    var ip = await Utils.getIpAddress();

    var param = Map<String, String>();
    param[ApiParams.customerId] = (context.read<AppStateProvider>().customerId);
    param[ApiParams.chequeNumber] = chequeNoController.text;
    param[ApiParams.enterAmount] = amountController.text;
    param[ApiParams.ip] = ip;
    var files;
    if (Utils.isWeb || selectedFile != null) {
      files = Map<String, PlatformFile>();
      files[ApiParams.file] = selectedFile ?? "";
    } else {
      files = Map<String, String>();
      files[ApiParams.file] = fileName ?? "";
    }
    var chequeRes = await context
        .read<AppStateProvider>()
        .chequeFundTransfer(param, files, (selectedFile != null));
    setLoading(false);
    if (chequeRes) {
      selectedFile = null;
      fileName = '';
      context.pop();
      var value = Map<String, dynamic>();
      value["af_revenue"] = amountController.text;
      value["af_currency"] = "INR";
      // AFSdk.logEvent(AFSdk.af_fundTransfer, value);
      // Utils.showToast(msg: LanguageHelper.textFundTransfer);
      context.pushNamed(RoutesName.FundTransferSuccessScreen, params: {
        Constants.amount: amountController.text,
      });
    }
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
    });
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
                  'Cheque Deposit',
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
        body: MonexoLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Container(
                    margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
                    child: Column(
                      children: [
                        mainWidgets(context),
                      ],
                    ))
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
                            SizedBox(height: 50),
                            Expanded(
                              child: Container(
                                child: Center(
                                  child: Container(
                                    // color: ColorsUtil.redColor,
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    margin: EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 30),
                                        // Padding(
                                        //   padding:
                                        //       const EdgeInsets.symmetric(
                                        //           horizontal: 15),
                                        //   child: Align(
                                        //     alignment: Alignment.centerLeft,
                                        //     child: Text(
                                        //       'PAN Verification',
                                        //       style: TextStyle(
                                        //         fontFamily:
                                        //             CustomFonts.nunito,
                                        //         fontWeight: FontWeight.bold,
                                        //         fontSize: 20,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                        mainWidgets(context)
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
  }

  Widget mainWidgets(BuildContext context) {
    var fundDetails =
        Provider.of<AppStateProvider>(context).userFundTransferDetails;
    bool isFundExceeded =
        (fundDetails?.totalFundsTransferred?.transactionAmount ?? 0) >
                1000000 ||
            amountController.text.doubleValue() > 1000000;
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      amountWidget(),
                      SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          AmountTabsWidget(
                            title: 1000,
                            ontap: () {
                              int amount;
                              if (amountController.text.isEmpty) {
                                amount = 0;
                              } else {
                                amount = int.parse(amountController.text);
                              }
                              amount = amount + 1000;
                              amountController.text = amount.toString();
                            },
                          ),
                          AmountTabsWidget(
                            title: 5000,
                            ontap: () {
                              int amount;
                              if (amountController.text.isEmpty) {
                                amount = 0;
                              } else {
                                amount = int.parse(amountController.text);
                              }
                              amount = amount + 5000;
                              amountController.text = amount.toString();
                            },
                          ),
                          AmountTabsWidget(
                            title: 10000,
                            ontap: () {
                              int amount;
                              if (amountController.text.isEmpty) {
                                amount = 0;
                              } else {
                                amount = int.parse(amountController.text);
                              }

                              amount = amount + 10000;
                              amountController.text = amount.toString();
                            },
                          ),
                          AmountTabsWidget(
                            title: 50000,
                            ontap: () {
                              int amount;
                              if (amountController.text.isEmpty) {
                                amount = 0;
                              } else {
                                amount = int.parse(amountController.text);
                              }
                              print(amount);
                              amount = amount + 50000;
                              amountController.text = amount.toString();
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      InputWidget(
                        controller: chequeNoController,
                        hintStr: 'Cheque Number',
                        heading: 'Cheque Number',
                        isError: isChequeError,
                        isValid: isChequeValid,
                        keyboardType: TextInputType.number,
                        horizontalMargin: 0,
                        maxLength: 6,
                        onChange: (String input) {
                          setState(() {
                            isChequeValid =
                                input.length == 6 && input.isValidChequeNumber;
                            isChequeError = false;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      InkWell(
                        onTap: () async {
                          if (Utils.isWeb) {
                            openFiles();
                          } else {
                            showSourceDialog();
                          }
                        },
                        child: Container(
                          child: DottedBorder(
                            color: ColorsUtil.blueColor,
                            borderType: BorderType.RRect,
                            radius: Radius.circular(5),
                            strokeWidth: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                color: ColorsUtil.lightestGrey,
                              ),
                              height: 52,
                              width: double.infinity,
                              child: fileName != null
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Container(
                                          width: 300,
                                          child: Text(
                                            fileName.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16.0,
                                                color: ColorsUtil.black),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Image.asset(
                                          LocalImages.upload,
                                          width: 16,
                                          height: 16,
                                          color: ColorsUtil.blueColorText,
                                        ),
                                        SizedBox(
                                          width: 14,
                                        ),
                                        Text(
                                          'Upload Cheque',
                                          style: TextStyle(
                                              fontFamily: CustomFonts.nunito,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16.0,
                                              color: ColorsUtil.blueColor),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Formats Accepted: PDF, PNG, JPG',
                              style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.0,
                                  color: ColorsUtil.lightBlack),
                            ),
                            IconButton(
                              icon: Icon(Icons.help_outline),
                              onPressed: showChequeHelpDialog,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Visibility(
                        visible: isFundExceeded,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                              color: ColorsUtil.rewardRedContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RotatedBox(
                                quarterTurns: 2,
                                child: Icon(
                                  Icons.info,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your total funding amount has crossed ₹ 10 Lakh. Please follow the instructions, fill the document and upload it.',
                                      maxLines: 3,
                                      softWrap: true,
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            context.pushNamed(
                                                RoutesName.FundTransferProcess);
                                          },
                                          child: Text(
                                            'Complete this process now',
                                            style: TextStyle(
                                              fontSize: 15,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: CustomFonts.nunito,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_right,
                                          size: 21,
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CustomButton(
                titleStr: 'Deposit Money',
                horizontalMargin: 0,
                isDisable: (!isBankCodeAvailable),
                onPress: makePayment,
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  context.pushNamed(RoutesName.HomeScreen);
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: CustomFonts.nunito,
                    color: ColorsUtil.greenText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showSourceDialog() {
    var screenSize = MediaQuery.of(context).size;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
            title: Container(
              width: ResponsiveWidget.isSmallScreen(context)
                  ? screenSize.width * .8
                  : screenSize.width * .35,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    'Select Source Type',
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: CustomFonts.nunito,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          openCamera();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera,
                              size: 60,
                              color: ColorsUtil.lighterGrey,
                            ),
                            Text('Camera',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          openFiles();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder,
                              size: 60,
                              color: ColorsUtil.lighterGrey,
                            ),
                            Text('Files',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: CustomFonts.nunito,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  CustomButton(
                    horizontalMargin: 5,
                    borderColor: ColorsUtil.lightGrey,
                    titleStr: 'Cancel',
                    bgColor: ColorsUtil.white,
                    textColor: ColorsUtil.lightGrey,
                    onPress: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
  }

  void showChequeHelpDialog() {
    var screenSize = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title:
                const Text('Credentials and guidelines for filling the Cheque',
                    style: TextStyle(
                        // fontFamily: CustomFonts.nunito,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700)),
            content: Container(
              width: screenSize.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Table(
                      border: TableBorder.all(),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text('Account Name',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text(
                                'Monexo Fintech - Lender Funding Escrow Account',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Account Number',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('10000781341',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text('Account Type',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text('Current Account',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Bank Name',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IDFC Bank Limited',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IFS Code',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('IDFB0040101',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        TableRow(children: [
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('MICR Code',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('400751002',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Text('Bank Address',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6.0),
                            child: const Text(
                                'IDFC Bank Limited, Naman Chambers, C-32, G-Block, Bandra-Kurla Complex, Bandra East, MUMBAI-400051',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  // fontFamily: CustomFonts.nunito
                                )),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Please note the following:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                        'The transfer of the funds for cheque deposit should be from the bank account mentioned above.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                        'As the transfer of funds is made by cheque, you need to provide your cheque number and upload the scanned image of your cheque. The funds will be credited to your account after clearance of your cheque proceeds.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          // fontFamily: CustomFonts.nunito
                        ))
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: const Text("Done",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        // fontFamily: CustomFonts.nunito
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // your code
                  })
            ],
          );
        });
  }

  Widget amountWidget() {
    return InputWidget(
      prefixText: '₹ ',
      initialValue: '1000',
      controller: amountController,
      keyboardType: TextInputType.number,
      isValid: isAmountValid,
      alertColor: Colors.red,
      alertStr: "",
      isError: isAmountError,
      hintStr: 'Enter Amount',
      heading: 'Enter Amount',
      horizontalMargin: 0,
      onChange: (String input) {
        setState(() {
          isAmountValid = input.doubleValue() >= 5000;
          isAmountError = false;
        });
      },
    );
  }
}

class AmountTabsWidget extends StatelessWidget {
  AmountTabsWidget({Key? key, required this.title, required this.ontap})
      : super(key: key);

  int title;
  Function() ontap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        // height: 35,
        width: 80,
        decoration: BoxDecoration(
          color: ColorsUtil.greenDepositScreenText.withOpacity(.2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '+${title.toString()}',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: CustomFonts.nunito,
                  fontSize: 13,
                  color: ColorsUtil.blackish),
            ),
          ),
        ),
      ),
    );
  }
}
