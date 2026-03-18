import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'y_ruler_scrollbar_hint.dart';
import 'y_ruler_scrollbar_node.dart';
import 'y_ruler_scrollbar_painter.dart';
import 'y_ruler_scrollbar_style.dart';

export 'y_ruler_scrollbar_hint.dart';
export 'y_ruler_scrollbar_node.dart';
export 'y_ruler_scrollbar_style.dart';

typedef YScrollbarNodeLabelBuilder = Widget Function(
  BuildContext context,
  YRulerScrollbarNode node,
  int index,
);

/// 自定义滑块组件构建器
/// [thumbHeight] 当前计算出的滑块高度
/// [isDragging] 是否正在拖拽中
typedef YScrollbarThumbBuilder = Widget Function(
  BuildContext context,
  double thumbHeight,
  bool isDragging,
);

/// Scrollbar 交互状态
enum YScrollbarInteractionState {
  down,
  move,
  up,
}

class YRulerScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final YRulerScrollbarStyle style;
  final List<YRulerScrollbarNode> nodes;
  final YScrollbarHintBuilder? hintBuilder;
  final bool showHintOnDrag;
  final YScrollbarNodeLabelBuilder? nodeLabelBuilder;

  /// 自定义滑块构建器。如果不提供，将使用内置的样式绘制滑块。
  final YScrollbarThumbBuilder? thumbBuilder;

  final double Function(YRulerScrollbarNode node, int index)?
      extentRatioBuilder;
  final double Function(YRulerScrollbarNode node, int index)?
      scrollOffsetBuilder;
  final double Function(YRulerScrollbarNode node, int index)?
      hintScrollOffsetBuilder;
  final bool showTicksOnDragOnly;
  final double scrollbarMarginEnd;
  final double scrollbarMarginTop;
  final double scrollbarMarginBottom;
  final bool tapTrackToScroll;
  final double nodeTapTolerance;
  final bool thumbVisibility;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration timeToFade;
  final List<YRulerScrollbarNode>? hintNodes;
  final double Function(YRulerScrollbarNode node, int index)?
      hintExtentRatioBuilder;
  final ValueChanged<YRulerScrollbarNode?>? onHintChanged;

  const YRulerScrollbar({
    super.key,
    required this.child,
    required this.controller,
    this.style = const YRulerScrollbarStyle(),
    this.nodes = const [],
    this.hintNodes,
    this.hintBuilder,
    this.thumbBuilder,
    this.showHintOnDrag = true,
    this.nodeLabelBuilder,
    this.extentRatioBuilder,
    this.scrollOffsetBuilder,
    this.hintExtentRatioBuilder,
    this.hintScrollOffsetBuilder,
    this.showTicksOnDragOnly = true,
    this.scrollbarMarginEnd = 4.0,
    this.scrollbarMarginTop = 0.0,
    this.scrollbarMarginBottom = 0.0,
    this.tapTrackToScroll = true,
    this.nodeTapTolerance = 12.0,
    this.thumbVisibility = false,
    this.fadeInDuration = const Duration(milliseconds: 100),
    this.fadeOutDuration = const Duration(milliseconds: 300),
    this.timeToFade = const Duration(milliseconds: 1000),
    this.onHintChanged,
    this.onInteraction,
    this.enableDebugLog = false,
  });

  final void Function(YScrollbarInteractionState state, Offset localPosition)?
      onInteraction;
  final bool enableDebugLog;

  @override
  State<YRulerScrollbar> createState() => _YRulerScrollbarState();
}

