import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// 拖拽多选锚点元素
///
/// 作为 YDragSelectRegion 的配合组件，用于包裹在您的每一个可见子项目最外层。
/// [index] 为该项目在经过全部铺平后的一维数据列表中的唯一索引位置。
class YDragSelectElement extends StatelessWidget {
  /// 该项目在展平的一维数组中的索引位置
  final int index;

  /// 要包裹的真正组件项目
  final Widget child;

  /// 自定义额外携带元数据（若不仅仅需要索引）
  final Object? extra;

  const YDragSelectElement({
    super.key,
    required this.index,
    required this.child,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: _YDragSelectData(index: index, extra: extra),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// 内部包装的专有类型，防止取到其他杂质 MetaData
class _YDragSelectData {
  final int index;
  final Object? extra;

  const _YDragSelectData({required this.index, this.extra});
}

/// 全局长按滑动多选交互层
///
/// 包裹在整个流布局外围。它将拦截并托管长按 [onLongPress] 的一切拖拽追踪事件。
/// 并利用 [ScrollController] 实现靠近屏幕边缘进行智能滚动的能力。
class YDragSelectRegion extends StatefulWidget {
  final Widget child;

  /// 绑定的滚动控制器以执行边缘滚动。如果不传则尝试寻找 [PrimaryScrollController]
  final ScrollController? scrollController;

  /// 长按进入选中状态。
  /// 返回当前命中节点的全局一维索引
  final ValueChanged<int>? onDragSelectStart;

  /// 持续滑动更新中...
  /// 框架将保证计算到起点的 [startIndex] 与当前命中元素的 [currentIndex]，
  /// 以预防由于剧烈滑动带来的跳帧漏选。
  final void Function(int startIndex, int currentIndex)? onDragSelectUpdate;

  /// 鼠标或手指松开抬起，结束当前拖拽选择批次。
  final VoidCallback? onDragSelectEnd;

  /// 触发边缘滚动的阈值区域（距离容器顶侧/底侧的内部距离）
  final double autoScrollEdgeThreshold;

  /// 边缘自动滚动的最大速度 (像素/每帧)
  final double maxAutoScrollVelocity;

  const YDragSelectRegion({
    super.key,
    required this.child,
    this.scrollController,
    this.onDragSelectStart,
    this.onDragSelectUpdate,
    this.onDragSelectEnd,
    this.autoScrollEdgeThreshold = 80.0,
    this.maxAutoScrollVelocity = 14.0,
  });

  @override
  State<YDragSelectRegion> createState() => _YDragSelectRegionState();
}

class _YDragSelectRegionState extends State<YDragSelectRegion>
    with SingleTickerProviderStateMixin {
  int? _startIndex;
  int? _currentIndex;

  Offset? _currentGlobalPointer;
  late Ticker _autoScrollTicker;

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
    if (_currentGlobalPointer == null) return;
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(_currentGlobalPointer!);
    final double height = box.size.height;
    final double y = localPos.dy;

    double velocity = 0;

    if (y < widget.autoScrollEdgeThreshold) {
      // 靠近顶部，向上滚动，速度逐渐增加
      final ratio = (widget.autoScrollEdgeThreshold -
              y.clamp(0.0, widget.autoScrollEdgeThreshold)) /
          widget.autoScrollEdgeThreshold;
      velocity = -widget.maxAutoScrollVelocity * ratio;
    } else if (y > height - widget.autoScrollEdgeThreshold) {
      // 靠近底部，向下滚动，速度逐渐增加
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
        // 既然页面被滚走了，相对指针的位置就变了，需要重新寻找落盘的目标
        _performHitTest(_currentGlobalPointer!);
      }
    }
  }

  int? _performHitTest(Offset globalPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final localPosition = box.globalToLocal(globalPosition);
    final BoxHitTestResult result = BoxHitTestResult();

    // 只检索包裹在自己视觉下的 RenderBox 子树
    box.hitTest(result, position: localPosition);

    for (final HitTestEntry entry in result.path) {
      final target = entry.target;
      if (target is RenderMetaData) {
        final meta = target.metaData;
        if (meta is _YDragSelectData) {
          final index = meta.index;
          if (_currentIndex != index) {
            _currentIndex = index;
            if (_startIndex != null) {
              widget.onDragSelectUpdate?.call(_startIndex!, _currentIndex!);
            }
          }
          return index;
        }
      }
    }
    return null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    final index = _performHitTest(details.globalPosition);
    if (index != null) {
      _startIndex = index;
      _currentIndex = index;
      _currentGlobalPointer = details.globalPosition;
      widget.onDragSelectStart?.call(index);

      // 可以开启边缘滚动了
      if (!_autoScrollTicker.isTicking) {
        _autoScrollTicker.start();
      }
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_startIndex == null) return;
    _currentGlobalPointer = details.globalPosition;
    _performHitTest(details.globalPosition);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _cleanup();
    widget.onDragSelectEnd?.call();
  }

  void _onLongPressCancel() {
    _cleanup();
    widget.onDragSelectEnd?.call();
  }

  void _cleanup() {
    _startIndex = null;
    _currentIndex = null;
    _currentGlobalPointer = null;
    if (_autoScrollTicker.isTicking) {
      _autoScrollTicker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
