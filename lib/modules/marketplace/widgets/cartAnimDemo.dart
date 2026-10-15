import 'package:peerbridge/modules/marketplace/widgets/market_place_grid_cards.dart';
import 'package:peerbridge/utils/colours_util.dart';
import 'package:peerbridge/utils/fonts.dart';
import 'package:peerbridge/utils/images.dart';
import 'package:peerbridge/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CartAnimDemo extends StatelessWidget {
  const CartAnimDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
          itemExtent: 200,
          itemCount: 10,
          itemBuilder: (context, index) => MarketPlaceCard(index: index)),
    );
  }
}

class AddToCardAnimPage extends StatefulWidget {
  final int index;
 final Widget child;
  const AddToCardAnimPage({
    required this.index,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _AddToCardAnimPageState createState() => _AddToCardAnimPageState();
}

class _AddToCardAnimPageState extends State<AddToCardAnimPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));

    animationController.addListener(() {
      setState(() {});
    });

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      //  animationController.reset();
        Navigator.pop(context,true);
      }
    });
    super.initState();

    Future.delayed(Duration(milliseconds: 800))
        .then((value) => animationController.forward());
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    final bgColor = ColorTween(begin: Colors.white, end: ColorsUtil.green)
        .animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 0.7, curve: Curves.decelerate)));


    final positionedTween =
        Tween(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(0, 0.5, curve: Curves.decelerate)));


    final shapeTween =
    Tween(begin: BorderRadius.circular(0), end: BorderRadius.circular(80))
        .animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0.6, 1, curve: Curves.easeIn)));

    final sizeTween = Tween(begin: 1.0, end: 0.1).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0, 0.7, curve: Curves.decelerate)));


    final translateTween = Tween(
            begin: Offset.zero,
            end: Offset(size.width / 2.2, size.height / 2.2))
        .animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(0.6, 1, curve: Curves.decelerate)));
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Hero(
          tag: "${widget.index}",
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(translateTween.value.dx, translateTween.value.dy)
              ..scale(sizeTween.value, sizeTween.value),
            // offset: translateTween.value,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: bgColor.value, borderRadius: shapeTween.value
                  // shape: shapeTween.value,
                  ),
              width: size.width>400?400:size.width,
              height: size.width>400?400:size.width,

              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
