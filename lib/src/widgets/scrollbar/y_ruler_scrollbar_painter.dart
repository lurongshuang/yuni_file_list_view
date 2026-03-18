import 'package:flutter/widgets.dart';
import 'y_ruler_scrollbar_node.dart';
import 'y_ruler_scrollbar_style.dart';

/// YRulerScrollbar 的自绘画笔。
/// 这里仅负责绘制 Track 和 Ticks。Thumb 由 Widget 树负责渲染，以便支持自定义。
class YRulerScrollbarPainter extends ChangeNotifier implements CustomPainter {
  YRulerScrollbarPainter({
    required double maxScrollExtent,
    required double thumbHeight,
    required List<YRulerScrollbarNode> nodes,
    required YRulerScrollbarStyle style,
    double tickOpacity = 0.0,
    this.extentRatioBuilder,
    this.hasCustomNodeLabelBuilder = false,
  })  : _maxScrollExtent = maxScrollExtent,
        _thumbHeight = thumbHeight,
        _nodes = nodes,
        _style = style,
        _tickOpacity = tickOpacity;

  double _maxScrollExtent;
  double _thumbHeight;
  List<YRulerScrollbarNode> _nodes;
  YRulerScrollbarStyle _style;
  double _tickOpacity;

  double Function(YRulerScrollbarNode node, int index)? extentRatioBuilder;
  bool hasCustomNodeLabelBuilder;

  set maxScrollExtent(double v) {
    if (_maxScrollExtent == v) return;
    _maxScrollExtent = v;
    notifyListeners();
  }

  set thumbHeight(double v) {
    if (_thumbHeight == v) return;
    _thumbHeight = v;
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

  set tickOpacity(double v) {
    if (_tickOpacity == v) return;
    _tickOpacity = v;
    notifyListeners();
  }

  double _getNodeRatio(int index) {
    if (_nodes.isEmpty) return 0.0;
    if (extentRatioBuilder != null) {
      return extentRatioBuilder!(_nodes[index], index).clamp(0.0, 1.0);
    }
    if (_nodes.length > 1) {
      return index / (_nodes.length - 1);
    }
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = _style.padding.top;
    final trackHeight =
        (size.height - _style.padding.vertical).clamp(0.0, size.height);

    if (_style.hitTestBackgroundColor.a > 0) {
      canvas.drawRect(
          Offset.zero & size, Paint()..color = _style.hitTestBackgroundColor);
    }

    final visualWidth = size.width - _style.padding.horizontal;
    final trackWidth =
        (_style.trackWidth ?? visualWidth).clamp(0.0, size.width);
    final contentLeft = size.width - _style.padding.right - trackWidth;

    // 1. 绘制轨道
    if (_style.showTrack) {
      final trackRect =
          Rect.fromLTWH(contentLeft, trackTop, trackWidth, trackHeight);
      canvas.drawRect(trackRect, Paint()..color = _style.trackColor);
      canvas.drawLine(
        Offset(contentLeft, trackTop),
        Offset(contentLeft, trackTop + trackHeight),
        Paint()
          ..color = _style.trackBorderColor
          ..strokeWidth = 0.5,
      );
    }

    final thumbLeft = size.width - _style.padding.right - _style.thumbWidth;
    final usable = trackHeight - _thumbHeight;

    // 2. 绘制刻度线
    if (_nodes.isNotEmpty && _tickOpacity > 0.001) {
      final baseTickColor = _style.tickColor;
      final tickAlpha = (baseTickColor.a * _tickOpacity).clamp(0.0, 1.0);
      final tickColor = baseTickColor.withValues(alpha: tickAlpha);

      final tickPaint = Paint()
        ..color = tickColor
        ..strokeWidth = _style.tickStrokeWidth;

      for (int i = 0; i < _nodes.length; i++) {
        final node = _nodes[i];
        final ratio = _getNodeRatio(i);
        final y = trackTop + usable * ratio + _thumbHeight / 2;
        final tickLen =
            node.isMajor ? _style.majorTickLength : _style.minorTickLength;

        canvas.drawLine(
          Offset(thumbLeft - tickLen, y),
          Offset(thumbLeft, y),
          tickPaint,
        );

        if (!hasCustomNodeLabelBuilder &&
            _style.labelStyle != null &&
            node.isMajor) {
          final labelStyle = _style.labelStyle!.copyWith(
            color: (_style.labelStyle!.color ?? const Color(0xFF000000))
                .withValues(alpha: _tickOpacity),
          );
          final tp = TextPainter(
            text: TextSpan(text: node.label, style: labelStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(thumbLeft - tickLen - tp.width - 3, y - tp.height / 2),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant YRulerScrollbarPainter old) {
    return old._maxScrollExtent != _maxScrollExtent ||
        old._thumbHeight != _thumbHeight ||
        old._nodes != _nodes ||
        old._style != _style ||
        old._tickOpacity != _tickOpacity;
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
