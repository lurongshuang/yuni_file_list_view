## 0.0.8

* 🎯 **YRulerScrollbar — 新增 `scrollbarMarginTop` / `scrollbarMarginBottom`**：支持设定轨道的上下边距，常用于避开 `SliverAppBar` 等顶部悬浮元素，让滚动条视觉区域更精准。左侧浮动 Hint 面板同步跟随偏移，不再出现上下错位。
* 🐛 **修复 YRulerScrollbar 拖拽时 Thumb 上下跳动问题**：在 `_onDragStart` 时快照 `_dragMaxScrollExtent`，拖拽期间 `_dyToOffset` 始终使用该冻结值计算目标位置，彻底打断因 `SliverGrid` 懒加载布局造成的 `maxScrollExtent` 振荡 → `jumpTo` 振荡的正反馈闭环。
* 🏗 **YRulerScrollbar 改用 `NotificationListener` 接收滚动数据**：与 Flutter 官方 `RawScrollbar` 保持完全相同的数据获取方式，利用 `ScrollMetrics` 一致性快照（`pixels / maxScrollExtent / viewportDimension` 同帧写入），消除 `controller.addListener` 事后读取导致三值不一致的潜在抖动。
* ✨ **YRulerScrollbar 新增 `nodeLabelBuilder`**：可完全自定义每个刻度节点的标签 Widget，替代内部 Canvas 默认文本绘制。
* 🔧 **移除已无意义的 `bottomHintBuilder`**：重新设计底部提示区域为通用 Hint 系统，保持 API 简洁。

## 0.0.1


* 🚀 **Initial Release**: `yuni_file_list_view` is an ultra-high performance Flutter UI package for flexible file and photo gallery layouts.
* ✨ **Three Core Modes**: Provides `YFileGridView`, `YFileListView`, and `YFileGroupedListView` as well as their `Sliver` equivalents.
* ⚡️ **Ultimate 1D Flattening Matrix**: A revolutionary implementation of Grouped Grid combining millions of items without freezing the engine nor introducing `SliverGrid` allocations per group. Fully preserves Lazy-Loading.
* 📦 **Unopinionated Builders**: Pure configuration (paddings, spacings, crossAxisCount) without dictating UI constraints (colors, cards). Every shape is completely passed through required `Builder`s.
* ✋ **Drag-Select Non-intrusive Layer**: Added `YDragSelectRegion` and `YDragSelectElement` to bring zero-cost "Drag to Multi-Select & Auto-Scroll" interaction to any list, out-of-the-box.
