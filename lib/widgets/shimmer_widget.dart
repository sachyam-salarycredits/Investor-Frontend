import 'package:peerbridge/utils/colours_util.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double? height ;
  final  double? width;
  const ShimmerWidget({this.height=double.maxFinite,this.width=double.maxFinite,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8)
      ),
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: ColorsUtil.lighterGreen,
        child: Container(

          decoration: BoxDecoration(
              color: ColorsUtil.quizContainer,
              borderRadius: BorderRadius.circular(8)

          ),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final double aspectRatio;
  final int crossAxisCount;
  final double itemSpacing;
  final int  itemCount;

  const ShimmerList({required this.aspectRatio, this.itemCount=12,this.itemSpacing =8,this.crossAxisCount =1, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(crossAxisCount: crossAxisCount,
    childAspectRatio: aspectRatio,
    crossAxisSpacing: itemSpacing,mainAxisSpacing: itemSpacing,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    children: List.generate(itemCount, (index) => ShimmerWidget()),
    );
  }
}

