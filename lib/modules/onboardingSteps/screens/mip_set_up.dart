import 'package:Monexo/language/language_en.dart';
import 'package:Monexo/modules/onboardingSteps/models/mip_details.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/utils/api_constant.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/checkbox_widget.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/otp_verification.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../routes_management/routes_list.dart';
import '../../../supporting_file/appsFlyerSdk.dart';

class MIPSetup extends StatefulWidget {
  @override
  _MIPSetupState createState() => _MIPSetupState();
}

class _MIPSetupState extends State<MIPSetup> {
  int selectedIndex = -1;
  bool isDonateSelected = false;
  List<MipDetails>? mipDetailList;
  OldMipDetail? userMipDetails;
  MipDetails? selectedOption;
  String? selectedCause;
  MipPartner? selectedPartner;

  MipDetails? donationObject;

  List<String> causeList = [];
  List<MipPartner> partnerList = [];

  var donationId = 5;
  bool switchValue = true;

  var _isLoader = false;
  var isOtpVerified = false;

  @override
  void initState() {
    super.initState();
    getMipDetails();
    getUserMipDetails();
  }

  /// Fetch Mip Details
  Future<void> getMipDetails() async {
    setLoading(true);
    var mipList = await context.read<AppStateProvider>().getMipDetails();
    setLoading(false);

    if (mipList != null) {
      setState(() {
        mipDetailList = mipList;
        donationObject =
            mipList.where((element) => element.id == donationId).first;
        if (donationObject != null) {
          causeList = donationObject?.partnerList
                  ?.map((partner) => partner.causeName ?? '')
                  .toSet()
                  .toList() ??
              [];
        }
      });
      setPreviousMipDetails();
    }
  }

  /// Fetch Mip Details
  Future<void> getUserMipDetails() async {
    setLoading(true);
    var mipDetail = await context.read<AppStateProvider>().getPreviousMip();
    setLoading(false);

    if (mipDetail != null) {
      setState(() {
        userMipDetails = mipDetail;
        switchValue = mipDetail.enable;
      });
      setPreviousMipDetails();
    }
  }

  void setPreviousMipDetails() {
    if (userMipDetails != null && mipDetailList != null) {
      setState(() {
        selectedOption = mipDetailList
            ?.where((element) => userMipDetails?.mipOptionId == element.id)
            .first;
        selectedIndex = (selectedOption?.id ?? 0) - 1;
        isDonateSelected = selectedOption?.id == donationId;
        if (isDonateSelected) {
          selectedPartner = donationObject?.partnerList
              ?.where((element) =>
                  userMipDetails?.mipPartnerId == element.mipPartnerId)
              ?.first;
          selectedCause = selectedPartner?.causeName ?? '';
          partnerList = donationObject?.partnerList
                  ?.where((element) => selectedCause == element.causeName)
                  .toList() ??
              [];
        }
      });
    }
  }

  /// Fetch Mip Details
  Future<void> saveMipDetails() async {
    if (checkValidation()) {
      setLoading(true);
      var param = Map<String, dynamic>();
      param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
      param[ApiParams.mipOptionId] = selectedOption?.id ?? '0';
      param[ApiParams.mipPartnerId] = selectedPartner?.mipPartnerId ?? '';
      var saveResp =
          await context.read<AppStateProvider>().saveMipDetails(param);
      setLoading(false);
      if (saveResp) {
        AFSdk.logEvent(AFSdk.af_mip, null);
        AFSdk.logEvent(AFSdk.af_redemption, null);
        AFSdk.logEvent(AFSdk.af_register, null);
        AFSdk.logEvent(AFSdk.af_ekyc, null);
        AFSdk.logEvent(AFSdk.af_validateAccount, null);
        Utils.showAlert(
            context: context,
            msg: LanguageHelper.textMipSaved,
            onTap: () async {
              await context.read<AppStateProvider>().getCustomerDetails();
              context.pop();
            });
      }
    }
  }

