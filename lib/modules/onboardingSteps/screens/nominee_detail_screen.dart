import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/profile/models/user_details.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/date_picker/custom_date_picker.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/utils/extensions.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../supporting_file/appsFlyerSdk.dart';

class NomineeDetailScreen extends StatefulWidget {
  const NomineeDetailScreen({Key? key}) : super(key: key);

  @override
  _NomineeDetailScreenState createState() => _NomineeDetailScreenState();
}

class _NomineeDetailScreenState extends State<NomineeDetailScreen> {
  var fullNameController = TextEditingController();
  var dobController = TextEditingController();
  var panController = TextEditingController();
  var addressController = TextEditingController();
  var pincodeController = TextEditingController();
  var cityController = TextEditingController();
  var stateController = TextEditingController();

  bool fullNameValid = false;
  bool fullNameError = false;
  bool isDobValid = false;
  bool isDobError = false;
  bool isPanValid = false;
  bool isPanError = false;
  bool addressValid = false;
  bool isAddressError = false;
  bool pincodeValid = false;
  bool isPincodeError = false;
  bool cityValid = false;
  bool isCityError = false;
  bool stateValid = false;
  bool isStateError = false;
  var _isLoader = false;
  var isOtpVerified = false;
  var lastLength = 0;

  var selectedDate = DateTime(1980);
  String relationship = '';
  String dobStr = '';

  NomineeDetails? nomineeDetails;

  @override
  void initState() {
    super.initState();
    getNomineeDetails();
  }

