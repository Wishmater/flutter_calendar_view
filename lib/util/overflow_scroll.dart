import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OverflowScroll extends StatefulWidget {

  final ScrollController? scrollController;
  /// Autoscroll speed in pixels per second if null, disable autoscroll
  final double? autoscrollSpeed;
  final double opacityGradientSize;
  final Duration autoscrollWaitTime;
  final Duration initialAutoscrollWaitTime;
  final Axis scrollDirection;
  final Widget child;
  final bool consumeScrollNotifications;

  const OverflowScroll({
    required this.child,
    this.scrollController,
    this.autoscrollSpeed = 64,
    this.opacityGradientSize = 16,
    this.autoscrollWaitTime = const Duration(seconds: 5),
    this.initialAutoscrollWaitTime = const Duration(seconds: 3),
    this.scrollDirection = Axis.horizontal,
    this.consumeScrollNotifications = true,
    Key? key,
  }): super(key: key);

  @override
  _OverflowScrollState createState() => _OverflowScrollState();

}
class _OverflowScrollState extends State<OverflowScroll> {

  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = widget.scrollController ?? ScrollController();
    if (widget.autoscrollSpeed!=null && widget.autoscrollSpeed!>0){
      _scroll(true, widget.initialAutoscrollWaitTime);
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OverflowScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController!=null) {
      scrollController = widget.scrollController!;
    }
  }

  void _scroll([bool forward=true, Duration? waitDuration]) async{
    if (!mounted) return;
    await Future.delayed(waitDuration ?? widget.autoscrollWaitTime);
    if (!mounted) return;
    try {
      final duration = Duration(milliseconds: (1000*scrollController.position.maxScrollExtent/widget.autoscrollSpeed!).round());
      if (forward){
        await scrollController.animateTo(scrollController.position.maxScrollExtent, duration: duration, curve: Curves.linear);
      } else{
        await scrollController.animateTo(0, duration: duration, curve: Curves.linear);
      }
      _scroll(!forward);
    } catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    result = NotificationListener(
      onNotification: (notification) => widget.consumeScrollNotifications,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: widget.scrollDirection,
        child: widget.child,
      ),
    );
    if (widget.opacityGradientSize>0) {
      result = ScrollOpacityGradient(
        scrollController: scrollController,
        direction: widget.scrollDirection==Axis.horizontal ? OpacityGradient.horizontal : OpacityGradient.vertical,
        maxSize: widget.opacityGradientSize,
        child: result,
      );
    }
    return result;
  }

}


class OpacityGradient extends StatelessWidget {

  static const left = 0;
  static const right = 1;
  static const top = 2;
  static const bottom = 3;
  static const horizontal = 4;
  static const vertical = 5;

  final Widget child;
  final int direction;
  final double? size;
  final double? percentage;

  OpacityGradient({
    required this.child,
    this.direction = vertical,
    double? size,
    this.percentage,
  }) :
        assert(size==null || percentage==null, "Can't set both a hard size and a percentage."),
        size = size==null&&percentage==null ? 16 : size
  ;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: direction==top || direction==bottom || direction==vertical
            ? Alignment.topCenter : Alignment.centerLeft,
        end: direction==top || direction==bottom || direction==vertical
            ? Alignment.bottomCenter : Alignment.centerRight,
        stops: [
          0,
          direction==bottom || direction==right ? 0
              : size==null ? percentage!
              : size!/(direction==top || direction==bottom || direction==vertical ? bounds.height : bounds.width),
          direction==top || direction==left ? 1
              : size==null ? 1-percentage!
              : 1-size!/(direction==top || direction==bottom || direction==vertical ? bounds.height : bounds.width),
          1,
        ],
        colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
      ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}


class ScrollOpacityGradient extends StatefulWidget {

  final ScrollController scrollController;
  final Widget child;
  final double maxSize;
  final int direction;
  final bool applyAtStart;
  final bool applyAtEnd;

  ScrollOpacityGradient({
    required this.scrollController,
    required this.child,
    this.maxSize = 16,
    this.direction = OpacityGradient.vertical,
    this.applyAtEnd = true,
    this.applyAtStart = true,
  });

  @override
  _ScrollOpacityGradientState createState() => _ScrollOpacityGradientState();

}
class _ScrollOpacityGradientState extends State<ScrollOpacityGradient> {

  @override
  void initState() {
    super.initState();
    _addListener(widget.scrollController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScroll();
    });
  }

  @override
  void didUpdateWidget(ScrollOpacityGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    _removeListener(oldWidget.scrollController);
    _addListener(widget.scrollController);
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener(widget.scrollController);
  }

  void _addListener(ScrollController scrollController) {
    scrollController.addListener(_updateScroll);
  }

  void _removeListener(ScrollController scrollController) {
    scrollController.removeListener(_updateScroll);
  }

  void _updateScroll(){
    if (mounted){
      setState(() {});
    }
  }

  double size1 = 0;
  double size2 = 0;
  @override
  Widget build(BuildContext context) {
    try{
      size1 = widget.scrollController.position.pixels.clamp(0, widget.maxSize);
      size2 = (widget.scrollController.position.maxScrollExtent-widget.scrollController.position.pixels).clamp(0, widget.maxSize);
    } catch(e){ }
    if (widget.direction==OpacityGradient.horizontal || widget.direction==OpacityGradient.vertical) {
      return OpacityGradient(
        size: widget.applyAtStart ? size1 : 0,
        direction: widget.direction==OpacityGradient.horizontal ? OpacityGradient.left : OpacityGradient.top,
        child: OpacityGradient(
          size: widget.applyAtEnd ? size2 : 0,
          direction: widget.direction==OpacityGradient.horizontal ? OpacityGradient.right : OpacityGradient.bottom,
          child: widget.child,
        ),
      );
    } else {
      return OpacityGradient(
        size: widget.direction==OpacityGradient.left || widget.direction==OpacityGradient.top
            ? size1 : size2,
        direction: widget.direction,
        child: widget.child,
      );
    }
  }

}