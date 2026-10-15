import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:peerbridge/widgets/doted_line.dart';
import 'package:flutter/material.dart';

class StepsWidget extends StatelessWidget {
  int totalSteps;
  int currentStep;

  StepsWidget({
    Key? key,
    this.totalSteps = 4,
    this.currentStep = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ResponsiveWidget.isSmallScreen(context)
          ? ColorsUtil.lighterGreen
          : ColorsUtil.white,
      height: 46,
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: getRandomWidgetArray(context),
      ),
    );
  }

  List<Widget> getRandomWidgetArray(BuildContext context) {
    var gameCells = <Widget>[];
    var circleSize = 20.0;
    var screenWidth = ResponsiveWidget.isSmallScreen(context)
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.width * .34;
    var lineSize =
        (screenWidth - 30 - (totalSteps * circleSize)) / (totalSteps - 1);
    for (int i = 1; i <= totalSteps; i++) {
      var a = Container(
        child: Row(
          children: [
            Image(
              width: circleSize,
              height: circleSize,
              image: AssetImage(i <= currentStep
                  ? LocalImages.green_tick
                  : LocalImages.green_circle),
              color: ColorsUtil.blueColor,
            ),
            Visibility(
                visible: i != totalSteps,
                child: Container(
                  width: lineSize,
                  child: DotedLine(
                    isDashLine: i >= currentStep,
                  ),
                ))
          ],
        ),
      );
      gameCells.add(a);
    }
    return gameCells;
  }
}
