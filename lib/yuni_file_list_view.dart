/// yuni_file_list_view
///
/// 一个可靠、可扩展的文件列表组件库，支持：
/// - 宫格列表（[YFileGridView] / [SliverYFileGridView]）
/// - 纵向普通列表（[YFileListView] / [SliverYFileListView]）
/// - 分组宫格列表（[YFileGroupedListView] / [SliverYFileGroupedListView]）
///
/// 所有组件均提供 Sliver 原子版本，可嵌入 [CustomScrollView]。
library yuni_file_list_view;

// ─── 数据模型 ────────────────────────────────────────────────────────────────
export 'src/model/y_file_group.dart';

// ─── 配置 ────────────────────────────────────────────────────────────────────
export 'src/config/y_file_grid_config.dart';
export 'src/config/y_file_list_config.dart';
export 'src/config/y_file_grouped_config.dart';

// ─── Builder 回调 ─────────────────────────────────────────────────────────────
export 'src/delegate/y_file_item_builder.dart';

// ─── 工具 ────────────────────────────────────────────────────────────────────
export 'src/utils/y_grid_column_calculator.dart';

// ─── 宫格列表 ─────────────────────────────────────────────────────────────────
export 'src/widgets/grid/sliver_y_file_grid_view.dart';
export 'src/widgets/grid/y_file_grid_view.dart';

// ─── 纵向列表 ─────────────────────────────────────────────────────────────────
export 'src/widgets/list/sliver_y_file_list_view.dart';
export 'src/widgets/list/y_file_list_view.dart';

// ─── 分组列表 ─────────────────────────────────────────────────────────────────
export 'src/widgets/grouped/sliver_y_file_grouped_list_view.dart';
export 'src/widgets/grouped/y_file_grouped_list_view.dart';

// ─── 高级交互能力 ─────────────────────────────────────────────────────────────
export 'src/widgets/interaction/y_drag_select_region.dart';
