import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/utils/api_constant.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/constants.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UPIScreenSecond extends StatefulWidget {
  const UPIScreenSecond({Key? key}) : super(key: key);

  @override
  _UPIScreenSecondState createState() => _UPIScreenSecondState();
}

class _UPIScreenSecondState extends State<UPIScreenSecond> {
  bool _isLoading = false;
  var amount;
  var installment;
  var tenure;
  var startDate;
  var endDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
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

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
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
                  'UPI E-Nach',
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
                        'UPI Mandate',
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
                                      .toString(), // 'March 20, 2023',
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
                                  // 'February 20, 2024',
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
              CustomButton(
                titleStr: 'Proceed',
                onPress: () async {
                  setState(() => _isLoading = true);
                  final provider = context.read<AppStateProvider>();
                  final param = <String, dynamic>{
                    ApiParams.customerId: provider.customerId,
                    ApiParams.custVirAdd: Constants.sipUpiId ?? '',
                    ApiParams.amount: installment.toString(),
                    ApiParams.monthDuration: tenure,
                    ApiParams.amountMaximum: Constants.sipAmount,
                    ApiParams.dateValue: Constants.sipDate,
                  };
                  final ok = await provider.createSipUpiMandate(param);
                  setState(() => _isLoading = false);
                  if (!ok) {
                    Utils.showAlert(
                        context: context,
                        msg: 'Failed to create UPI mandate. Please try again.');
                    return;
                  }
                  context.pushNamed(RoutesName.UPIScreen3);
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
