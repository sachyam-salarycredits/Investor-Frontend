import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/modules/profile/widgets/editTextWidget.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OfficeAddressCard extends StatefulWidget {
  String detailHeading2;

  OfficeAddressCard({
    required this.detailHeading2,
  });

  @override
  State<OfficeAddressCard> createState() => _OfficeAddressCardState();
}

class _OfficeAddressCardState extends State<OfficeAddressCard> {
  bool isEdit = false;
  String designationStr = '';
  String departmentStr = '';
  String flatStr = '';
  String doorStr = '';
  String pinCodeStr = '';
  String cityStr = '';
  String stateStr = '';

  bool isLoading = false;

  setLoader(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    var addressData =
        context.read<AppStateProvider>().userDetails?.officeAddress ??
            OfficeAddress();
    setState(() {
      designationStr = addressData.designation;
      departmentStr = addressData.department;
      flatStr = addressData.flatNo;
      doorStr = addressData.doorNo;
      pinCodeStr = addressData.pincode;
      cityStr = addressData.city;
      stateStr = addressData.state;
    });
    super.initState();
  }

  bool checkValidation() {
    if (designationStr.isEmpty ||
        departmentStr.isEmpty ||
        flatStr.isEmpty ||
        doorStr.isEmpty ||
        pinCodeStr.isEmpty ||
        cityStr.isEmpty ||
        stateStr.isEmpty) {
      Utils.showToast(msg: LanguageHelper.textFillFields);
      return false;
    }
    if (designationStr.isFollowedBySpace() ||
        departmentStr.isFollowedBySpace() ||
        flatStr.isFollowedBySpace() ||
        doorStr.isFollowedBySpace() ||
        pinCodeStr.isFollowedBySpace() ||
        cityStr.isFollowedBySpace() ||
        stateStr.isFollowedBySpace()) {
      Utils.showToast(msg: LanguageHelper.removeSpace);
      return false;
    }
    if (!pinCodeStr.isPincodeValid) {
      Utils.showToast(msg: LanguageHelper.textEnterPinCode);
      return false;
    }
    return true;
  }

  Future<void> updateAddressTap() async {
    var param = Map<String, String>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.designation] = designationStr.trimLeft();
    param[ApiParams.department] = departmentStr.trimLeft();
    param[ApiParams.city] = cityStr.trimLeft();
    param[ApiParams.doorNo] = doorStr.trimLeft();
    param[ApiParams.flatNo] = flatStr.trimLeft();
    param[ApiParams.pincode] = pinCodeStr.trimLeft();
    param[ApiParams.state] = stateStr.trimLeft();

    isEdit = false;

    setLoader(true);
    var status =
        await context.read<AppStateProvider>().updateOfficeAddress(param);
    setLoader(false);
    if (status) {
      Utils.showToast(msg: LanguageHelper.textOfficeAddressUpdated);
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
    var addressDetails = provider.userDetails?.officeAddress ?? OfficeAddress();
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
              Text(widget.detailHeading2,
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
                    ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            defaultColumnWidth: FixedColumnWidth(150.0),
            children: [
              TableRow(children: [
                EditableTextWidget(
                  value: "Department",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.department,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          departmentStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "Designation",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.designation,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          designationStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "Flat/Room No./Floor No./ Block No.",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.flatNo,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          flatStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "Door No./ Street Name/ Building",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.doorNo,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          doorStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "Pincode",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.pincode,
                      isEdit: isEdit,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          pinCodeStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "City",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.city,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          cityStr = value;
                        });
                      }),
                ),
              ]),
              TableRow(children: [
                EditableTextWidget(
                  value: "State",
                  isEdit: false,
                  onChanged: (value) {},
                  isHeading: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: EditableTextWidget(
                      value: addressDetails.state,
                      isEdit: isEdit,
                      onChanged: (value) {
                        setState(() {
                          stateStr = value;
                        });
                      }),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
