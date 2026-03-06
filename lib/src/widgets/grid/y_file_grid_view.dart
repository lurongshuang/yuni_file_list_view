import 'package:flutter/widgets.dart';
import '../../config/y_file_grid_config.dart';
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
class YFileGridView<T> extends StatelessWidget {
  /// 文件数据列表
  final List<T> items;

  /// 宫格参数配置
  final YFileGridConfig config;

  /// 自定义单元格构建器（必填）
  final YFileGridItemBuilder<T> itemBuilder;

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
    required this.itemBuilder,
    this.config = const YFileGridConfig(),
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
              itemBuilder: itemBuilder,
              config: config,
              availableWidth: constraints.maxWidth - config.padding.horizontal,
            ),
          ],
        );
      },
    );
  }
}
