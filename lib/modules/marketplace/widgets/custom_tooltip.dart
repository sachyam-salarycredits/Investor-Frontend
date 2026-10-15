import 'package:flutter/material.dart';
import 'package:peerbridge/theme/app_colors.dart';
import 'package:peerbridge/theme/app_text_styles.dart';

class CustomTooltip extends StatefulWidget {
  final String message;
  final Widget child;

  const CustomTooltip(
      {required Key key, required this.child, required this.message})
      : super(key: key);

  @override
  CustomTooltipState createState() => CustomTooltipState();
}

class CustomTooltipState extends State<CustomTooltip>
    with TickerProviderStateMixin {
  final color = AppColors.ink;
  late GlobalKey key;
  late Offset _offset;
  late Size _size;
  late OverlayEntry overlayEntry;
  String message = "";

  late AnimationController _controller;

  @override
  void initState() {
    key = LabeledGlobalKey(widget.message);
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {

        Future.delayed(Duration(seconds: 2)).then((value){
          overlayEntry.remove();
          _controller.reverse();
        });
      }
    });
    super.initState();
  }

  void getWidgetDetails() {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    _size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _offset = offset;
    print(_offset.dx);
  }

  OverlayEntry makeOverlay() {
    final screen = MediaQuery.of(context).size;
    const bubbleWidth = 260.0;
    final anchorRight = _offset.dx + _size.width;
    final left = (anchorRight - bubbleWidth)
        .clamp(12.0, screen.width - bubbleWidth - 12.0)
        .toDouble();
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: screen.height - _offset.dy + 4,
        left: left,
        width: bubbleWidth,
        child: ScaleTransition(
          alignment: Alignment.bottomRight,
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: _controller,
              curve: Interval(0, 0.4, curve: Curves.decelerate))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message,
                    style: AppTextStyles.medium(12.5, color: Colors.white),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: (anchorRight - left - bubbleWidth).abs() < 1
                        ? _size.width / 2 - 7
                        : 18),
                child: RotatedBox(
                  quarterTurns: 2,
                  child: ClipPath(
                    clipper: ArrowClip(),
                    child: Container(
                      height: 10,
                      width: 15,
                      decoration: BoxDecoration(
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  showMessage(String m) {
    if (_controller.isAnimating || _controller.value > 0) return;
    message = m;
    getWidgetDetails();
    overlayEntry = makeOverlay();
    Overlay.of(context)!.insert(overlayEntry);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: key, child: widget.child);
    // return InkWell(
    //   key: key,
    //   child:
    //  // onTap: () {},
    //   // onHover: (v) {
    //   //   if (v) {
    //   //     getWidgetDetails();
    //   //     overlayEntry = makeOverlay();
    //   //     Overlay.of(context)!.insert(overlayEntry);
    //   //     _controller.forward();
    //   //   } else {
    //   //     _controller.reverse();
    //   //     overlayEntry.remove();
    //   //   }
    //   // },
    // );
  }
}

class ArrowClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
