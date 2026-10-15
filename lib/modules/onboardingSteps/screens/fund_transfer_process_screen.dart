import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:peerbridge/widgets/pdf_view.dart';
import 'package:peerbridge/widgets/title_header.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

import '../../../utils/responsive.dart';

class FundTransferProcessScreen extends StatefulWidget {
  const FundTransferProcessScreen({Key? key}) : super(key: key);

  @override
  _FundTransferProcessScreenState createState() =>
      _FundTransferProcessScreenState();
}

class _FundTransferProcessScreenState extends State<FundTransferProcessScreen> {
  String? fileName;
  PlatformFile? selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    getInstructionForm();
    super.initState();
  }

  /// Get Fund Transfer Instruction form
  Future<void> getInstructionForm() async {
    setLoading(true);
    final formUrl =
        await context.read<AppStateProvider>().getFundInstructionForm();
    setLoading(false);
  }

  /// Get Fund Transfer Instruction form
  Future<void> submitForm() async {
    if (selectedFile == null) {
      Utils.showToast(msg: LanguageHelper.textSelectFile);
      return;
    }
    setLoading(true);
    final status = await context
        .read<AppStateProvider>()
        .saveFundInstructionForm(selectedFile);
    setLoading(false);
    if (status) {
      Utils.showToast(msg: LanguageHelper.textSubmitForm);
    }
  }

  downloadPdf() async {
    final demoLink =
        "https://monexo-s3-bucket.s3.ap-south-1.amazonaws.com/testingPdf/TestPDFfile.pdf";

    try {
      setLoading(true);
      final response = await http.get(Uri.parse(demoLink));

      if (Utils.isWeb) {
        Printing.sharePdf(
            bytes: response.bodyBytes, filename: "application-form.pdf");
      } else {
        Utils.saveAndOpenFile(response.bodyBytes);
      }

      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
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
        body: PeerBridgeLoader(
          isLoading: _isLoading,
          child: SafeArea(
              child: ResponsiveWidget.isSmallScreen(context)
                  ? Column(
                      children: [
                        Header(
                          backOnPressed: () {
                            context.pop();
                          },
                        ),
                        TitleHeader(
                          titleStr: 'Follow the instructions',
                          desStr: 'Please fill out the document and upload it',
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: mainWidgets(context),
                            ),
                          ),
                        ),
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
                                              titleStr:
                                                  'Follow the instructions',
                                              desStr:
                                                  'Please fill out the document and upload it',
                                            ),
                                            SizedBox(height: 30),
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
                        Container(
                          width: screenSize.width * .44,
                          color: ColorsUtil.blueColor,
                        )
                      ],
                    )),
        ),
      ),
    );
  }

  Widget mainWidgets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1 - Download the form',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        InkWell(
          onTap: () {
            downloadPdf();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorsUtil.greenText,
              ),
            ),
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  LocalImages.download,
                  color: ColorsUtil.greenText,
                  width: 16,
                  height: 16,
                ),
                SizedBox(
                  width: 9,
                ),
                Text(
                  'Download Form 112C-78C',
                  style: TextStyle(
                    color: ColorsUtil.greenText,
                    fontFamily: CustomFonts.nunito,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
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
          'Step 2 - Fill the form offline',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
          'Step 3 - Scan and upload the form',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: CustomFonts.nunito,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        InkWell(
          onTap: () async {
            final filePicked = await Utils.pickFile();
            if (filePicked == null) return;
            print('name$filePicked');
            setState(() {
              fileName = filePicked.name;
              selectedFile = filePicked;
            });
          },
          child: Container(
            child: DottedBorder(
              color: ColorsUtil.blueColorText,
              borderType: BorderType.RRect,
              radius: Radius.circular(5),
              strokeWidth: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  color: ColorsUtil.white,
                ),
                height: 50,
                width: double.infinity,
                child: fileName != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                  fontFamily: CustomFonts.nunito,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16.0,
                                  color: ColorsUtil.black),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Image.asset(
                            LocalImages.upload,
                            width: 16,
                            height: 16,
                            color: ColorsUtil.blueColorText,
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
                              color: ColorsUtil.blueColorText,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        CustomButton(
          horizontalMargin: 0,
          onPress: submitForm,
          titleStr: 'Continue',
        )
      ],
    );
  }
}
