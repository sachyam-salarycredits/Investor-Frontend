import 'package:Monexo/modules/marketplace/models/primary_loan_details.dart';
import 'package:Monexo/modules/marketplace/widgets/outlined_popup_container.dart';
import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:provider/src/provider.dart';

//UI for mobile

class PrimaryLoanDetailsDialog extends StatelessWidget {
  final int index;

  const PrimaryLoanDetailsDialog({required this.index, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrimaryLoanDetails?>(
        future: context.read<AppStateProvider>().getPrimaryLoanDetails(index),
        builder: (context, snap) {
          return AlertDialog(
            titlePadding: EdgeInsets.symmetric(horizontal: 0.0),
            insetPadding: EdgeInsets.symmetric(horizontal: 15.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(width: 1, color: ColorsUtil.lighterGrey)),
            title: Builder(
              builder: (context) {
                if (!snap.hasData) {
                  return Container(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snap.data == null) {
                  return Container(
                      height: 100, child: Center(child: Text(" No Data")));
                }

                final loanDetails = snap.data!;
                final primaryLoanModel =
                    context.read<AppStateProvider>().primaryMarketLoans![index];
                return ResponsiveWidget.isSmallScreen(context)
                    ? //mobile view
                    Container(
                        height: MediaQuery.of(context).size.height / 1.3,
                        // width: MediaQuery.of(context).size.height * .5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Loan details',
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 18.0,
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w700),
                                    ),

                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: ColorsUtil.blueColorCart,
                                        size: 30.0,
                                      ),
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Icon(
                                    //       Icons.add,
                                    //       color: ColorsUtil.greenText,
                                    //     ),
                                    //     Text(
                                    //       'Fund Now',
                                    //       style: TextStyle(
                                    //           color: ColorsUtil.greenText,
                                    //           fontFamily: CustomFonts.nunito,
                                    //           fontSize: 16.0,
                                    //           fontWeight: FontWeight.w700),
                                    //     ),
                                    //     SizedBox(
                                    //       width: 17,
                                    //     ),
                                    //     InkWell(
                                    //       highlightColor: Colors.transparent,
                                    //       onTap: () {
                                    //         Navigator.pop(context);
                                    //       },
                                    //       child: Icon(
                                    //         Icons.close,
                                    //         size: 30.0,
                                    //       ),
                                    //     )
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: ColorsUtil.lighterGrey,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: FittedBox(
                                  child: Row(
                                    children: [
                                      Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 270),
                                        child: Text(
                                          '${primaryLoanModel.productName} (${primaryLoanModel.customerName})',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: ColorsUtil.blueColorCart,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: CustomFonts.nunito,
                                              fontSize: 16),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                          color: ColorsUtil.circleGrey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 4),
                                        child: Text(
                                          '${primaryLoanModel.category}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: CustomFonts.nunito,
                                            fontWeight: FontWeight.w800,
                                            color: ColorsUtil.blueColorCart,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            height: 75,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.55,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Loan Amount',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '₹ ${primaryLoanModel.loanAmount.commaAddedValue()}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                border: Border.all(
                                                    color: ColorsUtil
                                                        .marketCardContainer1),
                                                color: ColorsUtil
                                                    .marketCardContainer),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.55,
                                            padding: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            height: 75,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Frequency',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '${primaryLoanModel.frequency}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                border: Border.all(
                                                    color: ColorsUtil
                                                        .marketCardContainer1),
                                                color: ColorsUtil
                                                    .marketCardContainer),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.55,
                                            padding: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            height: 75,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Duration',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '${primaryLoanModel.tenor.round()} Mo',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                border: Border.all(
                                                    color: ColorsUtil
                                                        .marketCardContainer1),
                                                color: ColorsUtil
                                                    .marketCardContainer),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.55,
                                            padding: EdgeInsets.only(
                                              left: 10,
                                            ),
                                            height: 75,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Returns',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  '${primaryLoanModel.lenderXIRR}%',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(7.0),
                                                border: Border.all(
                                                    color: ColorsUtil
                                                        .marketCardContainer1),
                                                color: ColorsUtil
                                                    .marketCardContainer),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: ColorsUtil.lighterGrey,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Loan Already Committed',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: CustomFonts.nunito,
                                          color: ColorsUtil.blueColorCart,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    SliderTheme(
                                      child: Slider(
                                        value: primaryLoanModel
                                            .getCommittedPercentage(),
                                        max: 100,
                                        min: 0,
                                        activeColor: ColorsUtil.blueColorCart,
                                        inactiveColor:
                                            ColorsUtil.marketCardContainer1,
                                        onChanged: (double value) {},
                                      ),
                                      data: SliderTheme.of(context).copyWith(
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 0.0),
                                          trackHeight: 10,
                                          thumbColor: Colors.transparent,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 0.0)),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹ ${primaryLoanModel.alreadyCommitedAmount.commaAddedValue()}',
                                              style: TextStyle(
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)
                                                  .copyWith(
                                                color: ColorsUtil.blueColorCart,
                                              ),
                                            ),
                                            Text(
                                              '${primaryLoanModel.getCommittedPercentage().toStringAsFixed(1)} %',
                                              style: TextStyle(
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)
                                                  .copyWith(
                                                color: ColorsUtil.blueColorCart,
                                              ),
                                            ),
                                          ]),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: ColorsUtil.lighterGrey,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'About borrower',
                                      style: TextStyle(
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Table(
                                          defaultColumnWidth:
                                              FixedColumnWidth(150.0),
                                          children: [
                                            TableRow(children: [
                                              Text(
                                                'Age:',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    height: 1.8),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  '${loanDetails.aboutBorrower?.age} Years',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.8),
                                                ),
                                              ),
                                            ]),
                                            TableRow(children: [
                                              Text(
                                                'Gender:',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    height: 1.8),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  '${loanDetails.aboutBorrower?.gender}',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.8),
                                                ),
                                              ),
                                            ]),
                                            TableRow(children: [
                                              Text(
                                                'Borrower state :',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    height: 1.8),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  '${loanDetails.aboutBorrower?.state}',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.8),
                                                ),
                                              ),
                                            ]),
                                            TableRow(children: [
                                              Text(
                                                'Employment type :',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    height: 1.8),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  '${loanDetails.aboutBorrower?.employementType}',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.8),
                                                ),
                                              ),
                                            ]),
                                            TableRow(children: [
                                              Text(
                                                'Role :',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    height: 1.8),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Text(
                                                  '${loanDetails.aboutBorrower?.role}',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      height: 1.8),
                                                ),
                                              ),
                                            ]),
                                          ]),
                                      Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Divider(
                                                thickness: 1,
                                                height: 1,
                                                color: ColorsUtil.lighterGrey,
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Financial Details',
                                                    style: TextStyle(
                                                        color: ColorsUtil
                                                            .blueColorCart,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Table(
                                                      defaultColumnWidth:
                                                          FixedColumnWidth(
                                                              150.0),
                                                      children: [
                                                        TableRow(children: [
                                                          Text(
                                                            'Current Net Salary :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '₹ ${loanDetails.financialDetails?.currentNetSalary}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Debt Service Ratio :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.debtServiceRatio}%',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Monexo Rating :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.monexoRating}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Bureau Score :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.bureauScore}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Vintage in Bureau :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.vintageInBureauMonths} Mo',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Digital Bank Verification :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.digitalBankVerification}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        // TableRow(children: [
                                                        //   Text(
                                                        //     'Mobile App Downloaded :',
                                                        //     textAlign:
                                                        //         TextAlign.left,
                                                        //     style: TextStyle(
                                                        //         color: ColorsUtil
                                                        //             .lighterGrey,
                                                        //         fontFamily:
                                                        //             CustomFonts
                                                        //                 .roboto,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w400,
                                                        //         fontSize: 16,
                                                        //         height: 1.8),
                                                        //   ),
                                                        //   Padding(
                                                        //     padding:
                                                        //         const EdgeInsets
                                                        //                 .only(
                                                        //             left: 10.0),
                                                        //     child: Text(
                                                        //       '${loanDetails.financialDetails?.mobileAppDownload}',
                                                        //       style: TextStyle(
                                                        //           color: ColorsUtil
                                                        //               .dividerColor,
                                                        //           fontFamily:
                                                        //               CustomFonts
                                                        //                   .roboto,
                                                        //           fontWeight:
                                                        //               FontWeight
                                                        //                   .w500,
                                                        //           fontSize: 16,
                                                        //           height: 1.8),
                                                        //     ),
                                                        //   ),
                                                        // ]),
                                                      ]),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Divider(
                                                thickness: 1,
                                                height: 1,
                                                color: ColorsUtil.lighterGrey,
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Credit Bureau of Active Loan Data',
                                                    style: TextStyle(
                                                        color: ColorsUtil
                                                            .blueColorCart,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    child: Table(
                                                        defaultVerticalAlignment:
                                                            TableCellVerticalAlignment
                                                                .middle,
                                                        // defaultColumnWidth:
                                                        //     FixedColumnWidth(
                                                        //         140.0),

                                                        children: [
                                                          TableRow(children: [
                                                            Text(
                                                              'Loan type',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart
                                                                      .withAlpha(
                                                                          100),
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  height: 1.8),
                                                            ),
                                                            Text(
                                                              'No. of Loans',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart
                                                                      .withAlpha(
                                                                          100),
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  height: 1.8),
                                                            ),
                                                            Text(
                                                              'POS',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart
                                                                      .withAlpha(
                                                                          100),
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 14,
                                                                  height: 1.8),
                                                            ),
                                                          ]),
                                                          TableRow(children: [
                                                            Text(
                                                              'Credit Cards',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.creditCards?.numberLoan}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.creditCards?.pos}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                          ]),
                                                          TableRow(children: [
                                                            Text(
                                                              'Personal Loans',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 1.5),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.personalLoan?.numberLoan}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.personalLoan?.pos}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                          ]),
                                                          TableRow(children: [
                                                            Text(
                                                              'Home Loans',
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.homeLoan?.numberLoan}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                            Text(
                                                              '${loanDetails.activeLoans?.homeLoan?.pos}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  height: 2.0),
                                                            ),
                                                          ]),
                                                          // TableRow(children: [
                                                          //   Text(
                                                          //     'Gold Loans',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .left,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          //   Text(
                                                          //     '${loanDetails.activeLoans?.goldLoan?.numberLoan}',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .center,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          //   Text(
                                                          //     '${loanDetails.activeLoans?.goldLoan?.pos}',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .center,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          // ]),
                                                          // TableRow(children: [
                                                          //   Text(
                                                          //     'Other Loans',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .left,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          //   Text(
                                                          //     '${loanDetails.activeLoans?.otherLoan?.numberLoan}',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .center,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          //   Text(
                                                          //     '${loanDetails.activeLoans?.otherLoan?.pos}',
                                                          //     textAlign:
                                                          //         TextAlign
                                                          //             .center,
                                                          //     style: TextStyle(
                                                          //         color: ColorsUtil
                                                          //             .dividerColor,
                                                          //         fontFamily:
                                                          //             CustomFonts
                                                          //                 .roboto,
                                                          //         fontWeight:
                                                          //             FontWeight
                                                          //                 .w500,
                                                          //         fontSize: 14,
                                                          //         height: 2.0),
                                                          //   ),
                                                          // ]),
                                                        ]),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : //web view
                    Container(
                        height: MediaQuery.of(context).size.height / 1.1,
                        width: MediaQuery.of(context).size.width * .8,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 18),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${primaryLoanModel.productName} (${primaryLoanModel.customerName})',
                                      style: TextStyle(
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 20.0,
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: ColorsUtil.blueColorCart,
                                        size: 30.0,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: ColorsUtil.lighterGrey,
                              ),
                              Container(
                                height: 97,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: HeadingValueContainer(
                                        heading: "Loan Amount",
                                        value:
                                            "₹ ${primaryLoanModel.loanAmount.commaAddedValue()}",
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: HeadingValueContainer(
                                        heading: "Tenor",
                                        value:
                                            '${primaryLoanModel.tenor.round()} Mo',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: HeadingValueContainer(
                                        heading: "Frequency",
                                        value: "${primaryLoanModel.frequency}",
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: HeadingValueContainer(
                                        heading: "Lender XIRR",
                                        value:
                                            '${primaryLoanModel.lenderXIRR}%',
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: ColorsUtil.lighterGrey,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Loan Already Committed',
                                      style: TextStyle(
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    SliderTheme(
                                      child: Slider(
                                        value: primaryLoanModel
                                            .getCommittedPercentage(),
                                        max: 100,
                                        min: 0,
                                        activeColor: ColorsUtil.blueColorCart,
                                        inactiveColor: ColorsUtil.blueColorCart
                                            .withAlpha(100),
                                        onChanged: (double value) {},
                                      ),
                                      data: SliderTheme.of(context).copyWith(
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 0.0),
                                          trackHeight: 10,
                                          thumbColor: Colors.transparent,
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 0.0)),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹ ${primaryLoanModel.alreadyCommitedAmount.commaAddedValue()}',
                                              style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)
                                                  .copyWith(color: Colors.grey),
                                            ),
                                            Text(
                                              '${primaryLoanModel.getCommittedPercentage().toStringAsFixed(1)} %',
                                              style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)
                                                  .copyWith(color: Colors.grey),
                                            ),
                                          ]),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: ColorsUtil.lighterGrey,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          height:
                                              ResponsiveWidget.isMediumScreen(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      2
                                                  : 370,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: Border.all(
                                                  color: ColorsUtil
                                                      .marketPlaceContainer2)),
                                          padding: EdgeInsets.only(
                                              top: 30, left: 30),
                                          margin: EdgeInsets.only(
                                              top: 35, right: 30, bottom: 30),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'About borrower',
                                                  style: TextStyle(
                                                      color: ColorsUtil
                                                          .blueColorCart,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily:
                                                          CustomFonts.nunito,
                                                      fontSize: 20),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Table(
                                                    defaultColumnWidth:
                                                        FixedColumnWidth(200.0),
                                                    children: [
                                                      TableRow(children: [
                                                        Text(
                                                          'Age:',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color: ColorsUtil
                                                                  .blueColorCart
                                                                  .withAlpha(
                                                                      100),
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 16,
                                                              height: 1.8),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            '${loanDetails.aboutBorrower?.age} Years',
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart,
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        Text(
                                                          'Gender:',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color: ColorsUtil
                                                                  .blueColorCart
                                                                  .withAlpha(
                                                                      100),
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 16,
                                                              height: 1.8),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            '${loanDetails.aboutBorrower?.gender}',
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart,
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        Text(
                                                          'Borrower state :',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color: ColorsUtil
                                                                  .blueColorCart
                                                                  .withAlpha(
                                                                      100),
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 16,
                                                              height: 1.8),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            '${loanDetails.aboutBorrower?.state}',
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart,
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        Text(
                                                          'Employment type :',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color: ColorsUtil
                                                                  .blueColorCart
                                                                  .withAlpha(
                                                                      100),
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 16,
                                                              height: 1.8),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            '${loanDetails.aboutBorrower?.employementType}',
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart,
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        Text(
                                                          'Role :',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color: ColorsUtil
                                                                  .blueColorCart
                                                                  .withAlpha(
                                                                      100),
                                                              fontFamily:
                                                                  CustomFonts
                                                                      .nunito,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 16,
                                                              height: 1.8),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            '${loanDetails.aboutBorrower?.role}',
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart,
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                        ),
                                                      ]),
                                                    ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            height:
                                                ResponsiveWidget.isMediumScreen(context)
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        2
                                                    : 370,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                border: Border.all(
                                                    color: ColorsUtil
                                                        .marketPlaceContainer2)),
                                            padding: EdgeInsets.only(
                                                top: 30, left: 30),
                                            margin: EdgeInsets.only(
                                                top: 35, bottom: 30),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Financial Details',
                                                    style: TextStyle(
                                                        color: ColorsUtil
                                                            .blueColorCart,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontSize: 20),
                                                  ),
                                                  SizedBox(
                                                    height: 25,
                                                  ),
                                                  Table(
                                                      defaultColumnWidth:
                                                          FixedColumnWidth(
                                                              200.0),
                                                      children: [
                                                        TableRow(children: [
                                                          Text(
                                                            'Current Net Salary :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '₹ ${loanDetails.financialDetails?.currentNetSalary}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Debt Service Ratio :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.debtServiceRatio}%',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Monexo Rating :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.monexoRating}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Bureau Score :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.bureauScore}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Vintage in Bureau :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.vintageInBureauMonths} Mo',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        TableRow(children: [
                                                          Text(
                                                            'Digital Bank Verification :',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                color: ColorsUtil
                                                                    .blueColorCart
                                                                    .withAlpha(
                                                                        100),
                                                                fontFamily:
                                                                    CustomFonts
                                                                        .nunito,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 16,
                                                                height: 1.8),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 20.0),
                                                            child: Text(
                                                              '${loanDetails.financialDetails?.digitalBankVerification}',
                                                              style: TextStyle(
                                                                  color: ColorsUtil
                                                                      .blueColorCart,
                                                                  fontFamily:
                                                                      CustomFonts
                                                                          .nunito,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 16,
                                                                  height: 1.8),
                                                            ),
                                                          ),
                                                        ]),
                                                        // TableRow(children: [
                                                        //   Text(
                                                        //     'Mobile App Downloaded :',
                                                        //     textAlign:
                                                        //         TextAlign.left,
                                                        //     style: TextStyle(
                                                        //         color: ColorsUtil
                                                        //             .lighterGrey,
                                                        //         fontFamily:
                                                        //             CustomFonts
                                                        //                 .roboto,
                                                        //         fontWeight:
                                                        //             FontWeight
                                                        //                 .w400,
                                                        //         fontSize: 16,
                                                        //         height: 1.8),
                                                        //   ),
                                                        //   Padding(
                                                        //     padding:
                                                        //         const EdgeInsets
                                                        //                 .only(
                                                        //             left: 20.0),
                                                        //     child: Text(
                                                        //       '${loanDetails.financialDetails?.mobileAppDownload}',
                                                        //       style: TextStyle(
                                                        //           color: ColorsUtil
                                                        //               .dividerColor,
                                                        //           fontFamily:
                                                        //               CustomFonts
                                                        //                   .roboto,
                                                        //           fontWeight:
                                                        //               FontWeight
                                                        //                   .w500,
                                                        //           fontSize: 16,
                                                        //           height: 1.8),
                                                        //     ),
                                                        //   ),
                                                        // ]),
                                                      ]),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: ColorsUtil.lighterGrey,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      'Credit Bureau of Active Loan Data',
                                      style: TextStyle(
                                          color: ColorsUtil.blueColorCart,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: CustomFonts.nunito,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Table(
                                        defaultColumnWidth:
                                            FixedColumnWidth(270.0),

                                        ///180 if the commented loans used
                                        children: [
                                          TableRow(children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30),
                                              color: ColorsUtil
                                                  .marketCardContainer1,
                                              child: Text(
                                                'Loan type',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            Container(
                                              color: ColorsUtil
                                                  .marketCardContainer1,
                                              child: Text(
                                                'Credit Cards',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            Container(
                                              color: ColorsUtil
                                                  .marketCardContainer1,
                                              child: Text(
                                                'Personal Loans',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            Container(
                                              color: ColorsUtil
                                                  .marketCardContainer1,
                                              child: Text(
                                                'Home Loans',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart,
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            // Container(
                                            //   color: Color(0xffF4F9F5),
                                            //   child: Text(
                                            //     'Gold Loans',
                                            //     textAlign: TextAlign.left,
                                            //     style: TextStyle(
                                            //         // color: ColorsUtil.lighterGrey,
                                            //         fontFamily:
                                            //             CustomFonts.roboto,
                                            //         fontWeight: FontWeight.w500,
                                            //         fontSize: 18,
                                            //         height: 1.8),
                                            //   ),
                                            // ),
                                            // Container(
                                            //   color: Color(0xffF4F9F5),
                                            //   child: Text(
                                            //     'Other Loans',
                                            //     textAlign: TextAlign.left,
                                            //     style: TextStyle(
                                            //         // color: ColorsUtil.lighterGrey,
                                            //         fontFamily:
                                            //             CustomFonts.roboto,
                                            //         fontWeight: FontWeight.w500,
                                            //         fontSize: 18,
                                            //         height: 1.8),
                                            //   ),
                                            // ),
                                          ]),
                                          TableRow(children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30),
                                              child: Text(
                                                'No. of Loans',
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.creditCards?.numberLoan}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.personalLoan?.numberLoan}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.homeLoan?.numberLoan}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            // Text(
                                            //   '${loanDetails.activeLoans?.goldLoan?.numberLoan}',
                                            //   textAlign: TextAlign.left,
                                            //   style: TextStyle(
                                            //       color:
                                            //           ColorsUtil.dividerColor,
                                            //       fontFamily:
                                            //           CustomFonts.roboto,
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 18,
                                            //       height: 2.0),
                                            // ),
                                            // Text(
                                            //   '${loanDetails.activeLoans?.otherLoan?.numberLoan}',
                                            //   textAlign: TextAlign.left,
                                            //   style: TextStyle(
                                            //       color:
                                            //           ColorsUtil.dividerColor,
                                            //       fontFamily:
                                            //           CustomFonts.roboto,
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 18,
                                            //       height: 2.0),
                                            // ),
                                          ]),
                                          TableRow(children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30),
                                              child: Text(
                                                'POS',
                                                style: TextStyle(
                                                    color: ColorsUtil
                                                        .blueColorCart
                                                        .withAlpha(100),
                                                    fontFamily:
                                                        CustomFonts.nunito,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18,
                                                    height: 1.8),
                                              ),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.creditCards?.pos}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.personalLoan?.pos}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            Text(
                                              '${loanDetails.activeLoans?.homeLoan?.pos}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color:
                                                      ColorsUtil.blueColorCart,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  height: 2.0),
                                            ),
                                            // Text(
                                            //   '${loanDetails.activeLoans?.goldLoan?.pos}',
                                            //   textAlign: TextAlign.left,
                                            //   style: TextStyle(
                                            //       color:
                                            //           ColorsUtil.dividerColor,
                                            //       fontFamily:
                                            //           CustomFonts.roboto,
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 18,
                                            //       height: 2.0),
                                            // ),
                                            // Text(
                                            //   '${loanDetails.activeLoans?.otherLoan?.pos}',
                                            //   textAlign: TextAlign.left,
                                            //   style: TextStyle(
                                            //       color:
                                            //           ColorsUtil.dividerColor,
                                            //       fontFamily:
                                            //           CustomFonts.roboto,
                                            //       fontWeight: FontWeight.w500,
                                            //       fontSize: 18,
                                            //       height: 2.0),
                                            // ),
                                          ]),
                                        ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
              },
            ),
            actions: <Widget>[],
          );
        });
  }
}

const rowSpacer = TableRow(children: [
  SizedBox(
    height: 8,
  ),
  SizedBox(
    height: 8,
  )
]);

class HeadingValueContainer extends StatelessWidget {
  final String heading;
  final String value;

  const HeadingValueContainer(
      {required this.heading, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 16.0,
              color: ColorsUtil.blueColorCart.withAlpha(100),
              fontFamily: CustomFonts.nunito,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              color: ColorsUtil.blueColorCart,
              fontFamily: CustomFonts.nunito,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: ColorsUtil.marketCardContainer1),
          color: ColorsUtil.marketCardContainer),
    );
  }
}
