import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/utils/api_constant.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/constants.dart';
import 'package:Monexo/utils/extensions.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/responsive.dart';
import 'package:Monexo/utils/utils.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/widgets/header.dart';
import 'package:Monexo/widgets/input_widget.dart';
import 'package:Monexo/widgets/loader.dart';
import 'package:Monexo/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UPIScreenFirst extends StatefulWidget {
  const UPIScreenFirst({Key? key}) : super(key: key);

  @override
  _UPIScreenFirstState createState() => _UPIScreenFirstState();
}

class _UPIScreenFirstState extends State<UPIScreenFirst> {
  bool _isLoading = false;

  FocusNode _focus = FocusNode();
  bool isFocused = false;
  bool isUpiValid = false;
  bool isUpiError = false;

  var upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profileUpi = Constants.sipUpiId?.toString() ?? '';
    if (profileUpi.isNotEmpty) {
      upiController.text = profileUpi;
      isUpiValid = profileUpi.isUpiIdValid;
    }
  }

  @override
  void dispose() {
    upiController.dispose();
    super.dispose();
  }

  Future<void> _validateAndProceed() async {
    if (!isUpiValid) {
      return;
    }
    setState(() => _isLoading = true);
    final provider = context.read<AppStateProvider>();
    final param = <String, dynamic>{
      ApiParams.customerId: provider.customerId,
      ApiParams.custVirAdd: upiController.text.trim(),
    };
    final ok = await provider.validateSipUpiMandate(param);
    setState(() => _isLoading = false);
    if (!ok) {
      Utils.showAlert(context: context, msg: 'Please enter valid UPI ID');
      return;
    }
    Constants.sipUpiId = upiController.text.trim();
    context.pushNamed(RoutesName.UPIScreen2);
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
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: InputWidget(
                focusNode: _focus,
                isFocused: isFocused,
                controller: upiController,
                keyboardType: TextInputType.emailAddress,
                isValid: isUpiValid,
                isError: isUpiError,
                alertStr: isUpiError ? 'Please enter valid UPI ID' : '',
                hintStr: 'Enter your UPI ID',
                heading: 'Enter your UPI ID',
                horizontalMargin: 0,
                onChange: (String input) {
                  setState(() {
                    isUpiValid = input.isUpiIdValid;
                    isUpiError = !isUpiValid;
                  });
                },
              ),
            )),
          ),
          Column(
            children: [
              CustomButton(
                isDisable: !isUpiValid,
                titleStr: 'Next',
                onPress: _validateAndProceed,
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
