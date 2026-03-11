import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'y_ruler_scrollbar_hint.dart';
import 'y_ruler_scrollbar_node.dart';
import 'y_ruler_scrollbar_painter.dart';
import 'y_ruler_scrollbar_style.dart';

export 'y_ruler_scrollbar_hint.dart';
export 'y_ruler_scrollbar_node.dart';
export 'y_ruler_scrollbar_style.dart';

/// 用于自定义每个刻度节点的标签内容构建器
typedef YScrollbarNodeLabelBuilder = Widget Function(
  BuildContext context,
  YRulerScrollbarNode node,
  int index,
);

/// 类「iOS 相册」风格的可扩展 Scrollbar，支持：
///
/// - **自定义默认/拖拽样式**：颜色、宽度、高度约束、圆角全部可配
/// - **刻度节点**（尺子效果）：主/辅节点用不同长度的刻度线标注，如年份/月份
/// - **精准节点跳转**：轻触 Thumb 附近的节点刻度线，列表平滑跳转至对应位置
/// - **左侧浮动提示**：拖拽时在 Scrollbar 左侧显示当前节点标签（如日期），
///   支持通过 [hintBuilder] 完全自定义样式
///
/// **基本用法：**
/// ```dart
/// final ctrl = ScrollController();
///
/// YRulerScrollbar(
///   controller: ctrl,
///   nodes: [
///     YRulerScrollbarNode(label: '头部', extentRatio: 0.0, isMajor: true),
///     YRulerScrollbarNode(label: '尾部', extentRatio: 1.0, isMajor: true),
///   ],
///   child: ListView.builder(
///     controller: ctrl,
///     itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
///   ),
/// )
/// ```
class YRulerScrollbar extends StatefulWidget {
  /// 被包裹的滚动组件，通常是 [ListView] / [CustomScrollView] 等
  final Widget child;

  /// 滚动控制器，**必须同时传给 [child] 和本组件**
  final ScrollController controller;

  /// Scrollbar 外观配置，提供默认值
  final YRulerScrollbarStyle style;

  /// 刻度节点列表；传空列表表示不显示任何刻度线（退化为纯 thumb scrollbar）
  final List<YRulerScrollbarNode> nodes;

  /// 拖拽时在 Scrollbar 左侧显示的自定义提示 Widget 构建器。
  /// 不传则使用内置的 [YScrollbarDefaultHint]（黑底白字胶囊）。
  final YScrollbarHintBuilder? hintBuilder;

  /// 是否在拖拽时显示左侧提示，默认 true
  final bool showHintOnDrag;

  /// 用于自定义渲染每个节点的刻度提示内容。
  /// 如果提供了此回调，内部将直接通过 Widget 铺在刻度线内侧，不再由 Canvas 绘制默认文本。
  final YScrollbarNodeLabelBuilder? nodeLabelBuilder;

  /// 用于提供指定节点的占比（0.0 ~ 1.0）。
  /// 业务方可以通过传入自己实现 `YRulerScrollbarNode` 接口的真实数据列表，
  /// 并在此处返回：`(该数据在主列表的 Index) / (主列表总 Item 数)`。
  /// 
  /// 如果此回调为 null，默认行为是**均匀分布**（即按照 node 在 `nodes` 列表中的 index 等比划分）。
  final double Function(YRulerScrollbarNode node, int index)? extentRatioBuilder;

  /// 是否仅在拖拽时显示刻度线（即尺子本身）。如果为 true，默认情况下只显示 Thumb，
  /// 拖拽时刻度线才淡入；松手后淡出。默认 true。
  final bool showTicksOnDragOnly;

  /// Scrollbar 距离屏幕右边缘的偏移，默认 4（避免贴边）
  final double scrollbarMarginEnd;

  /// 点击轨道（非节点区域）时是否按比例跳转，默认 true
  final bool tapTrackToScroll;

  /// 点击节点识别的对齐容差（像素），节点 Y ±[nodeTapTolerance] 范围内均视为点击节点
  final double nodeTapTolerance;

