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
  ValueNotifier<double>? _liveDrawerWidth; // Live width during dragging (null when not dragging)

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

  // Callback for resize handle to update live width during drag
  void _onResizeDragStart(double startWidth) {
    // Create the notifier and trigger rebuild synchronously
    _liveDrawerWidth = ValueNotifier<double>(startWidth);
    // Trigger rebuild immediately to set up ValueListenableBuilder
    setState(() {});
  }

  // Callback for resize handle to update live width during drag
  void _onResizeDragUpdate(double newWidth) {
    if (_liveDrawerWidth != null) {
      // Update the value - this will trigger ValueListenableBuilder to rebuild
      // Always update to ensure real-time responsiveness during drag
      _liveDrawerWidth!.value = newWidth;
    } else {
      // If notifier doesn't exist yet, create it (shouldn't happen, but safety check)
      _liveDrawerWidth = ValueNotifier<double>(newWidth);
      setState(() {});
    }
  }

  // Callback for resize handle when drag ends - commit to provider
  void _onResizeDragEnd(double finalWidth, DrawerWidthProvider provider) {
    if (_liveDrawerWidth != null) {
      _liveDrawerWidth!.dispose();
      _liveDrawerWidth = null;
      setState(() {}); // Trigger rebuild to switch back to provider-based layout
    }
    provider.setDrawerWidth(finalWidth);
  }

  // Callback for resize handle when drag is cancelled
  void _onResizeDragCancel() {
    if (_liveDrawerWidth != null) {
      _liveDrawerWidth!.dispose();
      _liveDrawerWidth = null;
      setState(() {}); // Trigger rebuild to switch back to provider-based layout
    }
  }

  @override
  void dispose() {
    _isOpenNotifier.dispose();
    _liveDrawerWidth?.dispose();
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
    final baseDrawerWidth = widthProvider.drawerWidth;

    // If dragging, use ValueListenableBuilder to listen to live width updates
    // Otherwise, build directly with provider width
    final liveWidthNotifier = _liveDrawerWidth;
    if (liveWidthNotifier != null) {
      // Use ValueListenableBuilder to listen to real-time updates
      return ValueListenableBuilder<double>(
        valueListenable: liveWidthNotifier,
        builder: (context, liveWidth, child) {
          // Rebuild the layout with the new live width
          return _buildDrawerLayout(
            context,
            width,
            height,
            headerTotalHeight,
            contentHeight,
            liveWidth,
            true, // isDragging
            false, // shouldAnimate
          );
        },
      );
    } else {
      return _buildDrawerLayout(
        context,
        width,
        height,
        headerTotalHeight,
        contentHeight,
        baseDrawerWidth,
        false, // isDragging
        !_isInitialBuild, // shouldAnimate
      );
    }
  }

  Widget _buildDrawerLayout(
    BuildContext context,
    double width,
    double height,
    double headerTotalHeight,
    double contentHeight,
    double drawerWidth,
    bool isDragging,
    bool shouldAnimate,
  ) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Drawer - positioned below header area (accounting for SafeArea)
          // Use Positioned when dragging for instant updates, AnimatedPositioned otherwise
          isDragging
              ? Positioned(
                  width: drawerWidth,
                  height: contentHeight,
                  top: headerTotalHeight,
                  left: _opened ? 0 : -drawerWidth,
                  child: Container(
                    color: Colors.transparent,
                    child: widget.drawer,
                  ),
                )
              : AnimatedPositioned(
                  width: drawerWidth,
                  height: contentHeight,
                  top: headerTotalHeight,
                  left: _opened ? 0 : -drawerWidth,
                  duration: shouldAnimate 
                      ? Duration(milliseconds: widget.animationDuration)
                      : Duration.zero,
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
              currentWidth: drawerWidth,
              onDragStart: _onResizeDragStart,
              onDragUpdate: _onResizeDragUpdate,
              onDragEnd: _onResizeDragEnd,
              onDragCancel: _onResizeDragCancel,
            ),
          // Main content - constrained to fit between drawer and right edge
          // Use Positioned when dragging for instant updates, AnimatedPositioned otherwise
          isDragging
              ? Positioned(
                  height: height,
                  top: 0,
                  left: _opened ? drawerWidth : 0,
                  right: 0,
                  child: ClipRect(
                    child: widget.child,
                  ),
                )
              : AnimatedPositioned(
                  height: height,
                  top: 0,
                  left: _opened ? drawerWidth : 0,
                  right: 0,
                  duration: shouldAnimate
                      ? Duration(milliseconds: widget.animationDuration)
                      : Duration.zero,
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
  final double currentWidth;
  final Function(double) onDragStart;
  final Function(double) onDragUpdate;
  final Function(double, DrawerWidthProvider) onDragEnd;
  final VoidCallback onDragCancel;

  const _DrawerResizeHandle({
    required this.top,
    required this.height,
    required this.currentWidth,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
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
    final widthProvider = Provider.of<DrawerWidthProvider>(context, listen: false);
    
    return Positioned(
      left: widget.currentWidth - 5,
      top: widget.top,
      height: widget.height,
      width: 10, // Wider hit area for easier dragging
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        onEnter: (_) {
          if (!_isDragging) {
            setState(() {
              _isHovering = true;
            });
          }
        },
        onExit: (_) {
          if (!_isDragging) {
            setState(() {
              _isHovering = false;
            });
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            setState(() {
              _isDragging = true;
              _dragStartX = details.globalPosition.dx;
              _dragStartWidth = widget.currentWidth;
            });
            widget.onDragStart(_dragStartWidth);
          },
          onPanUpdate: (details) {
            if (_isDragging) {
              final deltaX = details.globalPosition.dx - _dragStartX;
              final newWidth = (_dragStartWidth + deltaX).clamp(
                widthProvider.minWidth,
                widthProvider.maxWidth,
              );
              // Call update immediately - this should trigger real-time updates via ValueNotifier
              widget.onDragUpdate(newWidth);
            }
          },
          onPanEnd: (details) {
            if (_isDragging) {
              final deltaX = details.globalPosition.dx - _dragStartX;
              final finalWidth = (_dragStartWidth + deltaX).clamp(
                widthProvider.minWidth,
                widthProvider.maxWidth,
              );
              widget.onDragEnd(finalWidth, widthProvider);
            }
            setState(() {
              _isDragging = false;
              _isHovering = false;
            });
          },
          onPanCancel: () {
            widget.onDragCancel();
            setState(() {
              _isDragging = false;
              _isHovering = false;
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Expanded hit area (transparent but draggable - covers full width)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
                // Visible drag handle indicator
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(vertical: 0),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
