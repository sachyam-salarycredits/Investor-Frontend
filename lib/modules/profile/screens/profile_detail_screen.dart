import 'package:peerbridge/modules/profile/widgets/bankDetailCard.dart';
import 'package:peerbridge/modules/profile/widgets/logoWidget.dart';
import 'package:peerbridge/modules/profile/widgets/mipCard.dart';
import 'package:peerbridge/modules/profile/widgets/nomineeDetailCard.dart';
import 'package:peerbridge/modules/profile/widgets/officeAddressCard.dart';
import 'package:peerbridge/modules/profile/widgets/profileDetailCard.dart';
import 'package:peerbridge/modules/profile/widgets/residenceAddressCard.dart';
import 'package:peerbridge/providers/app_state_provider.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/header.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';
import 'package:provider/provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  List<String> detailList = [
    'Profile Details',
    'Residence Address',
    'Office Address',
    'Bank Account Details',
    // 'MIP Details',
    'Nominee Details'
  ];
  late TabController _tabController;
  List _selectedIndexs = [];

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: detailList.length,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {});
    });

    //getting user fund transfer details
    context.read<AppStateProvider>().getUserFundDetails();

    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var _crossAxisSpacing = 0;
    var screenSize = MediaQuery.of(context).size;
    var _screenWidth = MediaQuery.of(context).size.width;
    var _crossAxisCount = 1;
    var _width = (_screenWidth - ((_crossAxisCount - 1) * _crossAxisSpacing)) /
        _crossAxisCount;
    var cellHeight = 280;
    var _aspectRatio = _width / cellHeight;

    var provider = Provider.of<AppStateProvider>(context);
    var userData = provider.userDetails!;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Header(
                backOnPressed: () {
                  Navigator.pop(context);
                },
              ),
              ResponsiveWidget.isSmallScreen(context)
                  ? Expanded(
                      child: Container(
                        child: CustomScrollView(
                          slivers: [
                            SliverAppBar(
                              title: Container(
                                margin: EdgeInsets.only(top: 50),
                                child: Column(
                                  children: [
                                    LogoWidget(
                                      url: userData.profileDetails!.profileUrl,
                                      size: 100,
                                    ),
                                    // CircleAvatar(
                                    //   radius: 50.5,
                                    //   backgroundImage:
                                    //       AssetImage(LocalImages.ramanathan),
                                    // ),
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            userData.profileDetails!.fullName,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: ColorsUtil.black,
                                              fontSize: 22.0,
                                              fontFamily: CustomFonts.nunito,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Profile ${provider.getProfilePercentage()}% complete',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontFamily:
                                                      CustomFonts.nunito,
                                                  fontWeight: FontWeight.w400,
                                                  color: ColorsUtil.greenText,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Icon(
                                                Icons.keyboard_arrow_right,
                                                color: ColorsUtil.greenText,
                                                size: 23,
                                              )
                                            ],
                                          ),
                                        ]),
                                  ],
                                ),
                              ),
                              automaticallyImplyLeading: false,
                              toolbarHeight: 250,
                              backgroundColor: ColorsUtil.white,
                              centerTitle: true,
                              pinned: true,
                              floating: true,
                              bottom: TabBar(
                                  isScrollable: true,
                                  indicatorColor: ColorsUtil.black,
                                  labelColor: ColorsUtil.black,
                                  unselectedLabelColor: ColorsUtil.lighterGrey,
                                  controller: _tabController,
                                  tabs: List.generate(
                                      detailList.length,
                                      (index) => Tab(
                                            text: detailList[index],
                                          ))),
                            ),

                            // SliverToBoxAdapter(
                            //   child:  Divider(
                            //     thickness: 1,
                            //     height: 1,
                            //   ),
                            // ),

                            SliverToBoxAdapter(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                color: Colors.white,
                                child: [
                                  ProfileDetailCard(
                                    detailHeading: detailList[0],
                                  ),
                                  // SizedBox(
                                  //   height: 16,
                                  // ),
                                  ResidenceAddressWidget(
                                    detailHeading1: detailList[1],
                                  ),
                                  // SizedBox(
                                  //   height: 16,
                                  // ),
                                  OfficeAddressCard(
                                    detailHeading2: detailList[2],
                                  ),
                                  // SizedBox(
                                  //   height: 16,
                                  // ),
                                  BankAccountDetailsCard(
                                    detailHeading3: detailList[3],
                                  ),
                                  // SizedBox(
                                  //   height: 16,
                                  // ),
                                  // MIPDetailsCard(
                                  //   detailHeading4: detailList[4],
                                  // ),
                                  // SizedBox(
                                  //   height: 16,
                                  // ),
                                  NomineeDetailsCard(
                                    detailHeading5: detailList[4],
                                  )
                                ][_tabController.index],
                              ),
                            ),

                            /// OLD Horizonatal Fromat
                            // SliverList(delegate: SliverChildListDelegate.fixed([
                            //   ProfileDetailCard(
                            //     detailHeading: detailList[0],
                            //   ),
                            //   SizedBox(
                            //     height: 16,
                            //   ),
                            //   ResidenceAddress(
                            //     detailHeading1: detailList[1],
                            //   ),
                            //   SizedBox(
                            //     height: 16,
                            //   ),
                            //   OfficeAddressCard(
                            //     detailHeading2: detailList[2],
                            //   ),
                            //   SizedBox(
                            //     height: 16,
                            //   ),
                            //   BankAccountDetailsCard(
                            //     detailHeading3: detailList[3],
                            //   ),
                            //   SizedBox(
                            //     height: 16,
                            //   ),
                            //   MIPDetailsCard(
                            //     detailHeading4: detailList[4],
                            //   ),
                            //   SizedBox(
                            //     height: 16,
                            //   ),
                            //   NomineeDetailsCard(
                            //     detailHeading5: detailList[5],
                            //   )
                            // ])),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              // color: ColorsUtil.redColor,
                              width: screenSize.width * .3,
                              height: screenSize.height * .9,
                              child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LogoWidget(
                                        url:
                                            userData.profileDetails!.profileUrl,
                                        size: 200,
                                      ),
                                      SizedBox(
                                        height: 22,
                                      ),
                                      Text(
                                        '${userData.profileDetails!.fullName}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontFamily: CustomFonts.nunito,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Profile ${provider.getProfilePercentage()}% complete',
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: CustomFonts.nunito,
                                              fontWeight: FontWeight.w400,
                                              color: ColorsUtil.greenText,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: ColorsUtil.greenText,
                                            size: 23,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: screenSize.width / 15),
                                        height: 200, // screenSize.height * .3,
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            // scrollDirection: Axis.horizontal,
                                            itemCount: detailList.length,
                                            itemBuilder: (context, index) {
                                              final _isSelected =
                                                  _selectedIndexs
                                                      .contains(index);
                                              return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (_isSelected) {
                                                        _selectedIndexs
                                                            .remove(index);
                                                      } else {
                                                        _selectedIndexs.clear();
                                                        _selectedIndexs
                                                            .add(index);
                                                      }
                                                    });
                                                    final contentSize =
                                                        scrollController
                                                                .position
                                                                .viewportDimension +
                                                            scrollController
                                                                .position
                                                                .maxScrollExtent;
