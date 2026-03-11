/// YRulerScrollbar 尺子上的一个刻度节点接口。
///
/// 业务方可以直接让真实的数据列表元素（如 `GroupData` 或 `ItemData`）
/// 实现此接口，从而避免专门为 Scrollbar 提取甚至重组一份独立的数据。
///
/// 组件底层在渲染时，会通过回调向业务方索取当前元素在总高度/总条目中的百分比位置。
///
/// **示例：业务数据模型直接实现该接口**
/// ```dart
/// class MyDataGroup implements YRulerScrollbarNode {
///   final String date;
///   final List<Photo> photos;
///
///   @override
///   String get label => date;
///
///   @override
///   bool get isMajor => true;
/// }
/// ```
abstract class YRulerScrollbarNode {
  /// 在刻度线旁或左侧/底部提示中展示的文字，如 "2023" 或 "3月"
  String get label;

  /// true = 主节点（较长刻度线 + 粗笔画），false = 辅节点（较短刻度线）。
  bool get isMajor;
}

/// 默认的实现类，方便简单场景下直接创建独立节点。
class YRulerScrollbarDefaultNode implements YRulerScrollbarNode {
  @override
  final String label;

  @override
  final bool isMajor;

  const YRulerScrollbarDefaultNode({
    required this.label,
    this.isMajor = false,
  });

  @override
  String toString() =>
      'YRulerScrollbarDefaultNode(label: $label, major: $isMajor)';
}
