import 'package:flutter/widgets.dart';
import '../../config/y_file_grid_config.dart';
import '../../model/y_file_item.dart';
import '../../delegate/y_file_item_builder.dart';
import 'sliver_y_file_grid_view.dart';

/// 宫格文件列表（可独立滚动）
///
/// 内部使用 [CustomScrollView] + [SliverYFileGridView] 实现，
/// 当需要与其他 Sliver 组合时，请直接使用 [SliverYFileGridView]。
///
/// ```dart
/// YFileGridView<MyFile>(
///   items: myFiles,
///   config: YFileGridConfig(crossAxisCount: 0, minItemWidth: 100),
///   onTap: (file, index) => print(file.name),
/// )
/// ```
class YFileGridView<T extends YFileItem> extends StatelessWidget {
  /// 文件数据列表
  final List<T> items;

  /// 宫格配置（默认 3 列）
  final YFileGridConfig config;

  /// 自定义单元格构建器；为 null 时使用默认实现
  final YFileGridItemBuilder<T>? itemBuilder;

  /// 点击回调
  final YFileItemTapCallback<T>? onTap;

  /// 长按回调
  final YFileItemLongPressCallback<T>? onLongPress;

  /// 选中的文件 id 集合（多选模式时传入）
  final Set<String>? selectedIds;

  /// 列表滚动控制器
  final ScrollController? controller;

  /// 列表滚动方向（默认垂直）
  final Axis scrollDirection;

  /// 列表是否逆序
  final bool reverse;

  /// 列表滚动物理效果
  final ScrollPhysics? physics;

  /// 列表是否收缩包裹内容（内嵌在其他滚动容器中时设 true）
  final bool shrinkWrap;

  const YFileGridView({
    super.key,
    required this.items,
    this.config = const YFileGridConfig(),
    this.itemBuilder,
    this.onTap,
    this.onLongPress,
    this.selectedIds,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 获取可用宽度，支持动态列数计算
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          controller: controller,
          scrollDirection: scrollDirection,
          reverse: reverse,
          physics: physics,
          shrinkWrap: shrinkWrap,
          slivers: [
            buildSliverYFileGridView<T>(
              items: items,
              config: config,
              itemBuilder: itemBuilder,
              onTap: onTap,
              onLongPress: onLongPress,
              selectedIds: selectedIds,
              availableWidth: constraints.maxWidth - config.padding.horizontal,
            ),
          ],
        );
      },
    );
  }
}
