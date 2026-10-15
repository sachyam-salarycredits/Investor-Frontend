import 'dart:async';

import 'package:peerbridge/language/language_en.dart';
import 'package:peerbridge/modules/authentication/models/customerId_list.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/routes_management/app_router.dart';
import 'package:peerbridge/routes_management/routes_list.dart';
import 'package:peerbridge/modules/marketplace/screens/market_place_screen.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/utils/utils.dart';
import 'package:peerbridge/widgets/checkbox_widget.dart';
import 'package:peerbridge/widgets/custom_button.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../supporting_file/appsFlyerSdk.dart';
import '../../../utils/api_constant.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({Key? key}) : super(key: key);

  @override
  _WelcomeBackScreenState createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  CustomerIdDetail? selectedUser;
  late List<CustomerIdDetail>? customerIdList;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      customerIdList = await context.read<AppStateProvider>().customerIdList;
      setUser();
    });
  }

  setUser() async {
    selectedUser = customerIdList?.first;
    setState(() {});
  }

  /// Get Customer Details
  Future<void> getCustomerDetails() async {
    if (selectedUser == null) {
      Utils.showAlert(context: context, msg: LanguageHelper.textSelectAccount);
      return;
    }
    setLoading(true);
    context.read<AppStateProvider>().customerId =
        selectedUser?.customerId ?? '';
    context.read<AppStateProvider>().isLoggedIn = true;
    await context.read<AppStateProvider>().saveUserState();
    await context.read<AppStateProvider>().getStepsStatus();

    setLoading(false);

    //Mark: ApssFlyer login event trigger
    AFSdk.logEvent(AFSdk.af_login, null);
    AFSdk.setUser(selectedUser?.customerId ?? "");
    //
    context.moveInitialPage();
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
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              SizedBox(height: 30),
                              mainWidgets(context, screenSize),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: Row(
                      children: [
                        Container(
                          width: screenSize.width * .56,
                          color: ColorsUtil.white,
                          child: Column(
                            children: [
                              Header(),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Container(
                                    width: screenSize.width * .4,
                                    constraints: BoxConstraints(maxWidth: 500),
                                    child: mainWidgets(context, screenSize),
                                  ),
                                ),
                              )
                            ],
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
      ),
    );
  }

  Widget mainWidgets(BuildContext context, screenSize) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 60, 15, 20),
      child: Column(
        children: [
          Image(
            width: 98,
            height: 98,
            image: AssetImage(
              LocalImages.profileImage,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Welcome back, ${selectedUser == null ? "" : selectedUser?.fullName ?? ''}!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Please choose your profile to continue \n to the marketplace',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CustomFonts.nunito,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 30),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: customerIdList?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              return CheckBoxWidget(
                titleStr:
                    '${customerIdList?[index].customerId} - ${customerIdList?[index].fullName}',
                isSelected: selectedUser != null
                    ? (customerIdList?.indexOf(selectedUser!) == index)
                    : false,
                onPress: () {
                  setState(() {
                    selectedUser = customerIdList?[index];
                  });
                },
              );
            },
          ),
          CustomButton(
            titleStr: 'Login',
            horizontalMargin: 0,
            onPress: getCustomerDetails,
          )
        ],
      ),
    );
  }
}
