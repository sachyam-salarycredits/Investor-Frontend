import 'package:Monexo/providers/app_state_provider.dart';
import 'package:Monexo/routes_management/routes_list.dart';
import 'package:Monexo/widgets/custom_button.dart';
import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/fonts.dart';
import 'package:Monexo/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/src/provider.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  late PageController _controller;
  // late AnimationController _animationController;
  // late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);

    context.read<AppStateProvider>().setOnBoardStatus(true);
    // _animationController =
    //     AnimationController(vsync: this, duration: Duration(seconds: 3));
    // _animation =
    //     CurvedAnimation(parent: _animationController, curve: Curves.ease);
    // _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    // _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          backgroundColor: ColorsUtil.blueColor,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Image.asset(content[currentIndex].netGradientImage,
                            width: 250,),
                        ),
                      ),
                      /// Calling method to get a View Page Widget
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              child: getViewPager(_controller, (int i) {
                                setState(() {
                                  currentIndex = i;
                                });
                              }),
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Container(
                            padding: EdgeInsets.only(left: 18.0),
                            /// Make Page View with Page Indicator here
                            height: 20.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                for(int i = 0; i<content.length; i++)
                                  if( i == currentIndex )
                                    SlideDots(true)
                                  else
                                    SlideDots(false)
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: clipPath(),
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Align(
                          alignment: Alignment.topCenter,
                          child: Image.asset(content[currentIndex].illustrationImage2, height: 320, width: 320,)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 0,
                  child:Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(child: Container(
                          child: Visibility(
                            visible: content[currentIndex].showBackBtn,
                            child: TextButton(onPressed: () {
                              /// Back Button Action Handler
                              if (currentIndex > 0) {
                                --currentIndex;
                                setState(() {
                                  _controller.animateToPage(
                                    currentIndex,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                });
                              }
                            },
                              child: Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(Icons.arrow_back_rounded, color: Colors.grey,),
                                ),
                              ),
                            ),
                          ),
                        )),
                        Spacer(),
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0, right: 20.0),
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          child: TextButton(onPressed: () {
                            /// Next Button Action Handler
                            if (currentIndex < (content.length - 1)) {
                              ++currentIndex;
                              setState(() {
                                _controller.animateToPage(
                                  currentIndex,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              });
                            } else {
                              context.goNamed(RoutesName.LandingScreen);
                            }
                          },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    content[currentIndex].rightBtnTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward, color: ColorsUtil.arrowColor,)
                                ],
                              )
                          ),
                          decoration: BoxDecoration(
                              color: ColorsUtil.blueColor,
                              borderRadius: BorderRadius.circular(6.0)
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}

/// Class of Custom Clipper to clip the Container with the defined path
class clipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // path.moveTo(0, 120);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 3.5, 0, 100);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

/// Method to get PageView
Widget getViewPager(PageController _controller, Function onPageChanged) {
  return Column(
    children: [
      Expanded(
        child: PageView.builder(
          controller: _controller,
          itemCount: content.length,
          onPageChanged: (int index) {
            onPageChanged(index);
          },
          itemBuilder: (_, i) {
            return Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image(
                    image: AssetImage(content[i].titleImage),
                    width: 250,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

/// Page Indicator Widget
class SlideDots extends StatelessWidget {
  bool isActive;
  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 26 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}

/// Onboarding Screens Content Data Model Class
class OnboardingContent {
  String titleImage;
  String illustrationImage2;
  String netGradientImage;
  String rightBtnTitle = 'Next';
  bool showBackBtn = false;

  OnboardingContent(
      {required this.titleImage,
        required this.illustrationImage2,
        required this.netGradientImage,
        required this.rightBtnTitle,
        required this.showBackBtn});
}

/// Onboarding Screens Content Data List
List<OnboardingContent> content = [
  OnboardingContent(
    titleImage: 'images/Frame2608157.png',
    illustrationImage2: 'images/Group2357.png',
    netGradientImage: 'images/Group2353.png',
    showBackBtn: false,
    rightBtnTitle: 'Next ',
  ),
  OnboardingContent(
      titleImage: 'images/Frame2608158.png',
      illustrationImage2: 'images/Artboard1.png',
      netGradientImage: 'images/Group2354.png',
      showBackBtn: true,
      rightBtnTitle: 'Next '
  ),
  OnboardingContent(
      titleImage: 'images/Frame2608159.png',
      illustrationImage2: 'images/Group2352.png',
      netGradientImage: 'images/Frame2608160.png',
      rightBtnTitle: 'Lets Begin',
      showBackBtn: true
  ),
];