import 'package:flutter/widgets.dart';
import '../../config/y_file_grouped_config.dart';
import '../../model/y_file_item.dart';
import '../../model/y_file_group.dart';
import '../../delegate/y_file_item_builder.dart';
import 'sliver_y_file_grouped_list_view.dart';

/// 分组宫格文件列表（可独立滚动）
///
/// 内部使用 [CustomScrollView] + [buildSliverYFileGroupedListView] 实现。
/// 需与其他 Sliver 组合时请直接使用 [buildSliverYFileGroupedListView]。
///
/// ```dart
/// YFileGroupedListView<MyFile>(
///   groups: myGroups,
///   config: YFileGroupedConfig(pinnedHeader: true),
///   onTap: (file, i) => print(file.name),
/// )
/// ```
class YFileGroupedListView<T extends YFileItem> extends StatelessWidget {
  final List<YFileGroup<T>> groups;
  final YFileGroupedConfig config;
  final YFileGroupHeaderBuilder<T>? headerBuilder;
  final YFileGroupItemBuilder<T>? itemBuilder;
  final YFileItemTapCallback<T>? onTap;
  final YFileItemLongPressCallback<T>? onLongPress;
  final Set<String>? selectedIds;
  final ScrollController? controller;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const YFileGroupedListView({
    super.key,
    required this.groups,
    this.config = const YFileGroupedConfig(),
    this.headerBuilder,
    this.itemBuilder,
    this.onTap,
    this.onLongPress,
    this.selectedIds,
    this.controller,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          controller: controller,
          reverse: reverse,
          physics: physics,
          shrinkWrap: shrinkWrap,
          slivers: [
            ...buildSliverYFileGroupedListView<T>(
              groups: groups,
              config: config,
              headerBuilder: headerBuilder,
              itemBuilder: itemBuilder,
              selectedIds: selectedIds,
              availableWidth: constraints.maxWidth -
                  (config.mode == YFileGroupedMode.grid
                      ? config.gridConfig.padding.horizontal
                      : config.listConfig.padding.horizontal),
            ),
          ],
        );
      },
    );
  }
}
