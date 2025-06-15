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
  }) : super(key: key);

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> {
  bool _opened = false;

  void open() {
    setState(() {
      _opened = true;
    });
  }

  void close() {
    setState(() {
      _opened = false;
    });
  }

  void toggle() {
    setState(() {
      _opened = !_opened;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    // Calculate drawer width with constraints
    final calculatedRatioWidth = width * widget.drawerRatio;
    final drawerWidth = calculatedRatioWidth.clamp(
      widget.minDrawerWidth,
      widget.maxDrawerWidth,
    );

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > widget.swipeSensitivity) {
          open();
        } else if (details.delta.dx < -widget.swipeSensitivity) {
          close();
        }
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Drawer
            AnimatedPositioned(
              width: drawerWidth,
              height: height,
              left: _opened ? 0 : -drawerWidth,
              duration: Duration(milliseconds: widget.animationDuration),
              curve: widget.animationCurve,
              child: Container(
                color: Colors.transparent, // Make background transparent
                child: widget.drawer,
              ),
            ),
            // Main content
            AnimatedPositioned(
              height: height,
              width: width,
              left: _opened ? drawerWidth : 0,
              duration: Duration(milliseconds: widget.animationDuration),
              curve: widget.animationCurve,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.child,
                  // Overlay when drawer is open
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: widget.animationDuration),
                    switchInCurve: widget.animationCurve,
                    switchOutCurve: widget.animationCurve,
                    child: _opened
                        ? GestureDetector(
                            onTap: close,
                            child: Container(
                              color: widget.overlayColor.withOpacity(
                                widget.overlayOpacity,
                              ),
                            ),
                          )
                        : null,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
