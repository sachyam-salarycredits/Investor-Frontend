import 'package:Monexo/utils/colours_util.dart';
import 'package:Monexo/utils/images.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String url;

  final double size;

  const LogoWidget({Key? key, this.url = "", this.size = 70}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasNetworkPhoto =
        url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
    if (!hasNetworkPhoto)
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(LocalImages.profileImage),
          ),
        ),
      );
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorsUtil.white,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(url),
          ),
        ));
  }
}