  const YRulerScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.style = const YRulerScrollbarStyle(),
    this.nodes = const [],
    this.hintBuilder,
    this.showHintOnDrag = true,
    this.nodeLabelBuilder,
    this.extentRatioBuilder,
    this.showTicksOnDragOnly = true,
    this.scrollbarMarginEnd = 4.0,
    this.tapTrackToScroll = true,
    this.nodeTapTolerance = 12.0,
  });

  @override
  State<YRulerScrollbar> createState() => _YRulerScrollbarState();
}

class _YRulerScrollbarState extends State<YRulerScrollbar>
    with TickerProviderStateMixin {
  late YRulerScrollbarPainter _painter;

  // 控制左侧提示的淡入淡出
  late AnimationController _hintFade;
  // 控制刻度线的淡入淡出
  late AnimationController _tickFade;

  double _currentOffset = 0;
  double _maxScrollExtent = 0;
  double _viewportExtent = 0;
  bool _isDragging = false;

  /// 拖拽时提示面板的 Y 中心偏移（相对于 Scrollbar 容器顶部）
  double _hintCenterY = 0;

  /// 最近的节点（用于提示面板显示）
  YRulerScrollbarNode? _nearestNode;

  @override
  void initState() {
    super.initState();

    _hintFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _tickFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.showTicksOnDragOnly ? 0.0 : 1.0,
    );

    // 刻度线透明度动画驱动画笔更新（但不调用 notifyListeners 避免重构，只需 repaint）
    _tickFade.addListener(() {
      _painter.tickOpacity = _tickFade.value;
      // 触发重绘
      _scrollbarKey.currentContext?.findRenderObject()?.markNeedsPaint();
    });

    _painter = YRulerScrollbarPainter(
      scrollOffset: 0,
      maxScrollExtent: 0,
      viewportExtent: 0,
      isDragging: false,
      nodes: widget.nodes,
      style: widget.style,
      tickOpacity: _tickFade.value,
      extentRatioBuilder: widget.extentRatioBuilder,
      hasCustomNodeLabelBuilder: widget.nodeLabelBuilder != null,
    );

    widget.controller.addListener(_onScroll);

    // 等第一帧渲染完后读取初始 extents
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncExtents());
  }

  @override
  void didUpdateWidget(covariant YRulerScrollbar old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, widget.controller)) {
      old.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
    }
    _painter.nodes = widget.nodes;
    _painter.style = widget.style;
    _painter.hasCustomNodeLabelBuilder = widget.nodeLabelBuilder != null;

    if (old.showTicksOnDragOnly != widget.showTicksOnDragOnly) {
      if (!widget.showTicksOnDragOnly) {
        _tickFade.value = 1.0;
      } else if (!_isDragging) {
        _tickFade.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    _painter.dispose();
    _hintFade.dispose();
    _tickFade.dispose();
    super.dispose();
  }

  // ─── 滚动同步 ─────────────────────────────────────────────────────────────

  void _onScroll() {
    final pos = widget.controller.position;
    _currentOffset = pos.pixels;
    _maxScrollExtent = pos.maxScrollExtent;
    _viewportExtent = pos.viewportDimension;

    _painter.scrollOffset = _currentOffset;
    _painter.maxScrollExtent = _maxScrollExtent;
    _painter.viewportExtent = _viewportExtent;

    // 拖拽时同步提示位置
    if (_isDragging) _updateHintPosition();
  }

  void _syncExtents() {
    if (!mounted) return;
    if (!widget.controller.hasClients) return;
    final pos = widget.controller.position;
    _currentOffset = pos.pixels;
    _maxScrollExtent = pos.maxScrollExtent;
    _viewportExtent = pos.viewportDimension;
    _painter.scrollOffset = _currentOffset;
    _painter.maxScrollExtent = _maxScrollExtent;
    _painter.viewportExtent = _viewportExtent;
  }

  // ─── 交互逻辑 ─────────────────────────────────────────────────────────────

  /// 把触摸点的 dy（相对于轨道顶部）转换为目标 scrollOffset
  double _dyToOffset(double dy, double trackHeight) {
    if (_maxScrollExtent <= 0) return 0;
    final thumbH = _calcThumbHeight(trackHeight);
    final usable = trackHeight - thumbH;
    if (usable <= 0) return 0;
    final ratio = ((dy - thumbH / 2) / usable).clamp(0.0, 1.0);
    return ratio * _maxScrollExtent;
  }

  double _calcThumbHeight(double trackHeight) {
    final total = _viewportExtent + _maxScrollExtent;
    if (total <= 0 || _maxScrollExtent <= 0) return trackHeight;
    final visibleRatio = _viewportExtent / total;
    final raw = trackHeight * visibleRatio;
    return raw.clamp(
      widget.style.thumbMinHeight,
      widget.style.thumbMaxHeight == double.infinity
          ? trackHeight
          : widget.style.thumbMaxHeight,
    );
  }

  /// 更新提示面板的 Y 坐标（让其跟随 thumb 中心）
  void _updateHintPosition() {
    if (!mounted) return;
    final trackHeight = _trackHeight;
    if (trackHeight <= 0) return;
    final thumbH = _calcThumbHeight(trackHeight);
    final usable = trackHeight - thumbH;
    final thumbTop = _maxScrollExtent > 0
        ? usable * (_currentOffset / _maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;
    setState(() {
      _hintCenterY = widget.style.padding.top + thumbTop + thumbH / 2;
      _nearestNode = _findNearestNode();
    });
  }

  /// 获取某个节点的位置比例
  double _getNodeRatio(int index) {
    if (widget.nodes.isEmpty) return 0.0;
    if (widget.extentRatioBuilder != null) {
      return widget.extentRatioBuilder!(widget.nodes[index], index).clamp(0.0, 1.0);
    }
    if (widget.nodes.length > 1) {
      return (index / (widget.nodes.length - 1)).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  /// 从节点列表中找到离当前 scrollOffset 最近的节点
  YRulerScrollbarNode? _findNearestNode() {
    if (widget.nodes.isEmpty) return null;
    YRulerScrollbarNode? best;
    double bestDist = double.infinity;
    for (int i = 0; i < widget.nodes.length; i++) {
      final node = widget.nodes[i];
      final nodeOffset = _getNodeRatio(i) * _maxScrollExtent;
      final d = (nodeOffset - _currentOffset).abs();
      if (d < bestDist) {
        bestDist = d;
        best = node;
      }
    }
    return best;
  }

  /// 获取当前轨道高度（依赖 RenderBox，安全访问）
  double get _trackHeight {
    final box = _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return 0;
    final h = box.size.height;
    return (h - widget.style.padding.vertical).clamp(0.0, double.infinity);
  }

  // ─── 手势处理 ─────────────────────────────────────────────────────────────

  final _scrollbarKey = GlobalKey();

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _painter.isDragging = true;
    _hintFade.forward();
    if (widget.showTicksOnDragOnly) {
      _tickFade.forward();
    }
    _onDragUpdate(
      DragUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        delta: Offset.zero,
        primaryDelta: 0,
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final box =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final dy = (local.dy - widget.style.padding.top)
        .clamp(0.0, _trackHeight);
    final target = _dyToOffset(dy, _trackHeight);

    if (widget.controller.hasClients) {
      widget.controller.jumpTo(target.clamp(0.0, _maxScrollExtent));
    }
    _updateHintPosition();
  }

  void _onDragEnd([DragEndDetails? _]) {
    _isDragging = false;
    _painter.isDragging = false;
    _hintFade.reverse();
    if (widget.showTicksOnDragOnly) {
      _tickFade.reverse();
    }
    setState(() {});
  }

  void _onTapUp(TapUpDetails details) {
    final box =
        _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final dy = (local.dy - widget.style.padding.top)
        .clamp(0.0, _trackHeight);

    // 如果刻度已经可见，优先检查点击节点
    // (如果设置了 showTicksOnDragOnly 且不在拖拽状态，理论上用户看不见刻度线，但为方便可能仍然响应点击。
    // 这里为了防止误触，仅在 tick 可见度较大时响应节点跳转)
    if (widget.nodes.isNotEmpty && _tickFade.value > 0.5) {
      final thumbH = _calcThumbHeight(_trackHeight);
      for (int i = 0; i < widget.nodes.length; i++) {
        final usable = _trackHeight - thumbH;
        final nodeOffset = _getNodeRatio(i) * _maxScrollExtent;
        final nodeY = _maxScrollExtent > 0
            ? usable *
                    (nodeOffset / _maxScrollExtent).clamp(0.0, 1.0) +
                thumbH / 2
            : 0.0;
        if ((dy - nodeY).abs() <= widget.nodeTapTolerance) {
          if (widget.controller.hasClients) {
            widget.controller.animateTo(
              nodeOffset.clamp(0.0, _maxScrollExtent),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          return;
        }
      }
    }

    // 其次：按比例跳转
    if (widget.tapTrackToScroll && widget.controller.hasClients) {
      final target = _dyToOffset(dy, _trackHeight);
      widget.controller.animateTo(
        target.clamp(0.0, _maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Scrollbar 总宽度：
    // 如果没有节点，或者处于隐藏刻度线的模式且没有标签，则纯粹用 thumb 宽。
    // 但是考虑到手势感应区和将来需要淡入的刻度区，我们始终分配最大的必要宽度。
    final hasNodes = widget.nodes.isNotEmpty;
    final maxTickLen = hasNodes
        ? (widget.nodes.any((n) => n.isMajor)
            ? widget.style.majorTickLength
            : widget.style.minorTickLength)
        : 0.0;
    final labelWidth = (hasNodes && widget.style.labelStyle != null) ? 36.0 : 0.0;
    
    // 如果 nodes 为空（简单模式），完全不需要预留刻度和标签的宽度
    final scrollbarWidth = widget.style.thumbWidth +
        (hasNodes ? (maxTickLen + labelWidth) : 0.0) +
        widget.style.padding.horizontal;

    return Stack(
      children: [
        // ── 主内容 ─────────────────────────────────────────────────────────
        widget.child,

        // ── Scrollbar（右侧固定列） ─────────────────────────────────────────
        Positioned(
          top: 0,
          bottom: 0,
          right: widget.scrollbarMarginEnd,
          width: scrollbarWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onVerticalDragCancel: _onDragEnd,
            onTapUp: _onTapUp,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 延迟同步 viewport 尺寸
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _syncExtents();
                });
                
                final trackHeight = constraints.maxHeight;
                final thumbH = _calcThumbHeight(trackHeight);
                final usable = trackHeight - thumbH;
                final bool showLabels = widget.nodeLabelBuilder != null && widget.nodes.isNotEmpty;
                final trackRightPadding = widget.style.padding.right;

                final paintWidget = RepaintBoundary(
                  child: CustomPaint(
                    key: _scrollbarKey,
                    painter: _painter,
                    size: Size(scrollbarWidth, trackHeight),
                  ),
                );

                if (!showLabels) return paintWidget;

                return AnimatedBuilder(
                  animation: _tickFade,
                  builder: (context, child) {
                    final tickOpacity = _tickFade.value;
                    return Stack(
                      children: [
                        paintWidget,
                        if (tickOpacity > 0)
                          ...List.generate(widget.nodes.length, (i) {
                            final node = widget.nodes[i];
                            final nodeOffset = _getNodeRatio(i) * _maxScrollExtent;
                            final nodeY = _maxScrollExtent > 0
                                ? usable * (nodeOffset / _maxScrollExtent).clamp(0.0, 1.0) + thumbH / 2
                                : 0.0;

                            return Positioned(
                              right: maxTickLen + trackRightPadding + 4,
                              top: nodeY - 100, // 设定很大一块空间来使用 Center 对齐
                              height: 200,
                              child: Opacity(
                                opacity: tickOpacity,
                                child: Center(
                                  child: widget.nodeLabelBuilder!(context, node, i),
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),

        // ── 左侧浮动提示（仅拖拽时可见） ────────────────────────────────────
        if (widget.showHintOnDrag)
          AnimatedBuilder(
            animation: _hintFade,
            builder: (context, child) {
              return Positioned(
                right: widget.scrollbarMarginEnd + scrollbarWidth + 4,
                top: 0,
                bottom: 0,
                child: IgnorePointer( // 防止阻挡滑动手势
                  child: FadeTransition(
                    opacity: _hintFade,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          (_hintCenterY - 20).clamp(0.0, double.infinity),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: _buildHint(),
          ),
      ],
    );
  }

  Widget _buildHint() {
    if (widget.hintBuilder != null) {
      return widget.hintBuilder!(context, _nearestNode, _currentOffset);
    }
    return YScrollbarDefaultHint(
      nearestNode: _nearestNode,
      currentOffset: _currentOffset,
    );
  }
}
