import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/extensions.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:flutter/material.dart';

class NavBarBoxWidget extends StatelessWidget {
  final String headingText;
  final String? status;
  final String iconText;
  final String subText;
  final bool isDisabled;
  final bool swithValue;
  final IconData? whatsNextIcon;
  void Function()? onPress;
  NavBarBoxWidget({
    this.headingText = "",
    this.status = '0',
    this.subText = '',
    this.whatsNextIcon,
    this.iconText = "",
    this.isDisabled = false,
    this.swithValue = false,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    var isFundTransfer = headingText == 'Fund Transfer';
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        color: ColorsUtil.white,
        margin: EdgeInsets.only(
          bottom: 10.0,
        ),
        child: InkWell(
          onTap: isDisabled ? null : onPress,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headingText,
                    maxLines: 1,
                    softWrap: true,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.medium(13.5,
                        color: swithValue
                            ? ColorsUtil.greyDisable
                            : AppColors.ink),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      children: [
                        if (!isFundTransfer)
                          Container(
                            width: 85,
                            height: 20,
                            decoration: BoxDecoration(
                                color: swithValue
                                    ? status.getStatusColor().withAlpha(20)
                                    : status.getStatusColor().withAlpha(51),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  status.getStatusStr(),
                                  style: AppTextStyles.medium(10.5,
                                    color: status
                                        .getStatusColor()
                                        .withAlpha(swithValue ? 50 : 255)),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          whatsNextIcon,
                          size: 18.0,
                          color:
                              // isFundTransfer
                              //     ? ColorsUtil.blueColor
                              //     :
                              ColorsUtil.arrowColor.withAlpha(swithValue
                                  ? 50
                                  : isDisabled
                                      ? 50
                                      : 255),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   height: 7,
              // ),
              // if (!isFundTransfer)
              //   Container(
              //     width: MediaQuery.of(context).size.width,
              //     child: Text(
              //       subText,
              //       maxLines: 2,
              //       softWrap: true,
              //       textAlign: TextAlign.left,
              //
              //       style: TextStyle(
              //           fontFamily: CustomFonts.nunito,
              //           color: ColorsUtil.lightGrey,
              //           fontSize: 10),
              //     ),
              //   ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1.0,
                height: 2.0,
                color: ColorsUtil.circleGrey,
              )
            ],
          ),
        ));
  }
}
