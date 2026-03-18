import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'y_desktop_selection_controller.dart';
import '../../model/y_selection_data.dart';

/// 桌面端框选区域组件
///
/// 负责捕获鼠标拖拽事件，绘制框选矩形，并更新 [YDesktopSelectionController] 的状态。
class YDesktopSelectionRegion extends StatefulWidget {
  final Widget child;
  final YDesktopSelectionController controller;
  final ScrollController? scrollController;

  /// 触发边缘滚动的阈值区域
  final double autoScrollEdgeThreshold;

  /// 边缘自动滚动的最大速度
  final double maxAutoScrollVelocity;

  /// 逻辑选择计算器
  final Set<int> Function(Rect rectInContent)? customSelectionCalculator;

  /// 是否开启点击背景清除选择
  final bool enableClearSelectionOnTapBackground;
  
  /// 选框填充颜色
  final Color? marqueeFillColor;
  
  /// 选框边框颜色
  final Color? marqueeBorderColor;
  
  /// 选框边框宽度
  final double marqueeBorderWidth;

  const YDesktopSelectionRegion({
    super.key,
    required this.child,
    required this.controller,
    this.scrollController,
    this.customSelectionCalculator,
    this.autoScrollEdgeThreshold = 80.0,
    this.maxAutoScrollVelocity = 14.0,
    this.enableClearSelectionOnTapBackground = true,
    this.marqueeFillColor,
    this.marqueeBorderColor,
    this.marqueeBorderWidth = 1.0,
  });

  @override
  State<YDesktopSelectionRegion> createState() => _YDesktopSelectionRegionState();
}

