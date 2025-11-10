import 'package:flutter/material.dart';

class SlidingDrawer extends StatefulWidget {
  final Widget drawer;
  final Widget child;
  final int swipeSensitivity;
  final double drawerRatio;
  final double minDrawerWidth;
  final double maxDrawerWidth;
  final Color overlayColor;
  final double overlayOpacity;
  final int animationDuration;
  final Curve animationCurve;
  final double? appBarHeight; // Height of the app bar to position drawer below it

  const SlidingDrawer({
    Key? key,
    required this.drawer,
    required this.child,
    this.swipeSensitivity = 25,
    this.drawerRatio = 0.15,
    this.minDrawerWidth = 225, // Minimum drawer width in pixels
    this.maxDrawerWidth = 350, // Maximum drawer width in pixels
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.5,
    this.animationDuration = 250,
    this.animationCurve = Curves.ease,
    this.appBarHeight,
  }) : super(key: key);

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> {
  bool _opened = false; // Start with drawer closed by default
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier<bool>(false);

  bool get isOpen => _opened;

  ValueNotifier<bool> get isOpenNotifier => _isOpenNotifier;

  void open() {
    setState(() {
      _opened = true;
      _isOpenNotifier.value = true;
    });
  }

  void close() {
    setState(() {
      _opened = false;
      _isOpenNotifier.value = false;
    });
  }

  void toggle() {
    setState(() {
      _opened = !_opened;
      _isOpenNotifier.value = _opened;
    });
  }

  @override
  void dispose() {
    _isOpenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = widget.appBarHeight ?? 0.0;
    final headerTotalHeight = topPadding + appBarHeight;
    final contentHeight = height - headerTotalHeight;
    
    // Calculate drawer width with constraints
    final calculatedRatioWidth = width * widget.drawerRatio;
    final drawerWidth = calculatedRatioWidth.clamp(
      widget.minDrawerWidth,
      widget.maxDrawerWidth,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Drawer - positioned below header area (accounting for SafeArea)
          AnimatedPositioned(
            width: drawerWidth,
            height: contentHeight,
            top: headerTotalHeight,
            left: _opened ? 0 : -drawerWidth,
            duration: Duration(milliseconds: widget.animationDuration),
            curve: widget.animationCurve,
            child: Container(
              color: Colors.transparent,
              child: widget.drawer,
            ),
          ),
          // Main content - constrained to fit between drawer and right edge
          AnimatedPositioned(
            height: height,
            top: 0,
            left: _opened ? drawerWidth : 0,
            right: 0, // Fixed to right edge of screen - content will be squished when drawer is open
            duration: Duration(milliseconds: widget.animationDuration),
            curve: widget.animationCurve,
            child: ClipRect(
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
