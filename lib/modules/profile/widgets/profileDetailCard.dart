import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/modules/profile/screens/profile_detail_screen.dart';
import 'package:peerbridge/modules/profile/widgets/editTextWidget.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDetailCard extends StatefulWidget {
  String detailHeading;

  ProfileDetailCard({
    required this.detailHeading,
  });

  @override
  State<ProfileDetailCard> createState() => _ProfileDetailCardState();
}

class _ProfileDetailCardState extends State<ProfileDetailCard> {
  bool isEdit = false;
  String emailId = '';
  String phoneNo = '';
  String aadharNo = '';

  bool isLoading = false;

  setLoader(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    var profileData =
        context.read<AppStateProvider>().userDetails?.profileDetails ??
            ProfileDetails();
    setState(() {
      emailId = profileData.email;
      phoneNo = profileData.phoneNumber;
      aadharNo = context
              .read<AppStateProvider>()
              .userDetails
              ?.profileDetails
              ?.aadharNumber ??
          "";
    });
    super.initState();
  }

  bool checkValidation() {
    if (!emailId.isEmailValid) {
      Utils.showToast(msg: LanguageHelper.textValidEmail);
      return false;
    }
    if (!phoneNo.isMobileNumberValid) {
      Utils.showToast(msg: LanguageHelper.textValidPhone);
      return false;
    }

    var kycDone = false;
    try {
      kycDone = context.read<AppStateProvider>().stepsData!.kyc == "1";
    } catch (e) {}
    if (!kycDone && !aadharNo.isAdharCardValid) {
      Utils.showToast(msg: LanguageHelper.textValidAadharNo);
      return false;
    }
    return true;
  }

  Future<void> updateAddressTap() async {
    var param = Map<String, String>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.phoneNumber] = phoneNo;
    param[ApiParams.aadharNumber] = aadharNo;
    param[ApiParams.email] = emailId.trimLeft();

    isEdit = false;

    setLoader(true);
    var status = await context.read<AppStateProvider>().updateProfile(param);
    setLoader(false);
    if (status) {
      Utils.showToast(msg: LanguageHelper.textProfileDetailsUpdated);
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
        mobileNumber: phoneNo,
        onFailed: () {},
        onVerified: () {
          updateAddressTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppStateProvider>(context);
    var profileDetails = provider.userDetails!.profileDetails!;

    bool kycDone = false;

    try {
      kycDone = (provider.stepsData?.kyc ?? '0') == "1";
    } catch (e) {}
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: ColorsUtil.circleGrey)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.detailHeading,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: ColorsUtil.black,
                      fontFamily: CustomFonts.nunito,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
              (isLoading)
                  ? TextButton.icon(
                      onPressed: null,
                      icon: SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      label: Text("Updating"))
                  : TextButton.icon(
                      onPressed: () {
                        if (isEdit) {
                          startOtpVerification();
                        } else {
                          setState(() {
                            isEdit = !isEdit;
                          });
                        }
                      },
                      icon: Icon(
                        isEdit ? Icons.check : Icons.edit_outlined,
                        size: 18.0,
                        color: ColorsUtil.greenText,
                      ),
                      label: Text(
                        isEdit ? 'Save' : "Edit",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.greenText),
                      ),
                    )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              defaultColumnWidth: FixedColumnWidth(150.0),
              children: [
                TableRow(children: [
                  EditableTextWidget(
                    value: "Customer ID",
                    isEdit: false,
                    onChanged: (value) {},
                    isHeading: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: EditableTextWidget(
                        value: provider.customerId,
                        isEdit: false,
                        onChanged: (value) {
                          debugPrint(value);
                        }),
                  ),
                ]),
                TableRow(children: [
                  EditableTextWidget(
                    value: "Name",
                    isEdit: false,
                    onChanged: (value) {},
                    isHeading: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: EditableTextWidget(
                        value: profileDetails.fullName,
                        isEdit: false,
                        onChanged: (value) {
                          debugPrint(value);
                        }),
                  ),
                ]),
                // rowSpacer,
                TableRow(children: [
                  EditableTextWidget(
                    value: "Email Address",
                    isEdit: false,
                    onChanged: (value) {},
                    isHeading: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: EditableTextWidget(
                        value: profileDetails.email,
                        isEdit: isEdit,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          setState(() {
                            emailId = value;
                          });
                        }),
                  ),
                ]),
                rowSpacer,
                TableRow(children: [
                  EditableTextWidget(
                    value: "Mobile Number",
                    isEdit: false,
                    onChanged: (value) {},
                    isHeading: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: EditableTextWidget(
                        value: profileDetails.phoneNumber,
                        isEdit: isEdit,
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            phoneNo = value;
                          });
                        }),
                  ),
                ]),
                rowSpacer,
                TableRow(children: [
                  EditableTextWidget(
                    value: "Aadhar Number",
                    isEdit: false,
                    onChanged: (value) {},
                    isHeading: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: EditableTextWidget(
                        // value: !kycDone
                        //     ? (provider.userDetails?.panDetails?.aadharNumber ??
                        //         '')
                        //     : provider.userDetails?.aadharNumber ?? '',
                        value: provider
                                .userDetails?.profileDetails?.aadharNumber ??
                            '',
                        isEdit: (isEdit && !kycDone) ? true : false,
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          aadharNo = value;
                        }),
                  ),
                ]),
                rowSpacer
              ]),
        ],
      ),
    );
  }
}