// Index to scroll to.
// Estimate the target scroll position.
                                                    final target = contentSize *
                                                        index /
                                                        detailList.length;
// Scroll to that position.
                                                    scrollController.position
                                                        .animateTo(
                                                      target,
                                                      duration: const Duration(
                                                          seconds: 1),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      // height: 70,
                                                      // decoration: BoxDecoration(
                                                      //     border: Border(
                                                      //         bottom: BorderSide(
                                                      //   width: 1,
                                                      //   color: _isSelected
                                                      //       ? ColorsUtil.black
                                                      //       : ColorsUtil
                                                      //           .white, // Underline thickness
                                                      // ))),
                                                      child: Text(
                                                        detailList[index],
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                CustomFonts
                                                                    .nunito,
                                                            fontSize: 16,
                                                            color: _isSelected
                                                                ? ColorsUtil
                                                                    .black
                                                                : ColorsUtil
                                                                    .lighterGrey,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            decoration: _isSelected
                                                                ? TextDecoration
                                                                    .underline
                                                                : TextDecoration
                                                                    .none),
                                                      )));
                                            }),
                                      ),
                                      // InkWell(
                                      //   onTap: () {
                                      //     FlyyFlutterPlugin
                                      //         .openFlyyReferralsPage();
                                      //   },
                                      //   child: Container(
                                      //     // margin: EdgeInsets.symmetric(
                                      //     //     horizontal: 16.0,
                                      //     //     vertical: 8.0),
                                      //     width: screenSize.width / 10,
                                      //     constraints:
                                      //         BoxConstraints(minWidth: 200),
                                      //     height: 50,
                                      //     decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.all(
                                      //           Radius.circular(
                                      //               5.0) //                 <--- border radius here
                                      //           ),
                                      //       gradient: new LinearGradient(
                                      //           colors: [
                                      //             Colors.green[300]!,
                                      //             Colors.green[600]!,
                                      //             ColorsUtil.blueColor
                                      //           ],
                                      //           begin: Alignment.centerLeft,
                                      //           end: Alignment.centerRight,
                                      //           stops: [0.2, 0.6, 1]),
                                      //     ),
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.symmetric(
                                      //           horizontal: 10),
                                      //       child: Row(
                                      //         mainAxisAlignment:
                                      //             MainAxisAlignment.center,
                                      //         children: [
                                      //           Image.asset(
                                      //               LocalImages.refer_earn),
                                      //           SizedBox(
                                      //             width: 10.0,
                                      //           ),
                                      //           Text(
                                      //             'Refer & Earn',
                                      //             textAlign: TextAlign.center,
                                      //             style: TextStyle(
                                      //                 fontFamily:
                                      //                     CustomFonts.nunito,
                                      //                 fontSize: 16.0,
                                      //                 fontWeight:
                                      //                     FontWeight.w600,
                                      //                 color: ColorsUtil.white),
                                      //           )
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
                                    ]),
                              ),
                            ),
                            Container(
                              width: screenSize.width * .65,
                              margin: EdgeInsets.symmetric(vertical: 18.5),
                              child: ListView(
                                controller: scrollController,
                                shrinkWrap: true,
                                // physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                children: [
                                  ProfileDetailCard(
                                    detailHeading: detailList[0],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  ResidenceAddressWidget(
                                    detailHeading1: detailList[1],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  OfficeAddressCard(
                                    detailHeading2: detailList[2],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  BankAccountDetailsCard(
                                    detailHeading3: detailList[3],
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  // MIPDetailsCard(
                                  //   detailHeading4: detailList[4],
                                  // ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  NomineeDetailsCard(
                                    detailHeading5: detailList[4],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
              // Row(
              //         children: [
              //           Container(
              //             // color: ColorsUtil.redColor,
              //             width: screenSize.width * .3,
              //             height: screenSize.height * .85,
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 CircleAvatar(
              //                   radius: 50.5,
              //                   backgroundImage:
              //                       AssetImage(LocalImages.ramanathan),
              //                 ),
              //                 Column(
              //                     crossAxisAlignment: CrossAxisAlignment.center,
              //                     children: [
              //                       SizedBox(
              //                         height: 22,
              //                       ),
              //                       Text(
              //                         'Tushar Palei',
              //                         textAlign: TextAlign.left,
              //                         style: TextStyle(
              //                           fontSize: 22.0,
              //                           fontFamily: CustomFonts.roboto,
              //                           fontWeight: FontWeight.w700,
              //                         ),
              //                       ),
              //                       SizedBox(
              //                         height: 10,
              //                       ),
              //                       Row(
              //                         mainAxisAlignment: MainAxisAlignment.center,
              //                         children: [
              //                           Text(
              //                             'Profile 35% complete',
              //                             maxLines: 1,
              //                             style: TextStyle(
              //                               fontSize: 18.0,
              //                               fontFamily: CustomFonts.roboto,
              //                               fontWeight: FontWeight.w400,
              //                               color: ColorsUtil.greenText,
              //                             ),
              //                           ),
              //                           SizedBox(
              //                             width: 2,
              //                           ),
              //                           Icon(
              //                             Icons.keyboard_arrow_right,
              //                             color: ColorsUtil.greenText,
              //                             size: 23,
              //                           )
              //                         ],
              //                       ),
              //                       SizedBox(
              //                         height: 30,
              //                       ),
              //                       Container(
              //                         margin: EdgeInsets.only(left: 40),
              //                         height: screenSize.height * .4,
              //                         child: ListView.builder(
              //                             // scrollDirection: Axis.horizontal,
              //                             itemCount: detailList.length,
              //                             itemBuilder: (context, index) {
              //                               final _isSelected =
              //                                   _selectedIndexs.contains(index);
              //                               return InkWell(
              //                                   onTap: () {
              //                                     setState(() {
              //                                       if (_isSelected) {
              //                                         _selectedIndexs
              //                                             .remove(index);
              //                                       } else {
              //                                         _selectedIndexs.clear();
              //                                         _selectedIndexs.add(index);
              //                                       }
              //                                     });
              //                                   },
              //                                   child: Container(
              //                                       padding: EdgeInsets.symmetric(
              //                                           horizontal: 10,
              //                                           vertical: 5),
              //                                       // height: 70,
              //                                       // decoration: BoxDecoration(
              //                                       //     border: Border(
              //                                       //         bottom: BorderSide(
              //                                       //   width: 1,
              //                                       //   color: _isSelected
              //                                       //       ? ColorsUtil.black
              //                                       //       : ColorsUtil
              //                                       //           .white, // Underline thickness
              //                                       // ))),
              //                                       child: Text(
              //                                         detailList[index],
              //                                         textAlign: TextAlign.left,
              //                                         style: TextStyle(
              //                                             fontFamily:
              //                                                 CustomFonts.roboto,
              //                                             fontSize: 16,
              //                                             color: _isSelected
              //                                                 ? ColorsUtil.black
              //                                                 : ColorsUtil
              //                                                     .lighterGrey,
              //                                             fontWeight:
              //                                                 FontWeight.w500,
              //                                             decoration: _isSelected
              //                                                 ? TextDecoration
              //                                                     .underline
              //                                                 : TextDecoration
              //                                                     .none),
              //                                       )));
              //                             }),
              //                       ),
              //                     ]),
              //               ],
              //             ),
              //           ),
              //           Container(
              //             width: screenSize.width * .6,
              //             color: ColorsUtil.greenColor,
              //           )
              //           SingleChildScrollView(
              //             child: Container(
              //               width: screenSize.width * .6,
              //               margin: EdgeInsets.symmetric(
              //                   horizontal: 16, vertical: 18.5),
              //               child: Column(
              //                 // physics: NeverScrollableScrollPhysics(),
              //                 // shrinkWrap: true,
              //                 // scrollDirection: Axis.vertical,
              //                 children: [
              //                   ProfileDetailCard(
              //                     detailHeading: detailList[0],
              //                   ),
              //                   SizedBox(
              //                     height: 16,
              //                   ),
              //                   ResidenceAddress(
              //                     detailHeading1: detailList[1],
              //                   ),
              //                   SizedBox(
              //                     height: 16,
              //                   ),
              //                   OfficeAddressCard(
              //                     detailHeading2: detailList[2],
              //                   ),
              //                   SizedBox(
              //                     height: 16,
              //                   ),
              //                   BankAccountDetailsCard(
              //                     detailHeading3: detailList[3],
              //                   ),
              //                   SizedBox(
              //                     height: 16,
              //                   ),
              //                   MIPDetailsCard(
              //                     detailHeading4: detailList[4],
              //                   ),
              //                   SizedBox(
              //                     height: 16,
              //                   ),
              //                   NomineeDetailsCard(
              //                     detailHeading5: detailList[5],
              //                   )
              //                 ],
              //               ),
              //             ),
              //           )
              //         ],
              //       )
            ],
          ),
        ),
      ),
    );
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
