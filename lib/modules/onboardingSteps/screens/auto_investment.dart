import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/input_widget.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/otp_verification.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../../../utils/images.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../models/auto_invest_category_model.dart';

class AutoInvestmentScreen extends StatefulWidget {
  const AutoInvestmentScreen({Key? key}) : super(key: key);

  @override
  _AutoInvestmentScreenState createState() => _AutoInvestmentScreenState();
}

class _AutoInvestmentScreenState extends State<AutoInvestmentScreen> {
  // var amountController = TextEditingController();
  var conservativeRiskController = TextEditingController();
  var moderateRiskController = TextEditingController();
  var highRiskController = TextEditingController();

  // bool isConservativeRiskTitle = false;
  // bool isModerateRiskTitle = false;
  // bool isHighRiskTitle = false;
  bool isValidData = false;
  // bool isAmountValid = false;
  // bool isAmountError = false;
  bool isConRiskValid = false;
  bool isModerateRiskValid = false;
  bool isHighRiskValid = false;
  bool isRiskError = false;

  bool switchValue = true;
  bool currentSwitchValue = true;

  bool _isLoading = false;
  var isOtpVerified = false;

  // double dotSize = 16;
  // double sliderValue = 20;
  double _currentSliderValue = 1000;

  bool isLowRiskSelected = false;
  bool isMediumRiskSelected = false;
  bool isHighRiskSelected = false;
  bool isCustomSelected = false;
  List paletteList = [
    ColorsUtil.green1PieColor,
    ColorsUtil.green2PieColor,
    ColorsUtil.green3PieColor,
  ];
  List<AutoInvestCategoryModel> autoInvestCategoryDetailList = [];
  List<ChartData> chartData = [];

  var autoInvestFinalList = [];

  @override
  void initState() {
    super.initState();
    getAutoInvestment();
    getAutoInvestCategoryDetails();
  }

