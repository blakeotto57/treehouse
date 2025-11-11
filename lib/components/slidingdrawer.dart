import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treehouse/theme/drawer_width_provider.dart';
import 'package:treehouse/theme/theme.dart';

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
    
    // Get drawer width from provider
    final widthProvider = Provider.of<DrawerWidthProvider>(context);
    final drawerWidth = widthProvider.drawerWidth;

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
          // Resize handle - only visible when drawer is open
          if (_opened)
            _DrawerResizeHandle(
              top: headerTotalHeight,
              height: contentHeight,
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

// Resizable handle widget for the drawer
class _DrawerResizeHandle extends StatefulWidget {
  final double top;
  final double height;

  const _DrawerResizeHandle({
    required this.top,
    required this.height,
  });

  @override
  State<_DrawerResizeHandle> createState() => _DrawerResizeHandleState();
}

class _DrawerResizeHandleState extends State<_DrawerResizeHandle> {
  bool _isHovering = false;
  bool _isDragging = false;
  double _dragStartX = 0;
  double _dragStartWidth = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final widthProvider = Provider.of<DrawerWidthProvider>(context);

    return Positioned(
      left: widthProvider.drawerWidth - 3,
      top: widget.top,
      height: widget.height,
      width: 6, // Wider hit area for easier interaction
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
            _dragStartX = details.globalPosition.dx;
            _dragStartWidth = widthProvider.drawerWidth;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            final deltaX = details.globalPosition.dx - _dragStartX;
            final newWidth = (_dragStartWidth + deltaX).clamp(
              widthProvider.minWidth,
              widthProvider.maxWidth,
            );
            widthProvider.setDrawerWidth(newWidth);
          }
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            _isHovering = false;
          });
        },
        onPanCancel: () {
          setState(() {
            _isDragging = false;
            _isHovering = false;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          onEnter: (_) {
            setState(() {
              _isHovering = true;
            });
          },
          onExit: (_) {
            if (!_isDragging) {
              setState(() {
                _isHovering = false;
              });
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: _isHovering || _isDragging ? 3 : 2,
                height: double.infinity,
                margin: EdgeInsets.symmetric(vertical: _isHovering || _isDragging ? 4 : 8),
                decoration: BoxDecoration(
                  color: _isHovering || _isDragging
                      ? (isDark 
                          ? AppColors.primaryGreenLight.withOpacity(0.9)
                          : AppColors.primaryGreen.withOpacity(0.9))
                      : (isDark 
                          ? AppColors.borderDark.withOpacity(0.4)
                          : AppColors.borderLight.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(1.5),
                  boxShadow: _isHovering || _isDragging
                      ? [
                          BoxShadow(
                            color: (isDark 
                                ? AppColors.primaryGreenLight 
                                : AppColors.primaryGreen).withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
