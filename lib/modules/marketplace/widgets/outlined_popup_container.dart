import 'package:peerbridge/modules/marketplace/models/fundTransferDetails.dart';
import 'package:peerbridge/modules/marketplace/models/popup_data.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';

class OutlinePopupContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final List<FundsStatement> statement;
  Color tabColor;
  Color tabBorderColor;

  OutlinePopupContainer(
      {Key? key,
      required this.title,
      required this.subtitle,
      this.statement = const [],
      this.description = '',
      this.tabColor = ColorsUtil.lightGrey,
      this.tabBorderColor = ColorsUtil.lightGrey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15),
      child: InkWell(
        onTap: () {
          if (statement.length > 0) {
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
                        rows: statement
                            .map((e) => DataRow(cells: [
                                  DataCell(Text(e.tDate.getSimpleDateStr())),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: CustomFonts.nunito,
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.lightGrey),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.0,
                fontFamily: CustomFonts.nunito,
                fontWeight: FontWeight.w800,
              ),
            ),
            Visibility(
              visible: description != '',
              child: SizedBox(
                height: 4,
              ),
            ),
            Visibility(
              visible: description != '',
              child: Text(
                description,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10.0,
                    fontFamily: CustomFonts.nunito,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey),
              ),
            )
          ],
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: tabBorderColor),
          color: tabColor),
    );
  }
}
