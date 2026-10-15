import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/material.dart';

class DotedLine extends StatelessWidget {
  final double height;
  final Color color;
  final bool isDashLine;

  const DotedLine({
    this.height = 1,
    this.color = ColorsUtil.blueColor,
    this.isDashLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 3.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return isDashLine
            ? Flex(
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: dashHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
                  );
                }),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
              )
            : Container(
                width: boxWidth,
                height: height,
                color: color,
              );
      },
    );
  }
}