  void showDatePicker(context) {
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime(1900),
      maxDateTime: DateTime.now(),
      initialDateTime: selectedDate,
      dateFormat: 'dd-MMMM-yyyy',
      locale: DateTimePickerLocale.en_us,
      onConfirm: changeDOB,
    );
  }

  void changeDOB(DateTime date, event) {
    setState(() {
      selectedDate = date;
      var day = date.day.toString().padLeft(2, '0');
      var month = date.month.toString().padLeft(2, '0');
      var year = date.year;
      dobController.text = '$day-$month-$year';
      dobStr = '$year-$month-$day';
      isDobValid = true;
      isDobError = false;
    });
  }

  void updateDobStr() {
    var date = dobController.text.getReverseNormalDate();
    var day = date.day.toString().padLeft(2, '0');
    var month = date.month.toString().padLeft(2, '0');
    var year = date.year;
    dobStr = '$year-$month-$day';
  }

  bool checkValidation() {
    if (fullNameController.text.isEmpty || !fullNameValid) {
      setState(() {
        fullNameError = true;
      });
      return false;
    }
    if (dobController.text == '') {
      setState(() {
        isDobError = true;
      });
      return false;
    }
    if (addressController.text.isEmpty || !addressValid) {
      setState(() {
        isAddressError = true;
      });
      return false;
    }
    if (!pincodeController.text.isPincodeValid) {
      setState(() {
        isPincodeError = true;
      });
      return false;
    }
    if (cityController.text.isEmpty || !cityValid) {
      setState(() {
        isCityError = true;
      });
      return false;
    }
    if (stateController.text.isEmpty || !stateValid) {
      setState(() {
        isStateError = true;
      });
      return false;
    }
    if (relationship == '') {
      debugPrint('debug print');
      Utils.showAlert(
          context: context, msg: LanguageHelper.textSelectRelationship);
      return false;
    }

    return true;
  }

  /// Fetch City and state data
  void fetchCityStateData() async {
    setLoading(true);
    var pinCodeDetail = await context
        .read<AppStateProvider>()
        .getCityState(pincodeController.text);
    setLoading(false);

    if (pinCodeDetail != null) {
      cityController.text = pinCodeDetail.districtname ?? '';
      stateController.text = pinCodeDetail.statename ?? '';
      cityValid = cityController.text.isNotEmpty;
      stateValid = stateController.text.isNotEmpty;
    }
  }

  ///Get nominee details
  void getNomineeDetails() async {
    setLoading(true);
    var userNomineeDetails =
        await context.read<AppStateProvider>().getNomineeDetails();
    setLoading(false);
    if (userNomineeDetails != null) {
      fullNameController.text = userNomineeDetails.nomineeFullName;
      dobController.text = userNomineeDetails.dob.getSimpleDateStr();
      dobStr = userNomineeDetails.dob;
      addressController.text = userNomineeDetails.address;
      pincodeController.text = userNomineeDetails.pincode;
      cityController.text = userNomineeDetails.city;
      stateController.text = userNomineeDetails.state;
      panController.text = userNomineeDetails.panNumber;
      setState(() {
        relationship = userNomineeDetails.relationship;
        nomineeDetails = userNomineeDetails;
        fullNameValid = fullNameController.text.isNotEmpty;
        isDobValid = dobStr.isNotEmpty;
        selectedDate = dobStr.getDateFromString();
        addressValid = addressController.text.isNotEmpty;
        pincodeValid = pincodeController.text.isPincodeValid;
        cityValid = cityController.text.isNotEmpty;
        stateValid = stateController.text.isNotEmpty;
        isPanValid = panController.text.isPanValid;
      });
    }
  }

  /// Save nominee details
  void saveDetailButtonTap() async {
    if (checkValidation()) {
      updateDobStr();
      var param = Map<String, String>();
      param[ApiParams.customerId] =
          (context.read<AppStateProvider>().customerId);
      param[ApiParams.nomineeFullName] = fullNameController.text;
      param[ApiParams.dob] = dobStr.replaceAll(' ', '');
      param[ApiParams.address] = addressController.text;
      param[ApiParams.pincode] = pincodeController.text;
      param[ApiParams.city] = cityController.text;
      param[ApiParams.state] = stateController.text;
      param[ApiParams.relationship] = relationship;
      param[ApiParams.panNumber] = panController.text;

      setLoading(true);
      var result =
          await context.read<AppStateProvider>().saveNomineeDetails(param);
      setLoading(false);
      if (result != null) {
        AFSdk.logEvent(AFSdk.af_nominee, null);
        context.pop();
        Utils.showToast(msg: LanguageHelper.textNomineesUpdated);
      } else {}
    }
    print("error");
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification() async {
    if (!checkValidation()) {
      return;
    }
    // saveDetailButtonTap();
    // return;
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
          saveDetailButtonTap();
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
                  'Nominee Details',
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
          isLoading: _isLoader,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Column(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        child: Text(
                          'Let us know who you wish to nominate in case of an unforeseen / untimely demise of yourself.',
                          style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      mainWidgets(context),
                    ],
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
                                            titleStr: 'Nominee Details',
                                            desStr:
                                                'Let us know who you wish to nominate in case of an unforeseen / untimely demise of yourself.',
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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputWidget(
                    hintStr: "Nominee Full Name",
                    heading: "Nominee Full Name",
                    controller: fullNameController,
                    isValid: fullNameValid,
                    isError: fullNameError,
                    onChange: (String input) {
                      setState(() {
                        fullNameValid =
                            input.isNotEmpty && !input.isFollowedBySpace();
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 56,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorsUtil.white,
                      border: Border.all(color: ColorsUtil.lighterGrey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            relationship == ''
                                ? 'Select Relationship'
                                : relationship,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: relationship == ''
                                    ? ColorsUtil.greyPlaceHolder
                                    : ColorsUtil.blueColor),
                          ),
                          Spacer(),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 25,
                            color: relationship == ''
                                ? ColorsUtil.greyPlaceHolder
                                : ColorsUtil.blueColor,
                          )
                        ],
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              nomineePopupDialog(context),
                        );
                      },
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    heading: 'Date of Birth',
                    controller: dobController,
                    isValid: isDobValid,
                    isError: isDobError,
                    onChange: (val) {
                      try {
                        var currentPos = dobController.selection.baseOffset;
                        //checking for day
                        if (currentPos == 2) {
                          //user removing the test
                          if (lastLength == 3) {
                            dobController.value = TextEditingValue(
                                text: val.substring(0, 1),
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 1)));
                            lastLength = 1;
                          } else {
                            dobController.value = TextEditingValue(
                                text: val + "-",
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 3)));
                            lastLength = 3;
                          }
                        }
                        //checking for month
                        if (currentPos == 5) {
                          //user removing the test
                          if (lastLength == 6) {
                            dobController.value = TextEditingValue(
                                text: val.substring(0, 4),
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 4)));
                            lastLength = 4;
                          } else {
                            dobController.value = TextEditingValue(
                                text: val + "-",
                                selection: TextSelection.fromPosition(
                                    TextPosition(offset: 6)));
                            lastLength = 6;
                          }
                        }

                        var formatter = DateFormat("dd-MM-yyyy");
                        var date = formatter.parseUTC(val).toLocal();

                        if (date.month <= 12 &&
                            date.month > 0 &&
                            date.day > 0 &&
                            date.day <= 31 &&
                            date.year > 1900 &&
                            date.year.toString().length == 4 &&
                            date.year <= DateTime.now().year) {
                          selectedDate = date;
                          isDobValid = true;
                          setState(() {});
                        }
                      } catch (e) {
                        isDobValid = false;
                        setState(() {});
                      }
                    },
                    maxLength: 10,
                    rightIcon: Tooltip(
                      message: "Show Calendar",
                      child: IconButton(
                        onPressed: () {
                          showDatePicker(context);
                        },
                        icon: Icon(CupertinoIcons.calendar_today),
                      ),
                    ),
                    hintStr: 'DD-MM-YYYY',
                    isEnable: true,
                    alertColor: Colors.red,
                    alertStr: !isDobValid && dobController.text.isNotEmpty
                        ? "Date entry should be in DD-MM-YYYY format"
                        : "",
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: panController,
                    isValid: isPanValid,
                    isError: isPanError,
                    maxLength: 10,
                    heading: 'PAN card number',
                    hintStr: "ABCDE1234D",
                    textCapitalization: TextCapitalization.characters,
                    onChange: (String input) {
                      setState(() {
                        isPanValid = input.isPanValid;
                        isPanError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    controller: pincodeController,
                    keyboardType: TextInputType.phone,
                    hintStr: 'Pin Code',
                    heading: 'Pin Code',
                    isValid: pincodeValid,
                    isError: isPincodeError,
                    onChange: (String input) {
                      setState(() {
                        pincodeValid = input.isPincodeValid;
                        if (pincodeValid) {
                          FocusScope.of(context).unfocus();
                          fetchCityStateData();
                        }
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    hintStr: 'Auto-Populate',
                    heading: 'City',
                    controller: cityController,
                    isValid: cityValid,
                    isError: isCityError,
                    onChange: (String input) {
                      setState(() {
                        cityValid =
                            input.isNotEmpty && !input.isFollowedBySpace();
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    heading: 'State',
                    hintStr: 'Auto-Populate',
                    controller: stateController,
                    isValid: stateValid,
                    isError: isStateError,
                    onChange: (String input) {
                      setState(() {
                        stateValid =
                            input.isNotEmpty && !input.isFollowedBySpace();
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    hintStr: 'Enter your Address',
                    heading: 'Enter your Address',
                    controller: addressController,
                    isValid: addressValid,
                    isError: isAddressError,
                    onChange: (String input) {
                      setState(() {
                        addressValid =
                            input.isNotEmpty && !input.isFollowedBySpace();
                      });
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CustomButton(
                titleStr: 'Save Nominee Details',
                onPress: () {
                  final userStage =
                      context.read<AppStateProvider>().userDetails?.userStage ??
                          1;
                  if (!isOtpVerified && userStage > 3) {
                    startOtpVerification();
                  } else {
                    saveDetailButtonTap();
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
    );
  }

  Widget nomineePopupDialog(BuildContext context) {
    int? selectedIndex;
    List<String> nomineeList = [
      'Father',
      'Mother',
      'Son',
      'Daughter',
      'Sister',
      'Husband',
      'Wife',
      'Other'
    ];
    return AlertDialog(
      titlePadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      insetPadding: EdgeInsets.all(00),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
          side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
      title: Container(
          height: ((nomineeList.length.toDouble()) + 1) * 50,
          width: MediaQuery.of(context).size.width * .8,
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              return ListTile(
                title: Row(
                  children: [
                    selectedIndex == index
                        ? Icon(
                            Icons.check,
                            color: ColorsUtil.blueColor,
                          )
                        : Container(),
                    SizedBox(width: 10),
                    Text(
                      nomineeList[index],
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          fontFamily: CustomFonts.nunito),
                    ),
                  ],
                ),
                tileColor: selectedIndex == index ? ColorsUtil.lightGreen : null,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  selectedIndex = index;
                  setState(() {
                    relationship = nomineeList[index];
                  });
                  Navigator.pop(context);
                },
              );
            },
          )),
      actions: <Widget>[],
    );
  }
}
