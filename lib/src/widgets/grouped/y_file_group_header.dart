import 'package:flutter/material.dart';
import '../../config/y_file_grouped_config.dart';
import '../../model/y_file_item.dart';
import '../../model/y_file_group.dart';

/// 分组列表 Header 默认实现
///
/// 展示分组标题，背景色可通过 [config.headerBackgroundColor] 自定义。
/// 通过 [YFileGroupedListView.headerBuilder] 可完全替换此实现。
class YFileGroupHeader<T extends YFileItem> extends StatelessWidget {
  final YFileGroup<T> group;
  final int groupIndex;
  final YFileGroupedConfig config;

  const YFileGroupHeader({
    super.key,
    required this.group,
    required this.groupIndex,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 强制赋予一个有实色的底色，避免滚动时内容垫在下方导致视觉上像“没推出去而是叠加了”
    final bgColor = config.headerBackgroundColor ?? theme.scaffoldBackgroundColor;

    return Container(
      height: config.headerHeight,
      // 如果 scaffoldBackgroundColor 解析为透明，依然强制给个白底兜底
      color: bgColor == Colors.transparent ? Colors.white : bgColor,
      alignment: Alignment.centerLeft,
      padding: config.headerPadding,
      child: Text(
        group.groupTitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