class _YRulerScrollbarState extends State<YRulerScrollbar>
    with TickerProviderStateMixin {
  late YRulerScrollbarPainter _painter;

  late AnimationController _hintFade;
  late AnimationController _thumbFade;
  late AnimationController _tickFade;
  Timer? _fadeoutTimer;

  double _currentOffset = 0;
  double _maxScrollExtent = 0;
  double _viewportExtent = 0;
  bool _isDragging = false;

  Offset _lastLocalPosition = Offset.zero;
  double? _dragStartThumbTop;
  double? _dragStartY;

  double _hintCenterY = 0;
  YRulerScrollbarNode? _nearestNode;

  final GlobalKey _scrollbarKey = GlobalKey();

  List<YRulerScrollbarNode> get _effectiveHintNodes =>
      widget.hintNodes ?? widget.nodes;

  @override
  void initState() {
    super.initState();
    _hintFade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _thumbFade = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
      reverseDuration: widget.fadeOutDuration,
      value: widget.thumbVisibility ? 1.0 : 0.0,
    );
    _tickFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.showTicksOnDragOnly ? 0.0 : 1.0,
    );

    _tickFade.addListener(() {
      _painter.tickOpacity = _tickFade.value;
    });

    _painter = YRulerScrollbarPainter(
      maxScrollExtent: 0,
      thumbHeight: widget.style.thumbMinHeight,
      nodes: widget.nodes,
      style: widget.style,
      tickOpacity: _tickFade.value,
      extentRatioBuilder: widget.extentRatioBuilder,
      hasCustomNodeLabelBuilder: widget.nodeLabelBuilder != null,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncExtents());
  }

  @override
  void didUpdateWidget(covariant YRulerScrollbar old) {
    super.didUpdateWidget(old);
    if (!identical(old.controller, widget.controller)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncExtents());
    }
    _painter.nodes = widget.nodes;
    _painter.style = widget.style;
    _painter.extentRatioBuilder = widget.extentRatioBuilder;
    _painter.hasCustomNodeLabelBuilder = widget.nodeLabelBuilder != null;

    if (old.showTicksOnDragOnly != widget.showTicksOnDragOnly) {
      if (!widget.showTicksOnDragOnly) {
        _tickFade.value = 1.0;
      } else if (!_isDragging) {
        _tickFade.value = 0.0;
      }
    }

    if (old.thumbVisibility != widget.thumbVisibility) {
      if (widget.thumbVisibility) {
        _thumbFade.value = 1.0;
        _fadeoutTimer?.cancel();
      } else if (!_isDragging) {
        _startFadeoutTimer();
      }
    }

    if (old.fadeInDuration != widget.fadeInDuration) {
      _thumbFade.duration = widget.fadeInDuration;
    }
    if (old.fadeOutDuration != widget.fadeOutDuration) {
      _thumbFade.reverseDuration = widget.fadeOutDuration;
    }
    if (old.timeToFade != widget.timeToFade) {
      if (_fadeoutTimer?.isActive ?? false) _startFadeoutTimer();
    }
  }

  @override
  void dispose() {
    _painter.dispose();
    _hintFade.dispose();
    _thumbFade.dispose();
    _tickFade.dispose();
    _fadeoutTimer?.cancel();
    super.dispose();
  }

  void _syncExtents() {
    if (!mounted) return;
    if (!widget.controller.hasClients) return;
    _updateFromMetrics(widget.controller.position);
  }

  void _updateFromMetrics(ScrollMetrics metrics) {
    _currentOffset = metrics.pixels;
    _viewportExtent = metrics.viewportDimension;

    // 拖拽期间，不更新渲染用的 _maxScrollExtent 避免跳变
    if (!_isDragging) {
      _maxScrollExtent = metrics.maxScrollExtent;
    }

    _painter.maxScrollExtent = _maxScrollExtent;

    if (widget.enableDebugLog) {
      debugPrint(
          '[YRulerScrollbar] offset: ${_currentOffset.toStringAsFixed(1)}, max: ${_maxScrollExtent.toStringAsFixed(1)}, viewport: ${_viewportExtent.toStringAsFixed(1)}, dragging: $_isDragging');
    }

    _updateHintPosition();
    // 触发重绘以更新 Widget 树中的滑块位置
    setState(() {});
  }

  void _showThumb() {
    if (widget.thumbVisibility || _isDragging || !mounted) return;
    if (_thumbFade.status != AnimationStatus.forward &&
        _thumbFade.value < 1.0) {
      _thumbFade.forward();
    }
    _startFadeoutTimer();
  }

  void _startFadeoutTimer() {
    _fadeoutTimer?.cancel();
    _fadeoutTimer = Timer(widget.timeToFade, () {
      if (mounted && !widget.thumbVisibility && !_isDragging) {
        _thumbFade.reverse();
      }
    });
  }

  // ─── 映射与计算逻辑 ─────────────────────────────────────────────────────────

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

  double _getNodeRatio(int index,
      {List<YRulerScrollbarNode>? nodes,
      double Function(YRulerScrollbarNode, int)? ratioBuilder}) {
    final targetNodes = nodes ?? widget.nodes;

    // 如果 caller 明确传入了 ratioBuilder，则使用之
    if (ratioBuilder != null) {
      return ratioBuilder(targetNodes[index], index).clamp(0.0, 1.0);
    }

    // 否则，根据 targetNodes 到底是 nodes 还是 hintNodes 来选择对应的 builder
    final isHintNodes = identical(targetNodes, widget.hintNodes);
    final builder =
        isHintNodes ? widget.hintExtentRatioBuilder : widget.extentRatioBuilder;

    if (targetNodes.isEmpty) return 0.0;
    if (builder != null)
      return builder(targetNodes[index], index).clamp(0.0, 1.0);
    if (targetNodes.length > 1)
      return (index / (targetNodes.length - 1)).clamp(0.0, 1.0);
    return 0.0;
  }

  double _nodeToActualOffset(int index,
      {List<YRulerScrollbarNode>? nodes,
      double Function(YRulerScrollbarNode, int)? ratioBuilder,
      double Function(YRulerScrollbarNode, int)? offsetBuilder}) {
    final targetNodes = nodes ?? widget.nodes;

    // 同样，根据 targetNodes 到底是 nodes 还是 hintNodes 来选择对应的 offsetBuilder
    final isHintNodes = identical(targetNodes, widget.hintNodes);
    final builder = offsetBuilder ??
        (isHintNodes
            ? widget.hintScrollOffsetBuilder
            : widget.scrollOffsetBuilder);

    if (index < 0 || index >= targetNodes.length) return 0;
    if (builder != null) return builder(targetNodes[index], index);
    return _getNodeRatio(index,
            nodes: targetNodes, ratioBuilder: ratioBuilder) *
        _maxScrollExtent;
  }

  double _offsetToYRatio(double offset) {
    if (_maxScrollExtent <= 0) return 0;

    // 如果没有节点，或者处于单纯按比例滑动的模式，则直接返回比例
    if (widget.nodes.isEmpty)
      return (offset / _maxScrollExtent).clamp(0.0, 1.0);

    // 强制使用 widget.nodes，不使用 hintNodes 干扰 Thumb 位置的计算
    final nodes = widget.nodes;

    final o0 = _nodeToActualOffset(0, nodes: nodes);
    final r0 = _getNodeRatio(0, nodes: nodes);
    if (offset <= o0) return r0 > 0 && o0 > 0 ? (offset / o0) * r0 : r0;

    final oLast = _nodeToActualOffset(nodes.length - 1, nodes: nodes);
    final rLast = _getNodeRatio(nodes.length - 1, nodes: nodes);
    if (offset >= oLast) {
      final effectiveMax = _maxScrollExtent > oLast ? _maxScrollExtent : oLast;
      if (effectiveMax <= oLast) return rLast;
      return rLast + (offset - oLast) / (effectiveMax - oLast) * (1.0 - rLast);
    }

    int i = 0;
    while (i < nodes.length - 1) {
      if (offset <= _nodeToActualOffset(i + 1, nodes: nodes)) break;
      i++;
    }

    final oStart = _nodeToActualOffset(i, nodes: nodes);
    final oEnd = _nodeToActualOffset(i + 1, nodes: nodes);
    final rStart = _getNodeRatio(i, nodes: nodes);
    final rEnd = _getNodeRatio(i + 1, nodes: nodes);

    if (oEnd == oStart) return rStart;
    return rStart + (offset - oStart) / (oEnd - oStart) * (rEnd - rStart);
  }

  double _yRatioToOffset(double yRatio) {
    if (_maxScrollExtent <= 0) return 0;

    if (widget.nodes.isEmpty) return yRatio * _maxScrollExtent;

    // 强制使用 widget.nodes
    final nodes = widget.nodes;

    final r0 = _getNodeRatio(0, nodes: nodes);
    final o0 = _nodeToActualOffset(0, nodes: nodes);
    if (yRatio <= r0) return r0 > 0 ? (yRatio / r0) * o0 : o0;

    final rLast = _getNodeRatio(nodes.length - 1, nodes: nodes);
    final oLast = _nodeToActualOffset(nodes.length - 1, nodes: nodes);
    if (yRatio >= rLast) {
      if (rLast >= 1.0) return oLast;
      final effectiveMax = _maxScrollExtent > oLast ? _maxScrollExtent : oLast;
      return oLast + (yRatio - rLast) / (1.0 - rLast) * (effectiveMax - oLast);
    }

    int i = 0;
    while (i < nodes.length - 1) {
      if (yRatio <= _getNodeRatio(i + 1, nodes: nodes)) break;
      i++;
    }

    final rStart = _getNodeRatio(i, nodes: nodes);
    final rEnd = _getNodeRatio(i + 1, nodes: nodes);
    final oStart = _nodeToActualOffset(i, nodes: nodes);
    final oEnd = _nodeToActualOffset(i + 1, nodes: nodes);

    if (rEnd == rStart) return oStart;
    return oStart + (yRatio - rStart) / (rEnd - rStart) * (oEnd - oStart);
  }

  YRulerScrollbarNode? _findNearestNode() {
    final nodes = _effectiveHintNodes;
    if (nodes.isEmpty) return null;

    YRulerScrollbarNode? best;
    for (int i = 0; i < nodes.length; i++) {
      double nodeActiveOffset = _nodeToActualOffset(i, nodes: nodes);
      // 容差值44，应对Header吸顶效果
      if (_currentOffset + 44.0 >= nodeActiveOffset) {
        best = nodes[i];
      } else {
        break;
      }
    }
    return best ?? nodes.first;
  }

  void _updateHintPosition() {
    if (!mounted) return;
    final trackHeight = _trackHeight;
    if (trackHeight <= 0) return;
    final thumbH = _calcThumbHeight(trackHeight);
    final ratio = _offsetToYRatio(_currentOffset);
    final thumbTop = (trackHeight - thumbH) * ratio;

    final newNode = _findNearestNode();

    // 只有在拖拽状态下，才触发 onHintChanged（比如震动反馈）
    if (newNode != _nearestNode && _isDragging) {
      widget.onHintChanged?.call(newNode);
    }

    final newHintCenterY = widget.style.padding.top + thumbTop + thumbH / 2;
    if (_hintCenterY != newHintCenterY || _nearestNode != newNode) {
      _hintCenterY = newHintCenterY;
      _nearestNode = newNode;
      // Note: State is updated along with the main widget tree in `_updateFromMetrics`
      // or drag events. We don't necessarily need a separate setState here to avoid loop.
    }
  }

  double get _trackHeight {
    final box = _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return 0;
    return (box.size.height - widget.style.padding.vertical)
        .clamp(0.0, double.infinity);
  }

  // ─── 手势处理 ─────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _fadeoutTimer?.cancel();
    _lastLocalPosition = details.localPosition;
    widget.onInteraction
        ?.call(YScrollbarInteractionState.down, details.localPosition);

    final trackHeight = _trackHeight;
    final thumbH = _calcThumbHeight(trackHeight);
    final ratio = _offsetToYRatio(_currentOffset);
    final currentThumbTop =
        widget.style.padding.top + (trackHeight - thumbH) * ratio;

    final dy = details.localPosition.dy;
    if (dy >= currentThumbTop && dy <= currentThumbTop + thumbH) {
      _dragStartThumbTop = currentThumbTop - widget.style.padding.top;
      _dragStartY = dy;
    } else {
      _dragStartThumbTop = null;
      _dragStartY = null;
      _onDragUpdate(DragUpdateDetails(
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
        delta: Offset.zero,
        primaryDelta: 0,
      ));
    }

    _hintFade.forward();
    _thumbFade.forward();
    if (widget.showTicksOnDragOnly) {
      _tickFade.forward();
    }
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final box = _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final trackHeight = _trackHeight;
    final thumbH = _calcThumbHeight(trackHeight);
    final usable = trackHeight - thumbH;

    if (usable <= 0 || _maxScrollExtent <= 0) return;

    double newThumbTop;
    if (_dragStartThumbTop != null && _dragStartY != null) {
      final deltaY = local.dy - _dragStartY!;
      newThumbTop = (_dragStartThumbTop! + deltaY).clamp(0.0, usable);
    } else {
      final dy = (local.dy - widget.style.padding.top).clamp(0.0, trackHeight);
      newThumbTop = (dy - thumbH / 2).clamp(0.0, usable);
    }

    final yRatio = newThumbTop / usable;
    final targetOffset = _yRatioToOffset(yRatio);

    if (widget.controller.hasClients) {
      widget.controller.jumpTo(targetOffset);
    }
    _lastLocalPosition = local;
    widget.onInteraction?.call(YScrollbarInteractionState.move, local);
    _updateHintPosition();
    setState(() {});
  }

  void _onDragEnd([DragEndDetails? _]) {
    _isDragging = false;
    widget.onInteraction
        ?.call(YScrollbarInteractionState.up, _lastLocalPosition);
    _hintFade.reverse();
    if (widget.showTicksOnDragOnly) {
      _tickFade.reverse();
    }
    if (!widget.thumbVisibility) {
      _startFadeoutTimer();
    }
    setState(() {});
  }

  void _onTapUp(TapUpDetails details) {
    final box = _scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final trackHeight = _trackHeight;
    final dy = (local.dy - widget.style.padding.top).clamp(0.0, trackHeight);
    final thumbH = _calcThumbHeight(trackHeight);
    final usable = trackHeight - thumbH;

    if (widget.nodes.isNotEmpty && _tickFade.value > 0.5) {
      for (int i = 0; i < widget.nodes.length; i++) {
        final nodeRatio = _getNodeRatio(i);
        final nodeY = usable * nodeRatio + thumbH / 2;
        if ((dy - nodeY).abs() <= widget.nodeTapTolerance) {
          if (widget.controller.hasClients) {
            widget.controller.animateTo(
              _nodeToActualOffset(i),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          return;
        }
      }
    }

    if (widget.tapTrackToScroll && widget.controller.hasClients && usable > 0) {
      final targetThumbTop = (dy - thumbH / 2).clamp(0.0, usable);
      final yRatio = targetThumbTop / usable;
      final targetOffset = _yRatioToOffset(yRatio);
      widget.controller.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  Widget _buildDefaultThumb(double thumbHeight) {
    return Container(
      decoration: BoxDecoration(
        color: _isDragging
            ? widget.style.thumbDraggingColor
            : widget.style.thumbColor,
        borderRadius: widget.style.thumbRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNodes = widget.nodes.isNotEmpty;
    final maxTickLen = hasNodes
        ? (widget.nodes.any((n) => n.isMajor)
            ? widget.style.majorTickLength
            : widget.style.minorTickLength)
        : 0.0;
    final labelWidth =
        (hasNodes && widget.style.labelStyle != null) ? 36.0 : 0.0;
    final visualWidth = widget.style.thumbWidth +
        (hasNodes ? (maxTickLen + labelWidth) : 0.0) +
        widget.style.padding.horizontal;

    final scrollbarWidth = (widget.style.hitTestWidth != null)
        ? widget.style.hitTestWidth!.clamp(
            widget.style.thumbWidth + widget.style.padding.horizontal,
            double.infinity)
        : visualWidth;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification ||
                notification is ScrollEndNotification ||
                notification is OverscrollNotification) {
              _updateFromMetrics(notification.metrics);
              _showThumb();
            }
            return false;
          },
          child: widget.child,
        ),

        // Scrollbar (Track + Thumb)
        Positioned(
          top: widget.scrollbarMarginTop,
          bottom: widget.scrollbarMarginBottom,
          right: widget.scrollbarMarginEnd,
          width: scrollbarWidth,
          child: GestureDetector(
            key: _scrollbarKey,
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onVerticalDragCancel: _onDragEnd,
            onTapDown: (details) {
              _lastLocalPosition = details.localPosition;
              widget.onInteraction?.call(
                  YScrollbarInteractionState.down, details.localPosition);
            },
            onTapUp: (details) {
              _lastLocalPosition = details.localPosition;
              _onTapUp(details);
              widget.onInteraction
                  ?.call(YScrollbarInteractionState.up, details.localPosition);
            },
            onTapCancel: () => widget.onInteraction
                ?.call(YScrollbarInteractionState.up, _lastLocalPosition),
            child: LayoutBuilder(
              builder: (context, constraints) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      _maxScrollExtent == 0 &&
                      widget.controller.hasClients) {
                    _syncExtents();
                  }
                });

                final trackHeight = constraints.maxHeight;
                final thumbH = _calcThumbHeight(trackHeight);
                final ratio = _offsetToYRatio(_currentOffset);
                final thumbTop = widget.style.padding.top +
                    (trackHeight - widget.style.padding.vertical - thumbH) *
                        ratio;
                final bool showLabels =
                    widget.nodeLabelBuilder != null && widget.nodes.isNotEmpty;

                _painter.thumbHeight = thumbH;

                return AnimatedBuilder(
                  animation: Listenable.merge([_tickFade, _thumbFade]),
                  builder: (context, child) {
                    final tickOpacity = _tickFade.value;
                    final thumbOpacity = _thumbFade.value;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 画笔绘制 Track 和 Ticks
                        RepaintBoundary(
                          child: CustomPaint(
                            painter: _painter,
                            size: Size(scrollbarWidth, trackHeight),
                          ),
                        ),

                        // 自定义节点标签（如果有）
                        if (showLabels && tickOpacity > 0)
                          ...List.generate(widget.nodes.length, (i) {
                            final node = widget.nodes[i];
                            final nodeRatio = _getNodeRatio(i);
                            final usable = trackHeight -
                                widget.style.padding.vertical -
                                thumbH;
                            final nodeY = usable * nodeRatio + thumbH / 2;

                            return Positioned(
                              right:
                                  maxTickLen + widget.style.padding.right + 4,
                              top: widget.style.padding.top + nodeY - 100,
                              height: 200,
                              child: Opacity(
                                opacity: tickOpacity,
                                child: Center(
                                  child: widget.nodeLabelBuilder!(
                                      context, node, i),
                                ),
                              ),
                            );
                          }),

                        // 拖拽滑块 (Thumb) 转换为纯 Widget 支持自定义
                        if (thumbOpacity > 0)
                          Positioned(
                            top: thumbTop,
                            right: widget.style.padding.right,
                            width: widget.style.thumbWidth,
                            height: thumbH,
                            child: Opacity(
                              opacity: thumbOpacity,
                              child: widget.thumbBuilder != null
                                  ? widget.thumbBuilder!(
                                      context, thumbH, _isDragging)
                                  : _buildDefaultThumb(thumbH),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),

        // 左侧浮动提示（仅拖拽时可见）
        if (widget.showHintOnDrag)
          AnimatedBuilder(
            animation: _hintFade,
            builder: (context, child) {
              return Positioned(
                right: widget.scrollbarMarginEnd + scrollbarWidth + 4,
                top: widget.scrollbarMarginTop,
                bottom: widget.scrollbarMarginBottom,
                child: IgnorePointer(
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
            child: widget.hintBuilder != null
                ? widget.hintBuilder!(context, _nearestNode, _currentOffset)
                : YScrollbarDefaultHint(
                    nearestNode: _nearestNode,
                    currentOffset: _currentOffset,
                  ),
          ),
      ],
    );
  }
}
