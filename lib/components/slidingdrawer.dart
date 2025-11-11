import 'package:flutter/material.dart';

// Global state to track if drawer should be open
class DrawerState {
  static bool _shouldBeOpen = false;
  
  static bool get shouldBeOpen => _shouldBeOpen;
  
  static void setOpen(bool open) {
    _shouldBeOpen = open;
  }
}

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
  final bool? initialOpen; // Optional override for initial state

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
    this.initialOpen,
  }) : super(key: key);

  @override
  SlidingDrawerState createState() => SlidingDrawerState();
}

class SlidingDrawerState extends State<SlidingDrawer> {
  late bool _opened; // Will be initialized based on global state or initialOpen
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier<bool>(false);
  bool _isInitialBuild = true; // Track if this is the first build

  bool get isOpen => _opened;

  ValueNotifier<bool> get isOpenNotifier => _isOpenNotifier;

  @override
  void initState() {
    super.initState();
    // Use initialOpen if provided, otherwise use global state
    _opened = widget.initialOpen ?? DrawerState.shouldBeOpen;
    _isOpenNotifier.value = _opened;
  }

  void open() {
    setState(() {
      _opened = true;
      _isOpenNotifier.value = true;
    });
    DrawerState.setOpen(true);
  }

  void close() {
    setState(() {
      _opened = false;
      _isOpenNotifier.value = false;
    });
    DrawerState.setOpen(false);
  }

  void toggle() {
    setState(() {
      _opened = !_opened;
      _isOpenNotifier.value = _opened;
    });
    DrawerState.setOpen(_opened);
  }

  @override
  void dispose() {
    _isOpenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mark that initial build is complete after first build
    if (_isInitialBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialBuild = false;
          });
        }
      });
    }
    
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
            duration: _isInitialBuild && _opened 
                ? Duration.zero 
                : Duration(milliseconds: widget.animationDuration),
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
            duration: _isInitialBuild && _opened 
                ? Duration.zero 
                : Duration(milliseconds: widget.animationDuration),
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