class _YDesktopSelectionRegionState extends State<YDesktopSelectionRegion>
    with SingleTickerProviderStateMixin {
  Offset? _dragStartGlobal;
  Offset? _dragCurrentGlobal;
  double _initialScrollOffset = 0;
  late Ticker _autoScrollTicker;
  
  // 记录开始拖拽时的修饰键状态，决定是否是增量选择
  bool _isIncremental = false;
  Set<int> _initialSelection = {};
  int? _startHitIndex;

  @override
  void initState() {
    super.initState();
    _autoScrollTicker = createTicker(_onAutoScrollTick);
  }

  @override
  void dispose() {
    _autoScrollTicker.dispose();
    super.dispose();
  }

  ScrollController? get _scrollController {
    return widget.scrollController ?? PrimaryScrollController.maybeOf(context);
  }

  void _onAutoScrollTick(Duration elapsed) {
    if (_dragCurrentGlobal == null) return;
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(_dragCurrentGlobal!);
    final double height = box.size.height;
    final double y = localPos.dy;

    double velocity = 0;

    if (y < widget.autoScrollEdgeThreshold) {
      final ratio = (widget.autoScrollEdgeThreshold -
              y.clamp(0.0, widget.autoScrollEdgeThreshold)) /
          widget.autoScrollEdgeThreshold;
      velocity = -widget.maxAutoScrollVelocity * ratio;
    } else if (y > height - widget.autoScrollEdgeThreshold) {
      final ratio = ((y - (height - widget.autoScrollEdgeThreshold))
              .clamp(0.0, widget.autoScrollEdgeThreshold)) /
          widget.autoScrollEdgeThreshold;
      velocity = widget.maxAutoScrollVelocity * ratio;
    }

    if (velocity != 0) {
      final double newOffset = (controller.offset + velocity).clamp(
        controller.position.minScrollExtent,
        controller.position.maxScrollExtent,
      );
      if (newOffset != controller.offset) {
        controller.jumpTo(newOffset);
        _updateSelection();
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    _isIncremental = HardwareKeyboard.instance.isMetaPressed || 
                     HardwareKeyboard.instance.isControlPressed ||
                     HardwareKeyboard.instance.isShiftPressed;
    
    if (_isIncremental) {
      _initialSelection = Set.from(widget.controller.selectedIndices);
    } else {
      _initialSelection = {};
      widget.controller.clearSelection();
    }
    _startHitIndex = null;

    setState(() {
      _dragStartGlobal = details.globalPosition;
      _dragCurrentGlobal = details.globalPosition;
      _initialScrollOffset = _scrollController?.offset ?? 0;
    });
    
    _startHitIndex = _findHitIndex(details.globalPosition);

    if (!_autoScrollTicker.isTicking) {
      _autoScrollTicker.start();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragCurrentGlobal = details.globalPosition;
    });
    _updateSelection();
  }

  void _onPanEnd(DragEndDetails details) {
    _cleanup();
  }

  void _onPanCancel() {
    _cleanup();
  }

  void _cleanup() {
    setState(() {
      _dragStartGlobal = null;
      _dragCurrentGlobal = null;
      _initialScrollOffset = 0;
    });
    _startHitIndex = null;
    if (_autoScrollTicker.isTicking) {
      _autoScrollTicker.stop();
    }
  }

  void _updateSelection() {
    if (_dragStartGlobal == null || _dragCurrentGlobal == null) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final scrollOffset = _scrollController?.offset ?? 0;

    final startLocal = box.globalToLocal(_dragStartGlobal!);
    final startInContent = startLocal.translate(0, _initialScrollOffset);
    final currentLocal = box.globalToLocal(_dragCurrentGlobal!);
    final currentInContent = currentLocal.translate(0, scrollOffset);

    // 计算内容坐标系下的选择矩形
    final rectInContent = Rect.fromPoints(startInContent, currentInContent);

    if (widget.customSelectionCalculator != null) {
      // 模式 A：逻辑模式。直接通过集合运算计算索引，支持虚拟化。
      final Set<int> capturedIndices = widget.customSelectionCalculator!(rectInContent);
      _applyCapturedIndices(capturedIndices);
    } else {
      // 模式 B：物理模式。回退到通过遍历渲染树寻找 MetaData。
      // 计算当前在可视区域（Viewport）内的相对矩形
      final rectInViewport = Rect.fromPoints(
        startInContent.translate(0, -scrollOffset),
        currentLocal,
      );
      _performPhysicalMarqueeSelection(rectInViewport);
    }
  }

  void _applyCapturedIndices(Set<int> capturedIndices) {
    if (_isIncremental) {
      final combined = Set<int>.from(_initialSelection)..addAll(capturedIndices);
      widget.controller.updateSelection(combined);
    } else {
      widget.controller.updateSelection(capturedIndices);
    }
  }

  void _performPhysicalMarqueeSelection(Rect marqueeRect) {
    final Set<int> capturedIndices = {};
    
    void visitor(Element element) {
      final renderObject = element.renderObject;
      if (renderObject is RenderBox) {
        final data = _getSelectionData(renderObject);
        if (data != null) {
          final box = renderObject;
          final ancestor = context.findRenderObject() as RenderBox;
          final localPos = box.localToGlobal(Offset.zero, ancestor: ancestor);
          final boxRect = localPos & box.size;
          
          if (marqueeRect.overlaps(boxRect)) {
            capturedIndices.add(data.index);
          }
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    
    if (capturedIndices.isNotEmpty) {
      final vMin = capturedIndices.reduce((a, b) => a < b ? a : b);
      final vMax = capturedIndices.reduce((a, b) => a > b ? a : b);
      
      _startHitIndex ??= vMin; 
      
      final Set<int> finalIndices = {};
      final rangeStart = _startHitIndex! < vMin ? _startHitIndex! : vMin;
      final rangeEnd = _startHitIndex! > vMax ? _startHitIndex! : vMax;
      
      for (int i = rangeStart; i <= rangeEnd; i++) {
        finalIndices.add(i);
      }
      _applyCapturedIndices(finalIndices);
    } else {
      _applyCapturedIndices({});
    }
  }

  YSelectionData? _getSelectionData(RenderBox box) {
    if (box is RenderMetaData) {
      final meta = box.metaData;
      if (meta is YSelectionData) {
        return meta;
      }
    }
    return null;
  }

  int? _findHitIndex(Offset globalPos) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final localPos = box.globalToLocal(globalPos);

    int? foundIndex;
    void visitor(Element element) {
      if (foundIndex != null) return;
      final renderObject = element.renderObject;
      if (renderObject is RenderBox) {
        final data = _getSelectionData(renderObject);
        if (data != null) {
          final itemBox = renderObject;
          final ancestor = context.findRenderObject() as RenderBox;
          final pos = itemBox.localToGlobal(Offset.zero, ancestor: ancestor);
          final rect = pos & itemBox.size;
          if (rect.contains(localPos)) {
            foundIndex = data.index;
          }
        }
      }
      if (foundIndex == null) {
        element.visitChildren(visitor);
      }
    }

    context.visitChildElements(visitor);
    return foundIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final box = context.findRenderObject() as RenderBox?;
    
    Offset? startInViewport;
    Offset? currentInViewport;
    
    if (box != null && _dragStartGlobal != null && _dragCurrentGlobal != null) {
      final scrollOffset = _scrollController?.offset ?? 0;
      final startLocal = box.globalToLocal(_dragStartGlobal!);
      // 将起始点固定在内容上：
      // 起始点在可视区域的位置 = (其实时物理位置 + 起始时滚动) - 当前滚动
      startInViewport = startLocal.translate(0, _initialScrollOffset - scrollOffset);
      currentInViewport = box.globalToLocal(_dragCurrentGlobal!);
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      onTap: () {
        if (widget.enableClearSelectionOnTapBackground) {
          // 点击背景（未被子组件拦截）时清除选择
          widget.controller.clearSelection();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          widget.child,
          if (startInViewport != null && currentInViewport != null)
            CustomPaint(
              painter: _MarqueePainter(
                start: startInViewport,
                current: currentInViewport,
                fillColor: widget.marqueeFillColor ?? theme.primaryColor.withValues(alpha: 0.2),
                borderColor: widget.marqueeBorderColor ?? theme.primaryColor,
                borderWidth: widget.marqueeBorderWidth,
              ),
              size: Size.infinite,
            ),
        ],
      ),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  final Offset start;
  final Offset current;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  _MarqueePainter({
    required this.start, 
    required this.current,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, current);
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(_MarqueePainter oldDelegate) => 
      oldDelegate.start != start || 
      oldDelegate.current != current ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}