  getAutoInvestCategoryDetails() async {
    setLoading(true);

    print('lll');
    await context.read<AppStateProvider>().getAutoInvestCategoryDetails();
    autoInvestCategoryDetailList =
        await context.read<AppStateProvider>().autoInvestCategoryDetailList;

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        if (isLowRiskSelected) {
          autoInvestFinalList = autoInvestCategoryDetailList
              .where((element) => element.categoryType == 'Low Risk')
              .toList();
        } else if (isMediumRiskSelected) {
          autoInvestFinalList = autoInvestCategoryDetailList
              .where((element) => element.categoryType == 'Medium Risk')
              .toList();
        } else if (isHighRiskSelected) {
          autoInvestFinalList = autoInvestCategoryDetailList
              .where((element) => element.categoryType == 'High Risk')
              .toList();
        }
        chartData = [
          ChartData('Conservative Risk',
              double.parse(autoInvestFinalList.first.conservativeRisk ?? '0')),
          ChartData('Moderate Risk',
              double.parse(autoInvestFinalList.first.moderateRisk ?? '0')),
          ChartData('High Risk ',
              double.parse(autoInvestFinalList.first.highRisk ?? '0'))
        ];
      });
    });

    print('char===$chartData');
    setLoading(false);
  }

  bool checkValidation() {
    // if (amountController.text.isEmpty) {
    //   return false;
    // }
    if (!isValidSum()) {
      return false;
    }
    return true;
  }

  // bool checkAmountValidation() {
  //   if (amountController.text.doubleValue() < 1000 ||
  //       amountController.text.doubleValue() > 5000 ||
  //       !amountController.text.isMultipleThousandValid) {
  //     setState(() {
  //       isAmountError = true;
  //     });
  //     return false;
  //   }
  //   setState(() {
  //     isAmountError = false;
  //     isAmountValid = true;
  //   });
  //   return true;
  // }

  bool checkRiskValidation() {
    if (conservativeRiskController.text.doubleValue() > 100 ||
        moderateRiskController.text.doubleValue() > 100 ||
        highRiskController.text.doubleValue() > 100) {
      return true;
    }
    if (!isValidSum() &&
        (conservativeRiskController.text.isNotEmpty &&
            moderateRiskController.text.isNotEmpty &&
            highRiskController.text.isNotEmpty)) {
      return true;
    }
    if ((conservativeRiskController.text.doubleValue() +
            moderateRiskController.text.doubleValue() +
            highRiskController.text.doubleValue()) >
        100) {
      return true;
    }
    return false;
  }

  bool isValidSum() {
    var isValid = (conservativeRiskController.text.doubleValue() +
            moderateRiskController.text.doubleValue() +
            highRiskController.text.doubleValue()) ==
        100;
    if (isValid) {
      isConRiskValid = isValid;
      isModerateRiskValid = isValid;
      isHighRiskValid = isValid;
    }
    return isValid;
  }

  /// Save-Update auto-investments
  Future<void> getAutoInvestment() async {
    setLoading(true);
    var investDetails =
        await context.read<AppStateProvider>().getAutoInvestment();
    setLoading(false);
    if (investDetails != null) {
      setState(() {
        _currentSliderValue = investDetails.totalAmount == 0.0
            ? 1000
            : investDetails.totalAmount ?? 0.0;
        // amountController.text = '${investDetails.totalAmount?.round()}';
        // _currentSliderValue = investDetails.totalAmount?.round() as double;
        conservativeRiskController.text =
            '${investDetails.conservetiveRisk?.round()}';
        moderateRiskController.text = '${investDetails.moderateRisk?.round()}';
        highRiskController.text = '${investDetails.highRisk?.round()}';
        isValidData = checkValidation();
        isConRiskValid = isValidData;
        isModerateRiskValid = isValidData;
        isHighRiskValid = isValidData;
        currentSwitchValue = investDetails.enable ?? true;
        if (investDetails.flag == 'Custom') {
          isCustomSelected = true;
        } else if (investDetails.flag == 'Low Risk') {
          isLowRiskSelected = true;
        } else if (investDetails.flag == 'Medium Risk') {
          isMediumRiskSelected = true;
        } else {
          isHighRiskSelected = true;
        }
      });
    }
    setState(() {
      switchValue = currentSwitchValue;
      print('switchValue=== $switchValue');
    });
  }

  /// Save-Update auto-investments
  Future<void> saveUpdateData() async {
    if (!isValidData) {
      return;
    }
    var param = Map<String, String>();

    param[ApiParams.customerId] = (context.read<AppStateProvider>().customerId);
    param[ApiParams.totalAmount] = _currentSliderValue.toString();
    param[ApiParams.conservetiveRisk] = conservativeRiskController.text;
    param[ApiParams.moderateRisk] = moderateRiskController.text;
    param[ApiParams.highRisk] = highRiskController.text;
    print(param);
    setLoading(true);
    var investDetails =
        await context.read<AppStateProvider>().saveAutoInvestment(param);
    setLoading(false);
    if (investDetails != null) {
      var value = Map<String, dynamic>();
      value["af_revenue"] = _currentSliderValue.toString();
      value["af_currency"] = "INR";
      // AFSdk.logEvent(AFSdk.af_autoInvest, value);
      Utils.showAlert(
          context: context,
          msg: LanguageHelper.textAutoInvestmentUpdated,
          onTap: () {
            context.pop();
          });
    }
    Utils.showAlert(
        context: context,
        msg: LanguageHelper.textAutoInvestmentUpdated,
        onTap: () {
          context.pop();
        });
  }

  /// Update AutoInves Switch
  Future<void> updateAutoInvestSwitch() async {
    setLoading(true);
    var param = Map<String, dynamic>();
    param[ApiParams.customerId] = context.read<AppStateProvider>().customerId;
    param[ApiParams.enable] = switchValue;
    var updateSwitch =
        await context.read<AppStateProvider>().updateAutoInvestSwitch(param);
    setLoading(false);
    setState(() {
      isOtpVerified = false;
    });
    if (updateSwitch) {
      getAutoInvestment();
    } else {
      setState(() {
        switchValue = currentSwitchValue;
      });
    }
  }

  /// OTP verification is required before saving data
  Future<void> startOtpVerification(bool isSwitch) async {
    if (!isSwitch && !isValidData) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationWidget(
        onFailed: () {
          //do something
          setState(() {
            switchValue = currentSwitchValue;
          });
        },
        onVerified: () {
          if (isSwitch) {
            updateAutoInvestSwitch();
          } else {
            setState(() {
              isOtpVerified = true;
            });
            saveUpdateData();
          }
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

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: ResponsiveWidget.isSmallScreen(context)
            ? AppBar(
                title: Text(
                  'Auto Diversify',
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
                            }),
                      ),
                    ),
                  )
                ],
              )
            : null,
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
            child: ResponsiveWidget.isSmallScreen(context)
                ? Opacity(
                    opacity: switchValue ? 1 : 0.5,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          child: Text(
                            'Now investment as per your risk appetite, with auto diversify, we take care of fund allocations.',
                            style: TextStyle(
                              fontFamily: CustomFonts.nunito,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: mainWidgets(context),
                          ),
                        ),
                      ],
                    ),
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
                                child: SingleChildScrollView(
                                  child: Container(
                                    child: Center(
                                      child: Container(
                                        width: screenSize.width * .4,
                                        constraints:
                                            BoxConstraints(maxWidth: 500),
                                        child: Column(
                                          children: [
                                            TitleHeader(
                                              titleStr: 'Auto Diversify',
                                              desStr:
                                                  'Now investment as per your risk appetite, with auto diversify, we take care of fund allocations.',
                                              isVisibleSwitch: true,
                                              switchValue: switchValue,
                                              onChange: (val) {
                                                setState(() {
                                                  switchValue = val;
                                                });
                                                startOtpVerification(true);
                                                // debugPrint(switchValue.toString());
                                              },
                                            ),
                                            mainWidgets(context),
                                          ],
                                        ),
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
    var screenSize = MediaQuery.of(context).size;
    return IgnorePointer(
      ignoring: !switchValue,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Minimum Investment Amount Per Loan',
              style: TextStyle(
                color: ColorsUtil.blackish,
                fontSize: 14,
                fontFamily: CustomFonts.nunito,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Recommended',
              style: TextStyle(
                color: ColorsUtil.lightGrey,
                fontSize: 8,
                fontFamily: CustomFonts.nunito,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SfSliderTheme(
              data: SfSliderThemeData(
                tooltipBackgroundColor: ColorsUtil.blueColor,
                thumbColor: ColorsUtil.blueColor,
                activeTrackHeight: 5,
                inactiveTrackHeight: 2.5,
                activeDividerRadius: 3.5,
                inactiveDividerRadius: 3.5,
                inactiveDividerColor: ColorsUtil.lightGrey,
                activeTrackColor: ColorsUtil.blueColor,
                inactiveTrackColor: ColorsUtil.lighterGrey,
                labelOffset: Offset(0.0, -35.0),
                inactiveLabelStyle: TextStyle(
                  color: ColorsUtil.lightGrey,
                  fontSize: 11,
                  fontFamily: CustomFonts.nunito,
                ),
                activeLabelStyle: TextStyle(
                  color: ColorsUtil.lightGrey,
                  fontSize: 11,
                  fontFamily: CustomFonts.nunito,
                ),
              ),
              child: SfSlider(
                enableTooltip: true,
                thumbIcon: Image(
                  image: AssetImage(LocalImages.slider_arrow),
                  width: 20,
                  height: 20,
                ),
                min: 1000,
                max: 5000,
                value: _currentSliderValue,
                interval: 1000,
                stepSize: 1000,
                showTicks: false,
                showLabels: true,
                labelFormatterCallback:
                    (dynamic actualValue, String formattedText) {
                  switch (actualValue) {
                    case 1000:
                      return formattedText;
                    case 2000:
                      return '2,000';
                    case 3000:
                      return '3,000';
                    case 4000:
                      return '4,000';
                    case 5000:
                      return '5,000';
                  }
                  return actualValue.toString();
                },
                showDividers: true,
                onChanged: (dynamic newValue) {
                  setState(() {
                    _currentSliderValue = newValue;
                    print(_currentSliderValue);
                    if (_currentSliderValue == 5000) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          // <-- SEE HERE
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15.0),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveWidget.isSmallScreen(context)
                              ? screenSize.width
                              : screenSize.width * .35,
                        ),
                        builder: (BuildContext context) => Container(
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
                              // width: ResponsiveWidget.isSmallScreen(context)
                              //     ? screenSize.width * .8
                              //     : screenSize.width *
                              //         .35, //320,// height: 290,
                              // width: 320,
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // SizedBox(
                                  //   height: 15.0,
                                  // ),

                                  Text(
                                    'Are You Sure You Wanna Increase Your Minimum Investment To 5,000 ?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: CustomFonts.nunito,
                                        fontSize: 19.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Text(
                                    'Your are fewer funding loans and increasing your risk.',
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          borderColor: ColorsUtil.blueColor,
                                          titleStr: 'Yes',
                                          bgColor: ColorsUtil.white,
                                          textColor: ColorsUtil.blueColor,
                                          onPress: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          borderColor: ColorsUtil.blueColor,
                                          titleStr: 'Set To 1,000',
                                          bgColor: ColorsUtil.blueColor,
                                          textColor: ColorsUtil.white,
                                          onPress: () {
                                            setState(() {
                                              _currentSliderValue = 1000;
                                            });

                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  });
                },
              ),
            ),

            SizedBox(
              height: 10,
            ),
            Text(
              'Set Lending Criteria',
              style: TextStyle(
                color: ColorsUtil.blackish,
                fontSize: 16,
                fontFamily: CustomFonts.nunito,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CheckBox(
              selectedWidget: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Your objective is to earn XIRR of 12% to 13% p.a. consistently with least possible risk.',
                      style: TextStyle(
                        color: ColorsUtil.lightGrey,
                        fontSize: 13,
                        height: 1.8,
                        fontFamily: CustomFonts.nunito,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: ColorsUtil.lighterGrey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              // height: 100,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chartData.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: CircleAvatar(
                                              radius: 5,
                                              backgroundColor: paletteList[i]),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          ' ${chartData[i].y.toStringAsFixed(0)} %',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          chartData[i].x.toString(),
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: SfCircularChart(palette: [
                                ColorsUtil.green1PieColor,
                                ColorsUtil.green2PieColor,
                                ColorsUtil.green3PieColor
                              ], series: <CircularSeries>[
                                // Render pie chart
                                PieSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y)
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              titleStr: 'Low Risk',
              isSelected: isLowRiskSelected,
              onPress: () {
                setState(() {
                  isLowRiskSelected = !isLowRiskSelected;
                  isMediumRiskSelected = false;
                  isHighRiskSelected = false;
                  isCustomSelected = false;
                  // amountController.text = '';
                  // isAmountError = false;
                  // isAmountValid = false;
                  autoInvestFinalList = autoInvestCategoryDetailList
                      .where((element) => element.categoryType == 'Low Risk')
                      .toList();
                  chartData = [
                    ChartData(
                        'Conservative Risk',
                        double.parse(
                            autoInvestFinalList.first.conservativeRisk ?? '0')),
                    ChartData(
                        'Moderate Risk',
                        double.parse(
                            autoInvestFinalList.first.moderateRisk ?? '0')),
                    ChartData('High Risk ',
                        double.parse(autoInvestFinalList.first.highRisk ?? '0'))
                  ];
                  conservativeRiskController.text =
                      autoInvestFinalList.first.conservativeRisk ?? '0';
                  moderateRiskController.text =
                      autoInvestFinalList.first.moderateRisk ?? '0';
                  highRiskController.text =
                      autoInvestFinalList.first.highRisk ?? '0';
                  isConRiskValid = isValidSum();
                  isValidData = checkValidation();
                  isRiskError = checkRiskValidation();
                });
              },
            ),
            // Column(
            //   children: [
            //     InkWell(
            //       onTap: () {},
            //       child: Container(
            //           decoration: BoxDecoration(
            //             border: Border.all(
            //                 color:
            //                     // widget.isSelected
            //                     //     ? ColorsUtil.blueColor
            //                     //     :
            //                     ColorsUtil.lightestGrey),
            //             borderRadius: BorderRadius.all(Radius.circular(5)),
            //             color:
            //                 // widget.isSelected
            //                 //     ? Colors.blue.shade50
            //                 //     :
            //                 ColorsUtil.lightestGrey,
            //           ),
            //           height: 290,
            //           // ((widget.isUPIBox ?? false) && widget.isSelected) ? 130 : 56,
            //           width: double.infinity,
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.start,
            //                 children: [
            //                   SizedBox(
            //                     width: 16,
            //                   ),
            //                   Visibility(
            //                       child: Theme(
            //                     data: Theme.of(context).copyWith(
            //                       disabledColor: ColorsUtil.blueColor,
            //                     ),
            //                     child: Container(
            //                       height: 22,
            //                       width: 22,
            //                       decoration: BoxDecoration(
            //                           border: Border.all(
            //                               color: ColorsUtil.blueColor,
            //                               // widget.isSelected
            //                               //     ? ColorsUtil.blueColor
            //                               //     : ColorsUtil.lighterGrey,
            //                               width: 1.8),
            //                           borderRadius: BorderRadius.circular(60)),
            //                       child: Center(
            //                         child: Container(
            //                           height: 16,
            //                           width: 16,
            //                           decoration: BoxDecoration(
            //                               color: true
            //                                   ? ColorsUtil.blueColor
            //                                   : ColorsUtil.lightestGrey,
            //                               border: Border.all(
            //                                   color: true
            //                                       ? ColorsUtil.white
            //                                       : ColorsUtil.lightestGrey,
            //                                   width: 1),
            //                               borderRadius:
            //                                   BorderRadius.circular(60)),
            //                         ),
            //                       ),
            //                     ),
            //                   )),
            //                   SizedBox(
            //                     width: 15,
            //                   ),
            //                   Flexible(
            //                     child: Row(
            //                       mainAxisAlignment:
            //                           MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Text(
            //                           'Low Risk Allocation',
            //                           overflow: TextOverflow.ellipsis,
            //                           style: TextStyle(
            //                             fontFamily: CustomFonts.nunito,
            //                             fontSize: 15,
            //                             color: Colors.black,
            //                           ),
            //                         ),
            //                         (false)
            //                             ? Padding(
            //                                 padding: const EdgeInsets.symmetric(
            //                                     horizontal: 4),
            //                                 child: Text(
            //                                   '(Recommended)',
            //                                   overflow: TextOverflow.ellipsis,
            //                                   style: TextStyle(
            //                                     fontFamily: CustomFonts.nunito,
            //                                     fontSize: 11,
            //                                     color: ColorsUtil.lighterGrey,
            //                                   ),
            //                                 ),
            //                               )
            //                             : Container()
            //                       ],
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: true ? 10 : 0,
            //               ),
            //               Container(
            //                 margin: EdgeInsets.symmetric(horizontal: 20),
            //                 child: Column(
            //                   children: [
            //                     Text(
            //                       'With a low risk plan, we prioritize investing your money in low risk investments. Investing in high-risk opportunities is limited.',
            //                       style: TextStyle(
            //                         color: ColorsUtil.lightGrey,
            //                         fontSize: 13,
            //                         fontFamily: CustomFonts.nunito,
            //                       ),
            //                     ),
            //                     Divider(
            //                       color: ColorsUtil.lighterGrey,
            //                     ),
            //                     Container(
            //                       height: 160,
            //                       child: Row(
            //                         mainAxisAlignment: MainAxisAlignment.center,
            //                         crossAxisAlignment:
            //                             CrossAxisAlignment.center,
            //                         children: [
            //                           Expanded(
            //                             child: Center(
            //                               child: Container(
            //                                 // color: Colors.red,
            //                                 // height: 100,
            //                                 child: ListView.builder(
            //                                   itemCount: 3,
            //                                   itemBuilder: (context, i) {
            //                                     return Wrap(
            //                                       children: [
            //                                         Padding(
            //                                           padding:
            //                                               const EdgeInsets.only(
            //                                                   top: 5),
            //                                           child: CircleAvatar(
            //                                             radius: 5,
            //                                             backgroundColor:
            //                                                 Colors.green,
            //                                           ),
            //                                         ),
            //                                         SizedBox(
            //                                           width: 5,
            //                                         ),
            //                                         Text(
            //                                           ' ${chartData[i].y.toStringAsFixed(0)} %',
            //                                           // (NumberFormat.compact()
            //                                           //     .format((chartData[i]
            //                                           //         .y))),
            //                                           style: TextStyle(
            //                                             fontSize: 12,
            //                                             fontFamily:
            //                                                 CustomFonts.nunito,
            //                                             color: ColorsUtil
            //                                                 .viewDetailTabColor,
            //                                             fontWeight:
            //                                                 FontWeight.w600,
            //                                           ),
            //                                         ),
            //                                         SizedBox(
            //                                           width: 5,
            //                                         ),
            //                                         Text(
            //                                           chartData[i].x.toString(),
            //                                           maxLines: 2,
            //                                           style: TextStyle(
            //                                             fontSize: 12,
            //                                             fontFamily:
            //                                                 CustomFonts.nunito,
            //                                             color: ColorsUtil
            //                                                 .viewDetailTabColor,
            //                                             fontWeight:
            //                                                 FontWeight.w500,
            //                                           ),
            //                                         )
            //                                       ],
            //                                     );
            //                                   },
            //                                 ),
            //                               ),
            //                             ),
            //                           ),
            //                           Container(
            //                             height: 160,
            //                             width: 160,
            //                             child: SfCircularChart(
            //                                 // legend: Legend(
            //                                 //     position: LegendPosition.left,
            //                                 //     textStyle: TextStyle(
            //                                 //       fontSize: 12,
            //                                 //       fontFamily: CustomFonts.nunito,
            //                                 //       color: ColorsUtil.greyTabColor,
            //                                 //       fontWeight: FontWeight.w500,
            //                                 //     ),
            //                                 //
            //                                 //     // iconBorderColor:
            //                                 //     //     ColorsUtil.greyTabColor,
            //                                 //     // iconWidth:
            //                                 //     //     10,
            //                                 //     // iconHeight:
            //                                 //     //     10,
            //                                 //     // iconBorderWidth:
            //                                 //     //     10,
            //                                 //     // position: LegendPosition.bottom,
            //                                 //     overflowMode:
            //                                 //         LegendItemOverflowMode.wrap,
            //                                 //     isVisible: true,
            //                                 //     legendItemBuilder: (String name,
            //                                 //         dynamic series,
            //                                 //         dynamic point,
            //                                 //         int index) {
            //                                 //       return Padding(
            //                                 //         padding:
            //                                 //             const EdgeInsets.symmetric(
            //                                 //                 horizontal: 10),
            //                                 //         child: Wrap(
            //                                 //           children: [
            //                                 //             Padding(
            //                                 //               padding:
            //                                 //                   const EdgeInsets.only(
            //                                 //                       top: 4),
            //                                 //               child: CircleAvatar(
            //                                 //                 radius: 6,
            //                                 //                 backgroundColor:
            //                                 //                     ColorsUtil
            //                                 //                         .lighterGrey,
            //                                 //               ),
            //                                 //             ),
            //                                 //             SizedBox(
            //                                 //               width: 5,
            //                                 //             ),
            //                                 //             Container(
            //                                 //                 height: 20,
            //                                 //                 // width: 80,
            //                                 //                 child: Container(
            //                                 //                     child: Text(
            //                                 //                         '''${point.y.round().toString()} ${name}'''))),
            //                                 //           ],
            //                                 //         ),
            //                                 //       );
            //                                 //     }),
            //                                 series: <CircularSeries>[
            //                                   // Render pie chart
            //                                   PieSeries<ChartData, String>(
            //                                       dataSource: chartData,
            //                                       xValueMapper:
            //                                           (ChartData data, _) =>
            //                                               data.x,
            //                                       yValueMapper:
            //                                           (ChartData data, _) =>
            //                                               data.y)
            //                                 ]),
            //                           ),
            //                         ],
            //                       ),
            //                     )
            //                   ],
            //                 ),
            //               )
            //               // ((widget.isUPIBox ?? false) && widget.isSelected)
            //               //     ? widget.UPIWidget ?? Container()
            //               //     : Container()
            //             ],
            //           )),
            //     ),
            //     SizedBox(
            //       height: 15,
            //     )
            //   ],
            // ),
            CheckBox(
              selectedWidget: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Your objective is to earn XIRR of 14% to 16% p.a. You are willing to take slightly more risk.',
                      style: TextStyle(
                        color: ColorsUtil.lightGrey,
                        fontSize: 13,
                        height: 1.8,
                        fontFamily: CustomFonts.nunito,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: ColorsUtil.lighterGrey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chartData.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: CircleAvatar(
                                            radius: 5,
                                            backgroundColor: paletteList[i],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          ' ${chartData[i].y.toStringAsFixed(0)} %',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          chartData[i].x.toString(),
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: SfCircularChart(palette: [
                                ColorsUtil.green1PieColor,
                                ColorsUtil.green2PieColor,
                                ColorsUtil.green3PieColor
                              ], series: <CircularSeries>[
                                // Render pie chart
                                PieSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y)
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              titleStr: 'Moderate Risk',
              isSelected: isMediumRiskSelected,
              onPress: () {
                setState(() {
                  isMediumRiskSelected = !isMediumRiskSelected;
                  isLowRiskSelected = false;
                  isHighRiskSelected = false;
                  isCustomSelected = false;
                  // amountController.text = '';
                  // isAmountError = false;
                  // isAmountValid = false;
                  var autoInvestFinalList = autoInvestCategoryDetailList
                      .where((element) => element.categoryType == 'Medium Risk')
                      .toList();

                  chartData = [
                    ChartData(
                        'Conservative Risk',
                        double.parse(
                            autoInvestFinalList.first.conservativeRisk ?? '0')),
                    ChartData(
                        'Moderate Risk',
                        double.parse(
                            autoInvestFinalList.first.moderateRisk ?? '0')),
                    ChartData('High Risk ',
                        double.parse(autoInvestFinalList.first.highRisk ?? '0'))
                  ];
                  conservativeRiskController.text =
                      autoInvestFinalList.first.conservativeRisk ?? '0';
                  moderateRiskController.text =
                      autoInvestFinalList.first.moderateRisk ?? '0';
                  highRiskController.text =
                      autoInvestFinalList.first.highRisk ?? '0';
                  isConRiskValid = isValidSum();
                  isValidData = checkValidation();
                  isRiskError = checkRiskValidation();
                });
              },
            ),
            CheckBox(
              selectedWidget: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'Your objective is to earn XIRR of 16%+ p.a. You are willing to take higher risk for the yield.',
                      style: TextStyle(
                        color: ColorsUtil.lightGrey,
                        fontSize: 13,
                        height: 1.8,
                        fontFamily: CustomFonts.nunito,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: ColorsUtil.lighterGrey,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              // color: Colors.red,
                              // height: 100,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: chartData.length,
                                itemBuilder: (context, i) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: CircleAvatar(
                                            radius: 5,
                                            backgroundColor: paletteList[i],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          ' ${chartData[i].y.toStringAsFixed(0)} %',
                                          // (NumberFormat.compact()
                                          //     .format((chartData[i]
                                          //         .y))),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          chartData[i].x.toString(),
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: CustomFonts.nunito,
                                            color:
                                                ColorsUtil.viewDetailTabColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: SfCircularChart(palette: [
                                ColorsUtil.green1PieColor,
                                ColorsUtil.green2PieColor,
                                ColorsUtil.green3PieColor
                              ], series: <CircularSeries>[
                                // Render pie chart
                                PieSeries<ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y)
                              ]),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              titleStr: 'High Risk',
              isSelected: isHighRiskSelected,
              onPress: () {
                setState(() {
                  isHighRiskSelected = !isHighRiskSelected;
                  isMediumRiskSelected = false;
                  isLowRiskSelected = false;
                  isCustomSelected = false;
                  // amountController.text = '';
                  // isAmountError = false;
                  // isAmountValid = false;
                  var autoInvestFinalList = autoInvestCategoryDetailList
                      .where((element) => element.categoryType == 'High Risk')
                      .toList();

                  chartData = [
                    ChartData(
                        'Conservative Risk',
                        double.parse(
                            autoInvestFinalList.first.conservativeRisk ?? '0')),
                    ChartData(
                        'Moderate Risk',
                        double.parse(
                            autoInvestFinalList.first.moderateRisk ?? '0')),
                    ChartData('High Risk ',
                        double.parse(autoInvestFinalList.first.highRisk ?? '0'))
                  ];
                  conservativeRiskController.text =
                      autoInvestFinalList.first.conservativeRisk ?? '0';
                  moderateRiskController.text =
                      autoInvestFinalList.first.moderateRisk ?? '0';
                  highRiskController.text =
                      autoInvestFinalList.first.highRisk ?? '0';
                  isConRiskValid = isValidSum();
                  isValidData = checkValidation();
                  isRiskError = checkRiskValidation();
                });
              },
            ),
            CheckBox(
              selectedWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am an expert in Investing. I will build my own allocation.',
                      style: TextStyle(
                        color: ColorsUtil.lightGrey,
                        fontSize: 12,
                        fontFamily: CustomFonts.nunito,
                      ),
                    ),
                    Divider(
                      color: ColorsUtil.lighterGrey,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    InputWidget(
                      hintStr: 'Conservative Risk',
                      heading: 'Conservative Risk',
                      controller: conservativeRiskController,
                      isValid: isConRiskValid && !isRiskError,
                      isError: isRiskError,
                      keyboardType: TextInputType.number,
                      horizontalMargin: 0,
                      suffixText: '%',
                      onChange: (String input) {
                        setState(() {
                          isConRiskValid = isValidSum();
                          isValidData = checkValidation();
                          isRiskError = checkRiskValidation();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    InputWidget(
                      hintStr: 'Moderate Risk',
                      heading: 'Moderate Risk',
                      isValid: isModerateRiskValid && !isRiskError,
                      isError: isRiskError,
                      controller: moderateRiskController,
                      keyboardType: TextInputType.number,
                      horizontalMargin: 0,
                      suffixText: '%',
                      onChange: (String input) {
                        setState(() {
                          isModerateRiskValid = isValidSum();
                          isValidData = checkValidation();
                          isRiskError = checkRiskValidation();
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    InputWidget(
                      hintStr: 'High Risk',
                      heading: 'High Risk',
                      isValid: isHighRiskValid && !isRiskError,
                      isError: isRiskError,
                      controller: highRiskController,
                      keyboardType: TextInputType.number,
                      horizontalMargin: 0,
                      suffixText: '%',
                      onChange: (String input) {
                        setState(() {
                          isHighRiskValid = isValidSum();
                          isValidData = checkValidation();
                          isRiskError = checkRiskValidation();
                        });
                      },
                    ),
                  ],
                ),
              ),
              titleStr: 'Custom',
              isSelected: isCustomSelected,
              onPress: () {
                setState(() {
                  if (!isCustomSelected) {
                    conservativeRiskController.clear();
                    moderateRiskController.clear();
                    highRiskController.clear();
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        // <-- SEE HERE
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15.0),
                        ),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveWidget.isSmallScreen(context)
                            ? screenSize.width
                            : screenSize.width * .35,
                      ),
                      builder: (BuildContext context) => Container(
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
                            margin: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  LocalImages.caution_icon,
                                  width: 44,
                                  height: 35,
                                  color: ColorsUtil.redColor,
                                ),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Text(
                                  'Are you sure you want to Customize Auto Diversification ?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 19.0,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        borderColor: ColorsUtil.blueColor,
                                        titleStr: 'Yes',
                                        bgColor: ColorsUtil.white,
                                        textColor: ColorsUtil.blueColor,
                                        onPress: () {
                                          setState(() {
                                            isCustomSelected =
                                                !isCustomSelected;
                                            isMediumRiskSelected = false;
                                            isHighRiskSelected = false;
                                            isLowRiskSelected = false;
                                            // amountController.text = '';
                                            // isAmountError = false;
                                            // isAmountValid = false;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomButton(
                                        borderColor: ColorsUtil.blueColor,
                                        titleStr: 'No',
                                        bgColor: ColorsUtil.blueColor,
                                        textColor: ColorsUtil.white,
                                        onPress: () {
                                          setState(() {
                                            isLowRiskSelected = false;
                                            isMediumRiskSelected = false;
                                            isHighRiskSelected = false;
                                            isCustomSelected = false;
                                            // amountController.text = '';
                                            // isAmountError = false;
                                            // isAmountValid = false;
                                          });

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    isCustomSelected = !isCustomSelected;
                    isMediumRiskSelected = false;
                    isHighRiskSelected = false;
                    isLowRiskSelected = false;
                    // amountController.text = '';
                    // isAmountError = false;
                    // isAmountValid = false;

                  }
                });
              },
            ),
            // InputWidget(
            //   hintStr: 'Enter Amount',
            //   heading: 'Enter Amount',
            //   controller: amountController,
            //   isError: isAmountError,
            //   isValid: isAmountValid,
            //   alertStr: isAmountError
            //       ? 'Amount should be between 1000 to 5000 and multiple of 1000.'
            //       : '',
            //   keyboardType: TextInputType.number,
            //   leftIcon: Text(
            //     '\u{20B9}',
            //     style: TextStyle(fontSize: 25, color: ColorsUtil.lightBlack),
            //   ),
            //   onChange: (String input) {
            //     setState(() {
            //       isAmountValid = checkAmountValidation();
            //       isAmountError = !checkAmountValidation();
            //       isValidData = checkValidation();
            //     });
            //   },
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 20, top: 30, bottom: 20),
            //   child: Text(
            //     'Set Lending Criteria',
            //     style: TextStyle(
            //         fontFamily: CustomFonts.nunito,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 16),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 25, right: 15),
            //   child: Row(
            //     children: [
            //       Container(
            //         child: Column(
            //           children: [
            //             Container(
            //               width: dotSize,
            //               height: dotSize,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(dotSize / 2),
            //                 color: ColorsUtil.circleGrey,
            //               ),
            //             ),
            //             Container(
            //               height: 60,
            //               width: 1,
            //               color: ColorsUtil.circleGrey,
            //             ),
            //             Container(
            //               width: dotSize,
            //               height: dotSize,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(dotSize / 2),
            //                 color: ColorsUtil.circleGrey,
            //               ),
            //             ),
            //             Container(
            //               height: 60,
            //               width: 1,
            //               color: ColorsUtil.circleGrey,
            //             ),
            //             Container(
            //               width: dotSize,
            //               height: dotSize,
            //               decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(dotSize / 2),
            //                 color: ColorsUtil.circleGrey,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Flexible(
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 15),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               InputWidget(
            //                 hintStr: 'Conservative Risk',
            //                 heading: 'Conservative Risk',
            //                 // conservativeRiskController.text.isNotEmpty
            //                 //     ? "Conservative Risk"
            //                 //     : "",
            //                 controller: conservativeRiskController,
            //                 isValid: isConRiskValid && !isRiskError,
            //                 isError: isRiskError,
            //                 keyboardType: TextInputType.number,
            //                 horizontalMargin: 0,
            //                 rightIcon: Text(
            //                   '%',
            //                   style: TextStyle(
            //                     fontSize: 20,
            //                     fontFamily: CustomFonts.nunito,
            //                     fontWeight: FontWeight.w700,
            //                   ),
            //                 ),
            //                 onChange: (String input) {
            //                   setState(() {
            //                     isConRiskValid = isValidSum();
            //                     isValidData = checkValidation();
            //                     isRiskError = checkRiskValidation();
            //                   });
            //                 },
            //               ),
            //               SizedBox(height: 20),
            //               InputWidget(
            //                 hintStr: 'Moderate Risk',
            //                 heading: 'Moderate Risk',
            //                 // moderateRiskController.text.isNotEmpty
            //                 //     ? "Moderate Risk"
            //                 //     : "",
            //                 isValid: isModerateRiskValid && !isRiskError,
            //                 isError: isRiskError,
            //                 controller: moderateRiskController,
            //                 keyboardType: TextInputType.number,
            //                 horizontalMargin: 0,
            //                 rightIcon: Text(
            //                   '%',
            //                   style: TextStyle(
            //                     fontSize: 20,
            //                     fontFamily: CustomFonts.nunito,
            //                     fontWeight: FontWeight.w700,
            //                   ),
            //                 ),
            //                 onChange: (String input) {
            //                   setState(() {
            //                     isModerateRiskValid = isValidSum();
            //                     isValidData = checkValidation();
            //                     isRiskError = checkRiskValidation();
            //                   });
            //                 },
            //               ),
            //               SizedBox(height: 20),
            //               InputWidget(
            //                 hintStr: 'High Risk',
            //                 heading: 'High Risk',
            //                 // highRiskController.text.isNotEmpty
            //                 //     ? "High Risk"
            //                 //     : "",
            //                 isValid: isHighRiskValid && !isRiskError,
            //                 isError: isRiskError,
            //                 controller: highRiskController,
            //                 keyboardType: TextInputType.number,
            //                 horizontalMargin: 0,
            //                 rightIcon: Text(
            //                   '%',
            //                   style: TextStyle(
            //                     fontSize: 20,
            //                     fontFamily: CustomFonts.nunito,
            //                     fontWeight: FontWeight.w700,
            //                   ),
            //                 ),
            //                 onChange: (String input) {
            //                   setState(() {
            //                     isHighRiskValid = isValidSum();
            //                     isValidData = checkValidation();
            //                     isRiskError = checkRiskValidation();
            //                   });
            //                 },
            //               ),
            //             ],
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            Visibility(
              visible: isRiskError && isCustomSelected,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                margin: EdgeInsets.only(
                  top: 10,
                ),
                decoration: BoxDecoration(
                  color: ColorsUtil.redColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error,
                      color: ColorsUtil.redColor,
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'The sum of all 3 Risk Factors should be 100%. Please try again by Changing the values & increments of 10%.',
                        style: TextStyle(
                          fontFamily: CustomFonts.nunito,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              titleStr: 'Save',
              isDisable: !switchValue ||
                  (!isLowRiskSelected &&
                      !isMediumRiskSelected &&
                      !isHighRiskSelected &&
                      (!isCustomSelected || !isValidData)),
              onPress: () {
                final userStage =
                    context.read<AppStateProvider>().userDetails?.userStage ??
                        1;
                if (!isOtpVerified && userStage > 3) {
                  startOtpVerification(false);
                } else {
                  saveUpdateData();
                }
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class CheckBox extends StatefulWidget {
  String titleStr;
  VoidCallback onPress;
  bool isSelected;

  Widget? selectedWidget;

  CheckBox(
      {Key? key,
      this.titleStr = '',
      required this.onPress,
      this.isSelected = false,
      this.selectedWidget})
      : super(key: key);

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: widget.onPress,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: ColorsUtil.lightestGrey),
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: ColorsUtil.lightestGrey,
              ),
              // height: widget.isSelected ? 320 : 56,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Visibility(
                          child: Theme(
                        data: Theme.of(context).copyWith(
                          disabledColor: ColorsUtil.blueColor,
                        ),
                        child: Container(
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: ColorsUtil.blueColor,
                                  // widget.isSelected
                                  //     ? ColorsUtil.blueColor
                                  //     : ColorsUtil.lighterGrey,
                                  width: 1.8),
                              borderRadius: BorderRadius.circular(60)),
                          child: Center(
                            child: Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                  color: widget.isSelected
                                      ? ColorsUtil.blueColor
                                      : ColorsUtil.lightestGrey,
                                  border: Border.all(
                                      color: widget.isSelected
                                          ? ColorsUtil.white
                                          : ColorsUtil.lightestGrey,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(60)),
                            ),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.titleStr,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: CustomFonts.nunito,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            widget.titleStr == 'Low Risk'
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      '(Recommended)',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: CustomFonts.nunito,
                                        fontSize: 11,
                                        color: ColorsUtil.lighterGrey,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: widget.isSelected ? 15 : 0,
                  ),
                  widget.isSelected
                      ? widget.selectedWidget ?? Container()
                      : Container()
                ],
              )),
        ),
        SizedBox(
          height: 15,
        )
      ],
    );
  }
}
