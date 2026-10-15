import 'package:peerbridge/modules/marketplace/models/filter_data.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketPlaceFilter extends StatefulWidget {
  final dynamic onClose;

  const MarketPlaceFilter({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  _MarketPlaceFilterState createState() => _MarketPlaceFilterState();
}

class _MarketPlaceFilterState extends State<MarketPlaceFilter> {
  FilterDetails filterData = FilterDetails();
  final double minTenure = 1;
  final double maxTenure = 36;

  final RangeValues maxAmountRange = RangeValues(1000, 1000000);
  RangeValues amountRange = RangeValues(1000, 1000000);

  //in K

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var provider = Provider.of<AppStateProvider>(context);
    //  final filterData = provider.filterData;

    final tenure = filterData.tenure == 0.0 ? 1.0 : filterData.tenure;

    return Container(
      margin: EdgeInsets.only(top: 10),
      // height: MediaQuery.of(context).size.height * .7,
      child: SingleChildScrollView(
        child: Column(
          // shrinkWrap: true,
          // scrollDirection: Axis.vertical,
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                width: ResponsiveWidget.isSmallScreen(context)
                    ? MediaQuery.of(context).size.width
                    : 900,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                // height: MediaQuery.of(context).size.height * .5,
                decoration: BoxDecoration(
                  color: ColorsUtil.white,
                  borderRadius: BorderRadius.all(Radius.circular(
                          5.0) //                 <--- border radius here
                      ),
                ),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan Amount',
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          inactiveTrackColor: ColorsUtil.lightGreen,
                          activeTrackColor: ColorsUtil.blueColor,
                          overlayColor: Colors.transparent,
                          thumbColor: ColorsUtil.blueColor,
                          activeTickMarkColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                          valueIndicatorColor: ColorsUtil.circleGrey,
                          valueIndicatorTextStyle: TextStyle(
                            color: ColorsUtil.greenText,
                            fontFamily: CustomFonts.nunito,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          showValueIndicator:
                              ShowValueIndicator.onlyForContinuous,
                          thumbShape: const _ThumbShape(),
                        ),
                        child: RangeSlider(
                            values: amountRange,
                            min: maxAmountRange.start,
                            max: maxAmountRange.end,
                            labels: RangeLabels('${amountRange.start ~/ 1000}k',
                                '${amountRange.end ~/ 1000}k'),
                            onChanged: (RangeValues newRange) {
                              amountRange = newRange;
                              filterData.minAmount = amountRange.start;
                              filterData.maxAmount = amountRange.end;
                              setState(() {});
                            }),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Divider(
                        thickness: 1,
                        height: 1,
                        color: ColorsUtil.lighterGrey,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Tenure of Loan',
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          inactiveTrackColor: ColorsUtil.lightGreen,
                          activeTrackColor: ColorsUtil.blueColor,
                          overlayColor: Colors.transparent,
                          thumbColor: ColorsUtil.blueColor,
                          activeTickMarkColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                          valueIndicatorColor: ColorsUtil.circleGrey,
                          valueIndicatorTextStyle: TextStyle(
                            color: ColorsUtil.greenText,
                            fontFamily: CustomFonts.nunito,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          showValueIndicator: ShowValueIndicator.always,
                          thumbShape: const _ThumbShape(),
                        ),
                        // SliderThemeData(
                        //     inactiveTrackColor: Colors.green.shade100,
                        //     activeTrackColor: ColorsUtil.greenColor,
                        //     overlayColor: Colors.transparent,
                        //     thumbColor: ColorsUtil.greenColor,
                        //     activeTickMarkColor: Colors.transparent,
                        //     inactiveTickMarkColor: Colors.transparent,
                        //     valueIndicatorColor: ColorsUtil.greenColor,
                        //     showValueIndicator: ShowValueIndicator.always),
                        child: Slider(
                            value: tenure,
                            min: minTenure,
                            max: maxTenure,
                            divisions: maxTenure.toInt(),
                            label: tenure.round().toString(),
                            onChanged: (value) {
                              setState(() => filterData.tenure = value);
                            }),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Divider(
                        thickness: 1,
                        height: 1,
                        color: ColorsUtil.lighterGrey,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Grade of Loan',
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          riskWidget(context, 'Conservative'),
                          riskWidget(context, 'Moderate'),
                          riskWidget(context, 'High Risk'),
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
                      Text(
                        'Select Products',
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorsUtil.lightestGrey),
                          color: ColorsUtil.lightestGrey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        //constraints: BoxConstraints(minWidth: 350),
                        width: double.infinity,
                        height: 58,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: MultiSelectionPopUp(
                            title: 'Select Products',
                            allValues: provider.filterProducts,
                            screenSize: screenSize,
                            isEnabled: true,
                            onSelectionValues: (selectedTypes) {
                              filterData.products = selectedTypes;
                              setState(() {});
                            },
                            selectedValue: filterData.products,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              provider.filterData = FilterDetails();
                              widget.onClose();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorsUtil.circleGrey,
                                borderRadius: BorderRadius.circular(5),
                                // border: Border.all(
                                //     color: ColorsUtil.greenText),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              height: 56,
                              child: Center(
                                child: Text(
                                  'Clear Filters',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 18,
                                      color: ColorsUtil.greenText),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              provider.filterData = filterData;
                              widget.onClose();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: ColorsUtil.greenText,
                                borderRadius: BorderRadius.circular(5),
                                // border: Border.all(
                                //     color: ColorsUtil.greenText),
                              ),
                              // width: MediaQuery.of(context).size.width / 2.5,
                              height: 57,
                              child: Center(
                                child: Text(
                                  'Apply Filter',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: CustomFonts.nunito,
                                      fontSize: 18,
                                      color: ColorsUtil.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget riskWidget(context, name) {
    return InkWell(
      onTap: () {
        if (filterData.grade.isEmpty) {
          filterData.grade = List.empty(growable: true);
        }

        if (filterData.grade.contains(name)) {
          filterData.grade.remove(name);
        } else {
          filterData.grade.add(name);
        }

        setState(() {});
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ColorsUtil.circleGrey,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              width: filterData.grade.contains(name) ? 3 : 0,
              color: filterData.grade.contains(name)
                  ? ColorsUtil.blueColorText
                  : ColorsUtil.circleGrey),
        ),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: CustomFonts.nunito,
                fontSize: 14,
                color: ColorsUtil.greenText),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    filterData = FilterDetails(
      grade: context.read<AppStateProvider>().filterData.grade,
      maxAmount: context.read<AppStateProvider>().filterData.maxAmount,
      minAmount: context.read<AppStateProvider>().filterData.minAmount,
      pageNo: context.read<AppStateProvider>().filterData.pageNo,
      products: context.read<AppStateProvider>().filterData.products,
      tenure: context.read<AppStateProvider>().filterData.tenure,
    );

    amountRange = RangeValues(
        filterData.minAmount == 0 ? 1000 : filterData.minAmount,
        filterData.maxAmount == 0 ? 1000000 : filterData.maxAmount);

    super.initState();
  }
}

class _ThumbShape extends RoundSliderThumbShape {
  final _indicatorShape = const RectangularSliderValueIndicatorShape();

  const _ThumbShape();

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      textDirection: textDirection,
    );
    _indicatorShape.paint(
      context,
      center,
      activationAnimation: const AlwaysStoppedAnimation(1),
      enableAnimation: enableAnimation,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      value: value,
      textScaleFactor: 3,
      sizeWithOverflow: sizeWithOverflow,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );
  }
}

class MultiSelectionPopUp extends StatefulWidget {
  MultiSelectionPopUp(
      {required this.screenSize,
      required this.title,
      required this.isEnabled,
      required this.allValues,
      required this.selectedValue,
      required this.onSelectionValues});

  final List<String>? allValues;
  final String? title;
  final Size screenSize;
  final bool isEnabled;
  final List<String> selectedValue;
  final Function onSelectionValues;
  final List<String> selectedValueTemp = [];

  @override
  _MultiSelectionPopUpState createState() => _MultiSelectionPopUpState();
}

class _MultiSelectionPopUpState extends State<MultiSelectionPopUp> {
  @override
  void initState() {
    super.initState();
    widget.selectedValueTemp.clear();
    widget.selectedValueTemp.addAll(widget.selectedValue);
  }

  List<Widget> showSelectedItems() {
    List<Widget> allWidgets = [];
    for (int i = 0; i < widget.selectedValue.length; i++) {
      allWidgets.add(ShowTextWidget(
        text: widget.selectedValue[i],
        itemNumber: i,
      ));

      if (i == 1) {
        break;
      }
    }
    if (widget.selectedValue.length > 2) {
      allWidgets.add(Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          '...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
      ));
    }
    // if (widget.selectedValue.length > 0) {
    //   allWidgets.add(Container(
    //     padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
    //     child: Text(
    //       '+${widget.selectedValue.length - 1}',
    //       textAlign: TextAlign.center,
    //       style: store.currentTheme.textTheme.headline5?.copyWith(fontSize: 15),
    //       overflow: TextOverflow.ellipsis,
    //     ),
    //   ));
    // }
    return allWidgets;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedValue.isNotEmpty && widget.selectedValueTemp.isEmpty) {
      widget.selectedValueTemp.addAll(widget.selectedValue);
      setState(() {});
    }
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setState) {
                return Dialog(
                  insetPadding: EdgeInsets.all(15),
                  child: Container(
                    child: Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      //constraints: BoxConstraints(maxWidth: 450),
                      height: 430,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.selectedValueTemp.clear();
                                      widget.selectedValueTemp
                                          .addAll(widget.allValues ?? []);
                                      // selectAllMarket(allSelected: true);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ColorsUtil.circleGrey,
                                        borderRadius: BorderRadius.circular(5),
                                        // border: Border.all(
                                        //     color: ColorsUtil.greenText),
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                          4.6,
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          'Select all',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: CustomFonts.nunito,
                                              fontSize: 16,
                                              color: ColorsUtil.greenText),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      widget.selectedValueTemp.clear();
                                      // selectAllMarket(allSelected: false);
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ColorsUtil.circleGrey,
                                        borderRadius: BorderRadius.circular(5),
                                        // border: Border.all(
                                        //     color: ColorsUtil.greenText),
                                      ),
                                      width: MediaQuery.of(context).size.width /
                                          5.8,
                                      height: 40,
                                      child: Center(
                                        child: Text(
                                          'Clear',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontFamily: CustomFonts.nunito,
                                              fontSize: 16,
                                              color: ColorsUtil.greenText),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: ListView.builder(
                                    itemCount: widget.allValues?.length,
                                    itemBuilder: (context, i) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (widget.selectedValueTemp
                                                    .contains(
                                                        widget.allValues?[i] ??
                                                            '')) {
                                                  widget.selectedValueTemp
                                                      .remove(widget
                                                              .allValues?[i] ??
                                                          '');
                                                } else {
                                                  widget.selectedValueTemp.add(
                                                      widget.allValues?[i] ??
                                                          '');
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  widget.selectedValueTemp
                                                          .contains(
                                                              widget.allValues?[
                                                                      i] ??
                                                                  '')
                                                      ? Icons.check_sharp
                                                      : null,
                                                  color: ColorsUtil.greenText,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 10),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Container(
                                                    width: 200,
                                                    child: Text(
                                                      widget.allValues?[i] ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 4,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            CustomFonts.nunito,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                            Divider(
                              color: ColorsUtil.lighterGrey,
                              thickness: 1,
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 5, bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 40,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: ColorsUtil.greenText,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            widget.selectedValue.clear();
                                            widget.selectedValue.addAll(
                                                widget.selectedValueTemp);
                                            widget.onSelectionValues(
                                                widget.selectedValue);
                                          });
                                          Navigator.pop(
                                              context, widget.selectedValue);
                                        },
                                        child: Center(
                                          child: Text(
                                            'Done',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontFamily: CustomFonts.nunito,
                                                fontSize: 16,
                                                color: ColorsUtil.white),
                                          ),
                                        )),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            });
      },
      child: Container(
        width: widget.screenSize.width,
        constraints: BoxConstraints(minHeight: 44),
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: widget.selectedValue.length <= 0
            ? Container(
                child: Row(
                  children: [
                    Expanded(
                        child: Text(widget.title ?? '',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: CustomFonts.nunito,
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.lighterGrey))),
                    Icon(Icons.arrow_drop_down, color: ColorsUtil.blackish)
                  ],
                ),
              )
            : ListView(
                scrollDirection: Axis.horizontal,
                children: showSelectedItems(),
              ),
      ),
    );
  }
}

class ShowTextWidget extends StatefulWidget {
  ShowTextWidget({required this.text, required this.itemNumber});

  final String text;
  final int itemNumber;

  @override
  State<ShowTextWidget> createState() => _ShowTextWidgetState();
}

class _ShowTextWidgetState extends State<ShowTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.itemNumber > 0 ? '${widget.text},' : '${widget.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontFamily: CustomFonts.nunito,
                fontWeight: FontWeight.w600,
                color: ColorsUtil.lightGrey),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
