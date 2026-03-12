import 'package:flutter/widgets.dart';
import 'y_ruler_scrollbar_node.dart';
import 'y_ruler_scrollbar_style.dart';

/// YRulerScrollbar 的自绘画笔。
///
/// 负责在画布上绘制：
/// 1. Track 背景（可选）
/// 2. Thumb（滑块），高度受 min/max 约束，位置和 scrollOffset 线性对应
/// 3. 刻度节点（主节点用较长线，辅节点用较短线）+ 可选标签
///    - [tickOpacity] 为 0 时完全不绘制刻度，为 1 时完全可见
///    - 由外部 AnimationController 驱动实现拖拽淡入/松手淡出
class YRulerScrollbarPainter extends ChangeNotifier
    implements CustomPainter {
  YRulerScrollbarPainter({
    required double scrollOffset,
    required double maxScrollExtent,
    required double viewportExtent,
    required bool isDragging,
    required List<YRulerScrollbarNode> nodes,
    required YRulerScrollbarStyle style,
    double tickOpacity = 0.0,
    double thumbOpacity = 1.0,
    this.extentRatioBuilder,
    this.hasCustomNodeLabelBuilder = false,
  })  : _scrollOffset = scrollOffset,
        _maxScrollExtent = maxScrollExtent,
        _viewportExtent = viewportExtent,
        _isDragging = isDragging,
        _nodes = nodes,
        _style = style,
        _tickOpacity = tickOpacity,
        _thumbOpacity = thumbOpacity;

  double _scrollOffset;
  double _maxScrollExtent;
  double _viewportExtent;
  bool _isDragging;
  List<YRulerScrollbarNode> _nodes;
  YRulerScrollbarStyle _style;

  /// 用于动态获取 node 位置比例的回调
  /// 范围 0.0 ~ 1.0
  final double Function(YRulerScrollbarNode node, int index)? extentRatioBuilder;

  /// 是否启用了外部自定义的节点组件。如果启用，Painter 就不再绘制文字。
  bool hasCustomNodeLabelBuilder;

  /// 刻度线和标签的整体不透明度（0.0 = 不可见，1.0 = 完全可见）。
  /// 由外部动画驱动，无需在此触发 notifyListeners（调用方负责刷新）。
  double _tickOpacity;

  /// 滑块不透明度
  double _thumbOpacity;

  // ─── setters，外部更新后调用 notifyListeners ─────────────────────────────

  set scrollOffset(double v) {
    if (_scrollOffset == v) return;
    _scrollOffset = v;
    notifyListeners();
  }

  set maxScrollExtent(double v) {
    if (_maxScrollExtent == v) return;
    _maxScrollExtent = v;
    notifyListeners();
  }

  set viewportExtent(double v) {
    if (_viewportExtent == v) return;
    _viewportExtent = v;
    notifyListeners();
  }

  set isDragging(bool v) {
    if (_isDragging == v) return;
    _isDragging = v;
    notifyListeners();
  }

  set nodes(List<YRulerScrollbarNode> v) {
    _nodes = v;
    notifyListeners();
  }

  set style(YRulerScrollbarStyle v) {
    _style = v;
    notifyListeners();
  }

  /// 由动画回调直接更新，不触发 notifyListeners（动画帧已触发 repaint）
  set tickOpacity(double v) {
    _tickOpacity = v;
  }

  set thumbOpacity(double v) {
    _thumbOpacity = v;
  }

  // ─── 计算 Thumb 位置和高度 ────────────────────────────────────────────────

  /// 计算 Thumb 在轨道上的顶部偏移量和高度（都为像素）
  ({double top, double height}) _calcThumb(double trackHeight) {
    final total = _viewportExtent + _maxScrollExtent;
    if (total <= 0 || _maxScrollExtent <= 0) {
      return (top: 0, height: trackHeight);
    }

    final visibleRatio = _viewportExtent / total;
    final rawHeight = trackHeight * visibleRatio;
    final thumbH = rawHeight.clamp(
      _style.thumbMinHeight,
      _style.thumbMaxHeight == double.infinity
          ? trackHeight
          : _style.thumbMaxHeight,
    );

    final usable = trackHeight - thumbH;
    final thumbTop = usable > 0
        ? usable * (_scrollOffset / _maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;

    return (top: thumbTop, height: thumbH);
  }

  /// 将节点的 scrollOffset 映射到轨道上的 Y 坐标（对应 thumb 中心位置）
  double _nodeToY(
      double nodeOffset, double trackHeight, double thumbHeight) {
    if (_maxScrollExtent <= 0) return 0;
    final usable = trackHeight - thumbHeight;
    return usable * (nodeOffset / _maxScrollExtent).clamp(0.0, 1.0) +
        thumbHeight / 2;
  }

  // ─── CustomPainter ────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = _style.padding.top;
    final trackHeight =
        (size.height - _style.padding.vertical).clamp(0.0, size.height);
    final trackWidth =
        (size.width - _style.padding.horizontal).clamp(0.0, size.width);

    // 1. Track 背景（始终可见，不受 tickOpacity 影响）
    if (_style.showTrack) {
      final trackRect = Rect.fromLTWH(
        _style.padding.left,
        trackTop,
        trackWidth,
        trackHeight,
      );
      canvas.drawRect(trackRect, Paint()..color = _style.trackColor);
      canvas.drawLine(
        Offset(_style.padding.left, trackTop),
        Offset(_style.padding.left, trackTop + trackHeight),
        Paint()
          ..color = _style.trackBorderColor
          ..strokeWidth = 0.5,
      );
    }

    final thumb = _calcThumb(trackHeight);
    // thumb 绘制在 painter 宽度的最右侧（padding.right 留边）
    final thumbLeft = size.width - _style.padding.right - _style.thumbWidth;

    // 2. 刻度线（受 tickOpacity 控制，opacity=0 时跳过绘制节省性能）
    if (_nodes.isNotEmpty && _tickOpacity > 0.001) {
      final baseTickColor = _style.tickColor;
      final tickAlpha = (baseTickColor.alpha * _tickOpacity).toInt();
      final tickColor = baseTickColor.withAlpha(tickAlpha);

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = _style.tickStrokeWidth;

      for (int i = 0; i < _nodes.length; i++) {
        final node = _nodes[i];
        
        // 解析比例
        double ratio = 0.0;
        if (extentRatioBuilder != null) {
          ratio = extentRatioBuilder!(node, i).clamp(0.0, 1.0);
        } else if (_nodes.length > 1) {
          ratio = i / (_nodes.length - 1);
        }
        
        final nodeScrollOffset = ratio * _maxScrollExtent;
        final y = trackTop +
            _nodeToY(nodeScrollOffset, trackHeight, thumb.height);
        final tickLen =
            node.isMajor ? _style.majorTickLength : _style.minorTickLength;

        // 刻度线从 thumb 左边向左延伸
        canvas.drawLine(
          Offset(thumbLeft - tickLen, y),
          Offset(thumbLeft, y),
          tickPaint,
        );

        // 标签（主节点才绘制，绘制在刻度线左侧）
        // 仅当没有自定义构建器，并且提供了样式时才绘制文字
        if (!hasCustomNodeLabelBuilder && _style.labelStyle != null && node.isMajor) {
          final labelAlpha = (_tickOpacity * 255).clamp(0.0, 255.0).toInt();
          final labelStyle = _style.labelStyle!.copyWith(
            color: (_style.labelStyle!.color ?? const Color(0xFF000000))
                .withAlpha(labelAlpha),
          );
          final tp = TextPainter(
            text: TextSpan(text: node.label, style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(
              thumbLeft - tickLen - tp.width - 3,
              y - tp.height / 2,
            ),
          );
        }
      }
    }

    // 3. Thumb（受 thumbOpacity 控制）
    if (_thumbOpacity <= 0.001) return;

    final baseThumbColor =
        _isDragging ? _style.thumbDraggingColor : _style.thumbColor;
    final thumbAlpha = (baseThumbColor.alpha * _thumbOpacity).toInt();
    final thumbColor = baseThumbColor.withAlpha(thumbAlpha);

    final thumbRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        thumbLeft,
        trackTop + thumb.top,
        _style.thumbWidth,
        thumb.height,
      ),
      topLeft: _style.thumbRadius.topLeft,
      topRight: _style.thumbRadius.topRight,
      bottomLeft: _style.thumbRadius.bottomLeft,
      bottomRight: _style.thumbRadius.bottomRight,
    );
    canvas.drawRRect(thumbRect, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(covariant YRulerScrollbarPainter old) {
    return old._scrollOffset != _scrollOffset ||
        old._maxScrollExtent != _maxScrollExtent ||
        old._viewportExtent != _viewportExtent ||
        old._isDragging != _isDragging ||
        old._nodes != _nodes ||
        old._style != _style ||
        old._tickOpacity != _tickOpacity ||
        old._thumbOpacity != _thumbOpacity;
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
