import 'dart:typed_data';

import 'package:Monexo/language/language_en.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/supporting_file/api_calling.dart';
import 'package:Monexo/utils/api_constant.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/images.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/user_preferences.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/date_picker/custom_date_picker.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/widgets/input_widget.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AuthorizedSignatoryScreen extends StatefulWidget {
  const AuthorizedSignatoryScreen({Key? key}) : super(key: key);

  @override
  _AuthorizedSignatoryScreenState createState() =>
      _AuthorizedSignatoryScreenState();
}

class _AuthorizedSignatoryScreenState extends State<AuthorizedSignatoryScreen> {
  String? fileName;
  // String? filePath;
  PlatformFile? pickedFile;
  bool isNameValid = false;
  bool isNameError = false;
  bool isDobValid = false;
  bool isDobError = false;
  bool isAadharValid = false;
  bool isAadharError = false;
  var nameController = TextEditingController();
  var dobController = TextEditingController();
  var aadharController = TextEditingController();
  var selectedDate = DateTime(1980);
  var lastLength = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getAuthorizedSignatory();
  }

  void showDatePicker(context) {
    final todayDate = DateTime.now();
    final minDate = DateTime(1900);
    final initialDate = DateTime(1980);
    DatePicker.showDatePicker(
      context,
      minDateTime: minDate,
      maxDateTime: todayDate,
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
      isDobValid = true;
      isDobError = false;
    });
  }

  bool checkValidation() {
    // return true;

    if (nameController.text.isEmpty) {
      setState(() {
        isNameError = true;
      });
      return false;
    }
    if (dobController.text == '') {
      setState(() {
        isDobError = true;
      });
      return false;
    }
    if (!aadharController.text.isAdharCardValid) {
      setState(() {
        isAadharError = true;
      });
      return false;
    }
    if (pickedFile == null) {
      Utils.showToast(msg: LanguageHelper.textSelectFile);
      return false;
    }
    return true;
  }

  /// Get Authorized signatory
  Future<void> getAuthorizedSignatory() async {
    setLoading(true);
    var signatoryDetail =
        await context.read<AppStateProvider>().getAuthorizedSignatory();
    setLoading(false);
    if (signatoryDetail != null) {
      setState(() {
        nameController.text = signatoryDetail.authorizedSignatoryName ?? '';
        dobController.text = signatoryDetail.date.getSimpleDateStr();
        aadharController.text = signatoryDetail.aadharNumber ?? '';
        fileName = signatoryDetail.fileUrl ?? '';
        isNameValid = nameController.text.isNotEmpty;
        isDobValid = dobController.text.isNotEmpty;
        isAadharValid = aadharController.text.isAdharCardValid;
        selectedDate =
            signatoryDetail.date.getReverseSimpleDateStr().getDateFromString();
      });
    }
  }

  /// Save-update Authorized signatory
  Future<void> submitBtnTap() async {
    if (checkValidation()) {
      setLoading(true);

      var param = Map<String, String>();
      param[ApiParams.customerId] =
          (context.read<AppStateProvider>().customerId);
      param[ApiParams.authorizedSignatoryName] = nameController.text;
      param[ApiParams.aadharNumber] = aadharController.text;
      param[ApiParams.date] = dobController.text;
      var files = Map<String, PlatformFile>();
      files[ApiParams.file] = pickedFile!;
      var signatoryDetail = await context
          .read<AppStateProvider>()
          .saveAuthorizedSignatory(param, files);
      setLoading(false);
      if (signatoryDetail != null) {
        //navigating to back screen
        context.pop();
        Utils.showToast(msg: LanguageHelper.textAuthorizedUpdated);
      }
    }
  }

  void setLoading(loading) {
    setState(() {
      _isLoading = loading;
    });
  }

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
                  'Authorized Signatory',
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
                ? Column(
                    children: [
                      // Header(
                      //   backOnPressed: () {
                      //     context.pop();
                      //   },
                      // ),
                      // TitleHeader(
                      //   titleStr: 'Authorized Signatory',
                      //   desStr:
                      //       'Let us know who you wish to nominate in case of an unforeseen / untimely demise of yourself.',
                      // ),
                      // SizedBox(height: 30),
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
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    child: Column(
                                      children: [
                                        TitleHeader(
                                          titleStr: 'Authorized Signatory',
                                          desStr:
                                              'Let us know who you wish to nominate in case of an unforeseen / untimely demise of yourself.',
                                        ),
                                        SizedBox(height: 30),
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
                    hintStr: "Authorized Signatory Name",
                    heading: "Authorized Signatory Name",
                    controller: nameController,
                    isError: isNameError,
                    isValid: isNameValid,
                    onChange: (String input) {
                      setState(() {
                        isNameValid = input.isNotEmpty;
                        isNameError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  InputWidget(
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
                    heading: 'Date of Birth',
                    isEnable: true,
                    alertColor: Colors.red,
                    alertStr: !isDobValid && dobController.text.isNotEmpty
                        ? "Date entry should be in DD-MM-YYYY format"
                        : "",
                  ),
                  SizedBox(height: 30),
                  InputWidget(
                    hintStr: 'Aadhar Number',
                    heading: 'Aadhar Number',
                    controller: aadharController,
                    isError: isAadharError,
                    isValid: isAadharValid,
                    maxLength: 12,
                    keyboardType: TextInputType.number,
                    onChange: (String input) {
                      setState(() {
                        isAadharValid = input.isAdharCardValid;
                        isAadharError = false;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () async {
                            final filePicked = await Utils.pickFile();
                            if (filePicked == null) return;
                            setState(() {
                              fileName = filePicked.name;
                              //  filePath = filePicked.path;
                              pickedFile = filePicked;
                              //print('namePath -> $filePath');
                            });
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
                                                  fontFamily:
                                                      CustomFonts.nunito,
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
                                            color: ColorsUtil.blueColor,
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Text(
                                            'Upload Form',
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
                          padding: const EdgeInsets.only(top: 8.0, left: 15),
                          child: Text(
                            'Formats Accepted: PDF, PNG, JPG',
                            style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.0,
                                color: ColorsUtil.lightBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Column(
            children: [
              CustomButton(
                titleStr: 'Save Authorized Signatory',
                onPress: submitBtnTap,
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
                tileColor: selectedIndex == index ? Colors.blue : null,
                onTap: () {
                  selectedIndex = index;
                  // setState((){
                  //
                  // });
                },
              );
            },
          )),
      actions: <Widget>[],
    );
  }
}
