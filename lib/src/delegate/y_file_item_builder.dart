import 'package:flutter/widgets.dart';
import '../model/y_file_group.dart';

// ─────────────────────── 宫格 Builder ──────────────────────────────

/// 宫格单元格自定义构建器
///
/// - [context]：当前 BuildContext
/// - [item]：当前文件数据
/// - [index]：在列表中的索引
typedef YFileGridItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

// ─────────────────────── 纵向列表 Builder ──────────────────────────

/// 纵向列表单元格自定义构建器
typedef YFileListItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
);

/// 纵向列表分割线构建器
typedef YFileListSeparatorBuilder = Widget Function(
  BuildContext context,
  int index,
);

// ─────────────────────── 分组列表 Builder ──────────────────────────

/// 分组 Header 自定义构建器
///
/// - [group]：当前分组数据
/// - [groupIndex]：分组在列表中的索引
typedef YFileGroupHeaderBuilder<T> = Widget Function(
  BuildContext context,
  YFileGroup<T> group,
  int groupIndex,
);

/// 分组内单元格自定义构建器（优先级高于 [YFileGridItemBuilder]）
typedef YFileGroupItemBuilder<T> = Widget Function(
  BuildContext context,
  YFileGroup<T> group,
  T item,
  int groupIndex,
  int itemIndex,
);