  /// Update Mip Switch
  Future<void> updateMipSwitch() async {
    setLoading(true);
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.enable] = switchValue;
    var updateSwitch =
        await context.read<AppStateProvider>().updateMipSwitch(param);
    setLoading(false);
    setState(() {
      isOtpVerified = false;
    });
    if (updateSwitch) {
      getUserMipDetails();
      context.read<AppStateProvider>().getCustomerDetails();
    } else {
      if (userMipDetails != null) {
        setState(() {
          switchValue = userMipDetails!.enable;
        });
      }
    }
  }

  bool checkValidation() {
    if (selectedOption == null) {
      Utils.showAlert(context: context, msg: LanguageHelper.textSelectOption);
      return false;
    }
    if (selectedOption?.id == donationId) {
      if (selectedCause == null) {
        Utils.showAlert(context: context, msg: LanguageHelper.textSelectCause);
        return false;
      }
      if (selectedPartner == null) {
        Utils.showAlert(
            context: context, msg: LanguageHelper.textSelectPartnerName);
        return false;
      }
    }
    return true;
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification(bool isSwitch) async {
    if (!isSwitch && !checkValidation()) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationWidget(
        onFailed: () {
          //do something
          if (userMipDetails != null) {
            setState(() {
              switchValue = userMipDetails!.enable;
            });
          }
        },
        onVerified: () {
          if (isSwitch) {
            updateMipSwitch();
          } else {
            setState(() {
              isOtpVerified = true;
            });
            saveMipDetails();
          }
        },
      ),
    );
  }

  void setLoading(loading) {
    setState(() {
      _isLoader = loading;
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
                  'MIP',
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
                actions: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: FlutterSwitch(
                          activeColor: ColorsUtil.white,
                          toggleColor: ColorsUtil.blueColor,
                          inactiveToggleColor: ColorsUtil.lightGrey,
                          width: 50.0,
                          height: 25.0,
                          toggleSize: 20.0,
                          value: switchValue,
                          borderRadius: 30.0,
                          onToggle: (val) {
                            setState(() {
                              switchValue = val;
                            });
                            startOtpVerification(true);
                            // debugPrint(switchValue.toString());
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )
            : null,
        body: MonexoLoader(
          isLoading: _isLoader,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Opacity(
                    opacity: switchValue ? 1 : 0.5,
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                isDonateSelected
                                    ? 'Please EDIT your Monthly Income Plan (MIP) settings.. The screen is showing the current values.'
                                    : 'Please select your Monthly Income Plan (MIP), to set amount of monthly earning to be transferred back to your bank account.',
                                style: TextStyle(
                                  fontFamily: CustomFonts.nunito,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            mainWidgets(context)
                            // IgnorePointer(
                            //     ignoring: !switchValue,
                            //     child: mainWidgets(context)),
                          ],
                        )),
                  )
                : Row(
                    children: [
                      Container(
                        width: screenSize.width * .56,
                        color: ColorsUtil.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                      width: screenSize.width * .4,
                                      constraints:
                                          BoxConstraints(maxWidth: 500),
                                      child: Column(
                                        children: [
                                          TitleHeader(
                                            titleStr: 'MIP Set up',
                                            desStr: isDonateSelected
                                                ? 'Please EDIT your Monthly Income Plan (MIP) settings.. The screen is showing the current values.'
                                                : 'Please select your Monthly Income Plan (MIP), to set amount of monthly earning to be transferred back to your bank account.',
                                            isVisibleSwitch: true,
                                            switchValue: switchValue,
                                            onChange: (val) {
                                              setState(() {
                                                switchValue = val;
                                              });
                                              startOtpVerification(true);
                                            },
                                          ),
                                          mainWidgets(context),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    return Expanded(
      child: IgnorePointer(
        ignoring: !switchValue,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: !isDonateSelected,
                      child: Container(
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mipDetailList?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            // if ((mipDetailList![index].id ?? 0) == donationId) {
                            //   return SizedBox();
                            // }

                            return mipDetailList?[index].optionName !=
                                    'Donate Full Interest'
                                ? CheckBoxWidget(
                                    titleStr:
                                        mipDetailList?[index].optionName ?? '',
                                    isSelected: selectedIndex == index,
                                    onPress: () {
                                      selectedOption = mipDetailList?[index];
                                      selectedIndex = index;
                                      setState(() {
                                        isDonateSelected =
                                            selectedOption?.id == donationId;
                                        if (!isDonateSelected) {
                                          selectedCause = null;
                                          selectedPartner = null;
                                        }
                                      });
                                    },
                                  )
                                : Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Center(
                                        child: Text(
                                          'OR',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: CustomFonts.nunito,
                                            color: ColorsUtil.blueColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            selectedOption =
                                                mipDetailList?[index];
                                            selectedIndex = index;
                                            setState(() {
                                              isDonateSelected =
                                                  selectedOption?.id ==
                                                      donationId;
                                              if (!isDonateSelected) {
                                                selectedCause = null;
                                                selectedPartner = null;
                                              }
                                            });
                                          },
                                          child: Text(
                                            mipDetailList?[index].optionName ??
                                                '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: CustomFonts.nunito,
                                              color: ColorsUtil.greenText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isDonateSelected,
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                color: Color(0xffF4F5F6),
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Donate Full Interest',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: ColorsUtil.blueColor,
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Set Up Donation',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      'Please fill out the below fields',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: ColorsUtil.lighterGrey),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Container(
                                        height: 56.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            isExpanded: false,
                                            value: selectedCause,
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 17.0),
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorsUtil.black,
                                              ),
                                            ),
                                            iconSize: 20,
                                            elevation: 16,
                                            style: const TextStyle(
                                              color: ColorsUtil.black,
                                            ),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.grey.shade700,
                                            ),
                                            onChanged: (String? cause) {
                                              setState(() {
                                                selectedCause = cause;
                                                selectedPartner = null;
                                                partnerList = donationObject
                                                        ?.partnerList
                                                        ?.where((element) =>
                                                            cause ==
                                                            element.causeName)
                                                        .toList() ??
                                                    [];
                                              });
                                            },
                                            hint: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Text(
                                                  "Select cause to support",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0,
                                                      color: ColorsUtil
                                                          .lightBlack),
                                                ),
                                              ),
                                            ),
                                            items: causeList
                                                .map<DropdownMenuItem<String>>(
                                                    (String? cause) {
                                              return DropdownMenuItem<String>(
                                                value: cause,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    cause ?? '',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        fontSize: 16.0,
                                                        color: ColorsUtil
                                                            .lightBlack),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Container(
                                        height: 56.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            isExpanded: false,
                                            value: selectedPartner,
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 17.0),
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                color: ColorsUtil.black,
                                              ),
                                            ),
                                            iconSize: 20,
                                            elevation: 16,
                                            style: const TextStyle(
                                              color: ColorsUtil.black,
                                            ),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.grey.shade700,
                                            ),
                                            onChanged: (MipPartner? partner) {
                                              setState(() {
                                                selectedPartner = partner;
                                              });
                                            },
                                            hint: Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Text(
                                                  "Select Partner name",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0,
                                                      color: ColorsUtil
                                                          .lightBlack),
                                                ),
                                              ),
                                            ),
                                            items: partnerList.map<
                                                    DropdownMenuItem<
                                                        MipPartner>>(
                                                (MipPartner? partner) {
                                              return DropdownMenuItem<
                                                  MipPartner>(
                                                value: partner,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    partner?.partnerName ?? '',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontWeight:
                                                            FontWeight.w100,
                                                        fontSize: 16.0,
                                                        color: ColorsUtil
                                                            .lightBlack),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                    Visibility(
                                      visible: selectedPartner?.cardArtUrl !=
                                              null &&
                                          selectedPartner?.cardArtUrl != 'None',
                                      child: Column(
                                        children: [
                                          selectedPartner?.cardArtUrl != null &&
                                                  selectedPartner?.cardArtUrl !=
                                                      'None'
                                              ? Image.network(
                                                  selectedPartner?.cardArtUrl ??
                                                      '')
                                              : Image(
                                                  image: AssetImage(
                                                      LocalImages.donation),
                                                  width: double.infinity,
                                                  // height: 170,
                                                ),
                                          SizedBox(
                                            height: 30.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.only(bottom: 30, left: 10),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '80G Certificate Available?',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            (selectedPartner
                                                        ?.is80GCertificateEnabled ??
                                                    false)
                                                ? 'Yes'
                                                : 'No',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontFamily: CustomFonts.nunito,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: ColorsUtil.lighterGrey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: CustomFonts.nunito,
                                        color: ColorsUtil.blueColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Center(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          isDonateSelected = false;
                                        });
                                      },
                                      child: Text(
                                        'Go Back',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: CustomFonts.nunito,
                                          color: ColorsUtil.greenText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                CustomButton(
                  titleStr: 'Save MIP',
                  horizontalMargin: 0,
                  isDisable: !switchValue,
                  onPress: () {
                    final userStage = context
                            .read<AppStateProvider>()
                            .userDetails
                            ?.userStage ??
                        1;
                    if (!isOtpVerified && userStage > 3) {
                      startOtpVerification(false);
                    } else {
                      saveMipDetails();
                    }
                  },
                ),
                SizedBox(
                  height: 25,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // void showSwitchDialog(BuildContext context) {
  //   var screenSize = MediaQuery.of(context).size;
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(5.0),
  //               side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
  //           title: Container(
  //             //290,
  //             width: ResponsiveWidget.isSmallScreen(context)
  //                 ? screenSize.width * .8
  //                 : screenSize.width * .35, //320,// height: 290,
  //             // width: 320,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 SizedBox(
  //                   height: 15.0,
  //                 ),
  //                 Image.asset(
  //                   LocalImages.red_alert,
  //                   width: 44,
  //                   height: 38,
  //                 ),
  //                 SizedBox(
  //                   height: 16.0,
  //                 ),
  //                 Text(
  //                   'Are you sure you want to ${switchValue ? 'disable' : 'enable'} MIP',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                       color: Colors.black,
  //                       fontFamily: CustomFonts.nunito,
  //                       fontSize: 16.0,
  //                       fontWeight: FontWeight.w700),
  //                 ),
  //                 SizedBox(
  //                   height: 30.0,
  //                 ),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Container(
  //                       width: screenSize.width * .32,
  //                       constraints: new BoxConstraints(
  //                         minWidth: 100.0,
  //                       ),
  //                       height: 55, // 120,
  //                       child: CustomButton(
  //                         horizontalMargin: 5,
  //                         borderColor: ColorsUtil.greenColor,
  //                         titleStr: 'Yes',
  //                         bgColor: ColorsUtil.greenColor,
  //                         textColor: ColorsUtil.white,
  //                         onPress: () {
  //                           Navigator.pop(context);
  //                         },
  //                       ),
  //                     ),
  //                     Container(
  //                       height: 55,
  //                       width: screenSize.width * .32,
  //                       constraints: new BoxConstraints(
  //                         minWidth: 100.0,
  //                       ), //120,
  //                       child: CustomButton(
  //                         horizontalMargin: 5,
  //                         borderColor: ColorsUtil.redColor,
  //                         titleStr: 'Cancel',
  //                         bgColor: ColorsUtil.white,
  //                         textColor: ColorsUtil.redColor,
  //                         onPress: () {
  //                           Navigator.pop(context);
  //                         },
  //                       ),
  //                     )
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[],
  //         );
  //       });
  // }
}
