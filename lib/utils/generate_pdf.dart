import 'dart:typed_data';

// import 'package:makepdfs/models/invoice.dart';
import 'package:peerbridge/modules/home/models/ViewRiskDataModel.dart';
import 'package:peerbridge/supporting_file/dummy_js.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import '../modules/home/models/ViewDataModel.dart';
// import 'dart:html' as html;

Future<void> makePdf(
    List orderList, String cid, String name, String pdfType) async {
  final pdf = Document();
  final imageLogo = MemoryImage(
      (await rootBundle.load('images/peerbridge_logo.png'))
          .buffer
          .asUint8List());
  pdf.addPage(Page(
    build: (context) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              // Image Logo PeerBridge
              child: Image(imageLogo, width: 350, height: 57),
            ),
          ),
          SizedBox(height: 100),
          Column(
            children: [
              // Name
              Text("Name:- ${name}",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 20.0),
              // CID
              Text("Customer ID:- ${cid}",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  )),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
      ));
    },
  ));
  switch (pdfType) {
    case 'Risk':
      pdf.addPage(
        MultiPage(
          build: (Context context) => <Widget>[
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                // Table Header
                TableRow(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Month/Year",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your Investment",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your XIRR",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Loan Status",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                ]),
                ...orderList.map(
                  (e) => TableRow(
                    children: [
                      Expanded(
                        child: PaddedText(DateFormat('MMM yyyy').format(
                          DateTime.parse(e.loanInvestorStartDateC ?? ''),
                        )),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.loanInvestmentAmountC}"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.loanCertificateRateC}%"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText(
                            "${e.loanStatusC == 'Inactive' ? 'Closed' : 'Live'} "),
                        flex: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      break;
    case 'Interest Ratio':
      pdf.addPage(
        MultiPage(
          build: (Context context) => <Widget>[
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                // Table Header
                TableRow(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Month/Year",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your Investment",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your XIRR",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Loan Status",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                ]),
                ...orderList.map(
                  (e) => TableRow(
                    children: [
                      Expanded(
                        child: PaddedText(DateFormat('MMM yyyy').format(
                          DateTime.parse(e.startDate ?? ''),
                        )),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.investmentAmount}"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${(e.xirr).toStringAsFixed(2)}%"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText(
                            "${e.status == 'Active - Good Standing' ? 'Live' : 'Closed'} "),
                        flex: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      break;
    case 'Delinquency':
      pdf.addPage(
        MultiPage(
          build: (Context context) => <Widget>[
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                // Table Header
                TableRow(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Month/Year",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your Investment",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your XIRR",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Loan Status",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                ]),
                ...orderList.map(
                  (e) => TableRow(
                    children: [
                      Expanded(
                        child: PaddedText(DateFormat('MMM yyyy').format(
                          DateTime.parse(e.startDate ?? ''),
                        )),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.investmentAmount}"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.xirr?.toStringAsFixed(2)}%"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText(
                            "${e.status == 'Active - Good Standing' ? 'Live' : 'Closed'} "),
                        flex: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      break;
    case 'Loan Tenure':
      pdf.addPage(
        MultiPage(
          build: (Context context) => <Widget>[
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                // Table Header
                TableRow(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Month/Year",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your Investment",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your XIRR",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Loan Status",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                ]),
                ...orderList.map(
                  (e) => TableRow(
                    children: [
                      Expanded(
                        child: PaddedText(DateFormat('MMM yyyy').format(
                          DateTime.parse(e.startDate ?? ''),
                        )),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.amount}"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.xirr?.toStringAsFixed(2)}%"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText(
                            "${e.status == 'Active - Good Standing' ? 'Live' : 'Closed'} "),
                        flex: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      break;
    case 'Remaining Tenure':
      pdf.addPage(
        MultiPage(
          build: (Context context) => <Widget>[
            Table(
              border: TableBorder.all(color: PdfColors.black),
              children: [
                // Table Header
                TableRow(children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Month/Year",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your Investment",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Your XIRR",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text("Loan Status",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold)),
                    ),
                    flex: 1,
                  ),
                ]),
                ...orderList.map(
                  (e) => TableRow(
                    children: [
                      Expanded(
                        child: PaddedText(DateFormat('MMM yyyy').format(
                          DateTime.parse(e.startDate ?? ''),
                        )),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.amount}"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText("${e.xirr?.toStringAsFixed(2)}%"),
                        flex: 1,
                      ),
                      Expanded(
                        child: PaddedText(
                            "${e.status == 'Active - Good Standing' ? 'Live' : 'Closed'} "),
                        flex: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      break;
  }

  // return pdf.save();
  // final pdfInByte = await pdf.save();
  if (Utils.isWeb) {
    // print('Download web');
    // Uint8List pdfInBytes = await pdf.save();
    // //Create blob and link from
    // final blob = html.Blob([pdfInBytes], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.document.createElement('a') as html.AnchorElement
    //   ..href = url
    //   ..style.display = 'none'
    //   ..download = 'pdf.pdf';
    // html.document.body?.children.add(anchor);
    // anchor.click();
  } else {
    final pdfInByte = await pdf.save();
    final output = await getApplicationDocumentsDirectory();
    final path = '${output.path}/test.pdf';
    final file = File(path);
    print('PDF Path: $file');
    await file.writeAsBytes(pdfInByte);

    await OpenFile.open(file.path);
  }
}

Widget PaddedText(
  final String text, {
  final TextAlign align = TextAlign.left,
}) =>
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Text(
        text,
        textAlign: align,
      ),
    );
