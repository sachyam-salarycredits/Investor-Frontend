import 'package:peerbridge/modules/marketplace/models/popup_data.dart';
import 'package:peerbridge/modules/marketplace/widgets/view_detail.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';

import 'custom_tooltip.dart';

class CustomTooltipForDetail extends StatefulWidget {
  final List<PopupData> popupData;
  final String message;
  final Widget child;

  const CustomTooltipForDetail(
      {required Key key,
      required this.child,
      required this.popupData,
      required this.message})
      : super(key: key);

  @override
  _CustomTooltipForDetailState createState() => _CustomTooltipForDetailState();
}

class _CustomTooltipForDetailState extends State<CustomTooltipForDetail>
    with TickerProviderStateMixin {
  final color = Colors.white;
  late GlobalKey key;
  late Offset _offset;
  late Size _size;
  late OverlayEntry overlayEntry;

  late AnimationController _controller;

  @override
  void initState() {
    key = LabeledGlobalKey(widget.message);
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  void getWidgetDetails() {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    _size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _offset = offset;
    print(_offset.dx);
  }

  OverlayEntry _makeOverlay() {
    List<PopupData> popupData = List.empty();

    final isViewMore = widget.popupData.length > 3;

    if (isViewMore) {
      popupData = widget.popupData.sublist(0, 3);
    } else {
      popupData = widget.popupData;

    }


    return OverlayEntry(
      builder: (context) => Positioned(
        top: _offset.dy + 20,
        left: _offset.dx - 110,
        width: _size.width + 300,
        child: popupData.isEmpty?SizedBox():ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 0.9).animate(
              CurvedAnimation(parent: _controller, curve: Curves.bounceOut)),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipPath(
                  clipper: ArrowClip(),
                  child: Container(
                    height: 10,
                    width: 15,
                    decoration: BoxDecoration(
                      color: color,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DataTable(
                        headingTextStyle: TextStyle(color: ColorsUtil.lightGrey),
                        dataTextStyle: TextStyle(color: ColorsUtil.black),
                        columns: [
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Amount")),
                        ],
                        rows: popupData
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.date)),
                                  DataCell(Text(
                                      "₹ ${e.amount}")),
                                ]))
                            .toList(),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      child: widget.child,
      onTap: () {
        if (widget.popupData.length > 0) {
          showDialog(
            context: context,
            builder: (context) => Container(
              width: MediaQuery.of(context).size.shortestSide / 3,
              child: Dialog(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 50,
                      dataRowHeight: 35,
                      dividerThickness: 1,
                      headingTextStyle: TextStyle(
                          color: ColorsUtil.lightGrey, fontSize: 18),
                      dataTextStyle: TextStyle(color: ColorsUtil.black),
                      columns: [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Amount")),
                      ],
                      rows: widget.popupData
                          .map((e) => DataRow(cells: [
                        DataCell(Text(e.date)),
                        DataCell(Text(e.amount.commaAddedValue())),
                      ]))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

      },
      onHover: (v) {
        if (v) {
          getWidgetDetails();

          overlayEntry =_makeOverlay() ;
          Overlay.of(context)!.insert(overlayEntry);
          _controller.forward();
        } else {
          _controller.reverse();
          overlayEntry.remove();
        }
      },
    );
  }
}
