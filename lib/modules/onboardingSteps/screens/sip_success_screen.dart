import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants.dart';

class UPISuccessScreen extends StatefulWidget {
  String paymentMethod;

  UPISuccessScreen({required this.paymentMethod, Key? key}) : super(key: key);

  @override
  _UPISuccessScreenState createState() => _UPISuccessScreenState();
}

class _UPISuccessScreenState extends State<UPISuccessScreen> {
  bool _isLoading = false;

  String ScreenTitle = '';
  var amount;
  var installment;
  var tenure;
  var startDate;
  var endDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPaymentName();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
  }

  getData() {
    amount = Constants.sipAmount * Constants.sipTenure;
    installment = Constants.sipAmount;
    tenure = Constants.sipTenure;
    if (int.parse(Constants.sipDate) < DateTime.now().day) {
      print('month + 1');
      startDate = DateTime(DateTime.now().year, DateTime.now().month + 1,
          int.parse(Constants.sipDate));
    } else {
      print('month');
      startDate = DateTime(DateTime.now().year, DateTime.now().month,
          int.parse(Constants.sipDate));
    }

    endDate = DateTime(
        startDate.year,
        (startDate.month + Constants.sipTenure - 1),
        int.parse(Constants.sipDate));
  }

  getPaymentName() {
    if (Constants.sipPaymnentMethod == 'UPI') {
      ScreenTitle = 'UPI E-Nach';
    } else if (Constants.sipPaymnentMethod == 'netbanking') {
      ScreenTitle = 'Net Banking E-Nach';
    } else {
      ScreenTitle = 'Debit card E-Nach';
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
                  ScreenTitle,
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
                                            titleStr: 'UPI E-Nach',
                                            desStr: '',
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
                child: Container(
              width: double.infinity,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your mandate is registered successfully',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.blueColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Table(
                          children: [
                            TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'SIP Amount',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '₹ ${amount.toString().commaAddedValue()}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Monthly Installment',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '₹ ${installment.toString().commaAddedValue()}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Tenure',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  '${tenure} Months',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Start Date',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  DateFormat('MMMM dd, yyyy')
                                      .format(startDate)
                                      .toString(),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'End Date',
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  DateFormat('MMMM dd, yyyy')
                                      .format(endDate)
                                      .toString(),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: ColorsUtil.blueColor),
                                ),
                              ),
                            ])
                          ],
                        ),
                      )
                    ],
                  )),
            )),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Note: \nThe First Installment for your SIP will be debited on 3rd of the ongoing month. Post that, the installments will be debited on 10th of every month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: CustomFonts.nunito,
                      color: ColorsUtil.greyPlaceHolder,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              CustomButton(
                titleStr: 'Done',
                onPress: () {
                  // context.pushNamed(RoutesName.UPIScreen3);
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
}
