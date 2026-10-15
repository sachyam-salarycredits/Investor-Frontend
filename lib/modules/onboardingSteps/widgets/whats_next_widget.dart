import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:flutter/material.dart';

class WhatsNextWidget extends StatelessWidget {
  final String headingText;
  final String? status;
  final String iconText;
  final Color iconColor;
  final IconData rightIcon;
  final double horizontalMargin;
  final double verticalMargin;
  final VoidCallback onPress;

  WhatsNextWidget({
    this.headingText = "",
    this.status,
    this.rightIcon = Icons.launch,
    this.iconText = "",
    this.iconColor = ColorsUtil.blueColor,
    this.horizontalMargin = 20,
    this.verticalMargin = 5,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          margin: ResponsiveWidget.isSmallScreen(context)
              ? EdgeInsets.symmetric(
                  vertical: verticalMargin, horizontal: horizontalMargin)
              : EdgeInsets.symmetric(vertical: verticalMargin),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(7),
            ),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headingText,
                    maxLines: 2,
                    // softWrap: true,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: CustomFonts.nunito,
                        color: ColorsUtil.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 7.0,
                  ),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        maxLines: 1,
                        softWrap: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: CustomFonts.nunito,
                            color: ColorsUtil.lightGrey,
                            fontSize: 14),
                      ),
                      Text(
                        status.getStatusStr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: CustomFonts.nunito,
                          color: status.getStatusColor(),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Icon(
                rightIcon,
                size: 22.0,
                color: iconColor,
              ),
            ],
          )),
    );
  }
}
