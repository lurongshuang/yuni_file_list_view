import 'y_file_item.dart';

/// 文件分组数据模型
///
/// 用于 [YFileGroupedListView] 和 [SliverYFileGroupedListView]。
///
/// ```dart
/// final groups = [
///   YFileGroup(
///     groupId: '2025-01',
///     groupTitle: '2025年1月 北京市-来广营',
///     items: [...],
///   ),
/// ];
/// ```
class YFileGroup<T extends YFileItem> {
  /// 分组唯一标识
  final String groupId;

  /// 分组展示标题，如 "2025年1月 北京市-来广营"
  final String groupTitle;

  /// 分组内文件列表
  final List<T> items;

  /// 业务自定义扩展数据（不参与组件内部逻辑）
  final Object? extra;

  const YFileGroup({
    required this.groupId,
    required this.groupTitle,
    required this.items,
    this.extra,
  });

  /// 总文件数
  int get count => items.length;

  YFileGroup<T> copyWith({
    String? groupId,
    String? groupTitle,
    List<T>? items,
    Object? extra,
  }) {
    return YFileGroup<T>(
      groupId: groupId ?? this.groupId,
      groupTitle: groupTitle ?? this.groupTitle,
      items: items ?? this.items,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YFileGroup && runtimeType == other.runtimeType && groupId == other.groupId;

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() => 'YFileGroup(groupId: $groupId, title: $groupTitle, count: $count)';
}
