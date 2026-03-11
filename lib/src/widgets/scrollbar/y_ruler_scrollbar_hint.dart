import 'package:flutter/widgets.dart';
import 'y_ruler_scrollbar_node.dart';

/// Scrollbar 左侧浮动提示的构建回调。
///
/// 参数：
/// - [context]：Build 上下文
/// - [nearestNode]：当前滚动位置最近的节点（可为 null 表示没有节点）
/// - [currentOffset]：当前精确的滚动偏移量（像素）
///
/// 返回值是任意 Widget，将被放置在 Scrollbar 左侧并跟随 thumb 对齐。
///
/// **示例：显示年月日期提示**
/// ```dart
/// hintBuilder: (context, node, offset) {
///   return Container(
///     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
///     decoration: BoxDecoration(
///       color: Colors.black87,
///       borderRadius: BorderRadius.circular(8),
///     ),
///     child: Text(
///       node?.label ?? '',
///       style: const TextStyle(color: Colors.white, fontSize: 13),
///     ),
///   );
/// },
/// ```
typedef YScrollbarHintBuilder = Widget Function(
  BuildContext context,
  YRulerScrollbarNode? nearestNode,
  double currentOffset,
);

/// YRulerScrollbar 内置的默认左侧提示 Widget。
///
/// 使用半透明深色背景 + 白色文字的胶囊样式。
class YScrollbarDefaultHint extends StatelessWidget {
  final YRulerScrollbarNode? nearestNode;
  final double currentOffset;

  const YScrollbarDefaultHint({
    super.key,
    required this.nearestNode,
    required this.currentOffset,
  });

  @override
  Widget build(BuildContext context) {
    final label = nearestNode?.label ?? '';
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xCC000000),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(-2, 2),
          )
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
