# yuni_file_list_view

[![pub package](https://img.shields.io/pub/v/yuni_file_list_view.svg)](https://pub.dev/packages/yuni_file_list_view)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

一个极为强悍、高性能且高度可定制的 Flutter 文件/媒体列表组件库。

`yuni_file_list_view` 旨在完全接管各类应用中的“文件管理”、“图库相册”、“文档归档”等流式列表展示场景。它内置了原生级别极简的 1D 数据展平（Data Flattening）引擎，通过**单一 `SliverList`** 便能支持按日/月/年等动辄数百个**复杂分组**及**动态网格**的渲染。**面对千万级别条目也绝不掉帧、完美支持懒加载**！

此外，它还配备了非侵入式的“**相册级长按滑动多选交互层 (Drag-Select Interaction)**”，为您开箱即用地带来超越系统级画廊的滑动选取体验。

---

## 核心特性 🔥

* 🚀 **极速渲染架构**：告别市面上常见的“一组一个 SliverGrid / SliverList”的灾难级坑点。针对分组宫格场景，本库内置展平算法，千组万级数据最后均被转换为一行行高度统一的 1D Row 渲染，真正发挥 Flutter 懒加载的威力。
* 📱 **三种主流视图解耦呈现**：支持纯宫格 (Grid)、纯纵向列表 (List)、以及支持动态混排切换的 分组列表 (Grouped)。
* 💻 **桌面端专属组件**：提供桌面端优化的文件列表和网格组件，支持桌面端特有的选择交互和布局。
* ☑️ **相册级高级交互接管**：内置 `YDragSelectRegion` 和 `YDragSelectElement`。套上它们，你的照片墙或文件列表瞬间获得“长按后手指不仅起，继续滑动直接疯狂多选，滑出版面自动上下滚”的高级体验。而且利用 `ValueNotifier` 定点刷新包裹，全选万张图也丝滑不掉帧。
* 🎨 **无侵入的纯粹骨架**：配置项（Config）彻底剔除色彩、形状等强 UI 属性（只留必要的 padding & spacing 布局要素）。每一格的卡片、每一条分隔线完全向用户开放 required Builder 权限，真正做到“框架做性能与骨架，皮肤交给你”。
* 📏 **智能响应式列数**：内置 `SliverLayoutBuilder` 自动监听容器宽度。配合最小单元横宽 (`minItemWidth`)，组件自动在手机/平板/桌面端算出最佳横向展示列数，完美支持转屏与分屏。

---

## 安装使用

在你的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  yuni_file_list_view: ^0.0.8
```

导入核心包：

```dart
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
```

---

## 核心组件与使用场景

### 1. 全能分组列表 `YFileGroupedListView` & `SliverYFileGroupedList`
**适用场景**：仿微信相册按日/月归档、文档管理中按文件来源/时间/格式建立文件夹树进行多轨展现。

支持在初始化或动态切换中无缝修改 `config.mode`（`YFileGroupedMode.grid` 与 `YFileGroupedMode.list`）。

> 💡 **最佳性能指南**：如果整个页面不止这个列表，建议不要直接使用 `YFileGroupedListView`（因为它自带 ScrollView），而是直接在你的 `CustomScrollView > slivers` 阵列里放置 `SliverYFileGroupedList` 组件！它内部集成了宽度检测，能自动适配网格列数。

```dart
// 在 CustomScrollView 中使用标准 Sliver 组件
CustomScrollView(
  slivers: [
    SliverYFileGroupedList<MyFileData>(
      groups: myGroups, // List<YFileGroup<MyFileData>>
      config: YFileGroupedConfig(
        mode: YFileGroupedMode.grid, // 随时动态 setState 切换为 list 模式
        gridConfig: YFileGridConfig(
          // crossAxisCount: 4,      // 可选：固定列数
          minItemWidth: 100,         // 推荐：启用自适应宽度推算
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
          childAspectRatio: 1.0,
        ),
      ),
      // 必须亲自指派分组标题的外观
      headerBuilder: (context, group, groupIndex) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text(group.groupTitle),
        );
      },
      // 必须亲自指派每一格内视图（根据是 list 还是 grid mode 灵活发挥）
      itemBuilder: (context, group, item, groupIndex, itemIndex) {
        return Image.network(item.url, fit: BoxFit.cover);
      },
    ),
  ],
)
```

### 2. 长按拖拽滑动极速多选 `YDragSelectRegion`
**适用场景**：批量整理文件、相册图库勾选功能。用户点下第一张不要抬手直接滑出去，所到之处皆为选中/反选！

将整个 `CustomScrollView` (或是你的滚动容器) 套在 `YDragSelectRegion` 中，并在底层单个数据块外侧包裹 `YDragSelectElement`（带上独一无二的 index 标识），让 Region 去进行非相交手势命中运算。

```dart
YDragSelectRegion(
  scrollController: _scrollController,
  // 拖转开始：告诉你按下了哪个 index 的元素，并且你要在此刻决定是【想选中它们】还是【想取消它们】！
  onDragSelectStart: (index) {
    // 拍摄被按下时当前已选择哪些的快照，然后开始操作...
  },
  // 滑动过程中高频触发：会告诉你最初按下的 start index 和目前滑到的 current index
  onDragSelectUpdate: (startIndex, currentIndex) {
    // 算法自动在内部补全从 start 跨越到 current 之间的所有实体序号，
    // 利用 Set 去重并剔除多余部分以实现“滑回来就取消框选”的优秀抵消感。
  },
  child: CustomScrollView(
    controller: _scrollController,
    slivers: [
      SliverYFileGroupedList<MyFileData>(
        // ...
        itemBuilder: (context, group, item, groupIndex, itemIndex) {
          int globalIndex = calculateGlobalIndex(); // 把组序化为贯通全盘的一维序号
          return YDragSelectElement(
            index: globalIndex, // 这个 index 就是 Region 运算并吐回给你的锚点依据！
            // 这里为了极致省性能，建议再包一层你们自己的局部 ValueNotifier 重绘组件！
            child: MyAssetCard(item), 
          );
        },
      )
    ]
  )
)
```

### 3. 普通非分组宫格/列表 `YFileGridView` & `YFileListView`
**适用场景**：全局只有一个简单的大展板、检索结果详情列表。

参数极简，且同样拥有无缝嵌入 Sliver 系统的原生 `buildSliverYFileGridView()` 和 `buildSliverYFileListView()` 函数。两者皆基于 `index` 回抛。

```dart
// 示例：一个根据屏幕宽度自动排列列数的云盘文件板
YFileGridView<MyFileData>(
  items: searchResults,
  config: YFileGridConfig(
    crossAxisCount: 0, // 🔥 灵魂设置 0，代表开启自动宽度推算
    minItemWidth: 120, // 当设定每块最小宽 120 像素时，若屏幕宽得足以放4块就出4快，宽得够放10块就出10块
    padding: EdgeInsets.symmetric(horizontal: 16),
  ),
  itemBuilder: (context, item, index) {
    return FilePanelCard(item: item);
  },
)
```

### 4. 桌面端专属组件
**适用场景**：桌面应用中的文件管理、媒体浏览等场景，提供符合桌面端操作习惯的交互体验。

#### 4.1 桌面端文件列表 `YDesktopFileListView`
```dart
YDesktopFileListView<MyFileData>(
  items: files,
  onItemTap: (item, index) {
    // 处理点击事件
  },
  onItemSecondaryTap: (item, index) {
    // 处理右键点击事件
  },
  itemBuilder: (context, item, index, selected) {
    return YDesktopFileItem(
      item: item,
      selected: selected,
      onTap: () => handleTap(item),
    );
  },
)
```

#### 4.2 桌面端文件网格 `YDesktopFileGridView`
```dart
YDesktopFileGridView<MyFileData>(
  items: files,
  config: YFileGridConfig(
    minItemWidth: 150,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemBuilder: (context, item, index, selected) {
    return FileGridItem(
      item: item,
      selected: selected,
    );
  },
)
```

#### 4.3 桌面端分组视图 `YDesktopGroupedView` & `YDesktopGroupedGridView`
```dart
YDesktopGroupedView<MyFileData>(
  groups: groups,
  headerBuilder: (context, group, groupIndex) {
    return YDesktopFileHeader(title: group.groupTitle);
  },
  itemBuilder: (context, group, item, groupIndex, itemIndex, selected) {
    return YDesktopFileItem(
      item: item,
      selected: selected,
    );
  },
)
```

### 4. 业务级刻度滚动条 `YRulerScrollbar`
**适用场景**：仿系统相册、大型文件库。不仅提供基础滚动，还支持带有“年份/类别”节点的侧边刻度尺，支持点击跳转和拖拽预览。

```dart
YRulerScrollbar(
  controller: _scrollController,
  nodes: myYearGroups, // 直接传入你的分组列表
  // 必须：告诉组件每个节点在大列表中的位置占比 (0.0~1.0)
  extentRatioBuilder: (node, index) => calculateRatio(index),
  // 可选：自定义刻度标签预览 Widget
  nodeLabelBuilder: (context, node, index) => Text(node.label),
  // 可选：设置滑块始终可见（默认 false）
  thumbVisibility: true,
  // 可选：提示内容切换回调（可用于触发震动反馈）
  onHintChanged: (node) => HapticFeedback.lightImpact(),
  // 可选：滑块淡入时长（默认 100ms，建议快）
  fadeInDuration: const Duration(milliseconds: 100),
  // 可选：滑块淡出时长（默认 300ms，建议慢）
  fadeOutDuration: const Duration(milliseconds: 300),
  // 可选：停止滑动后，开始执行淡出的延迟等待时长（默认 600ms）
  timeToFade: const Duration(milliseconds: 800),
  // 可选：轨道边距，用于避开顶部自定义 AppBar
  scrollbarMarginTop: 100,
  style: YRulerScrollbarStyle(
    thumbColor: Colors.blue.withValues(alpha: 0.5),
    thumbWidth: 4,
    showTrack: false,
  ),
  child: CustomScrollView(
    controller: _scrollController,
    slivers: [ /* ... */ ],
  ),
)
```


### 5. 桌面端选择控制器 `YDesktopSelectionController`
**适用场景**：桌面端应用中需要复杂选择逻辑的场景，如批量操作文件、多选编辑等。

```dart
final selectionController = YDesktopSelectionController<MyFileData>();

// 在组件中使用
YDesktopSelectionRegion<MyFileData>(
  controller: selectionController,
  child: YDesktopFileListView(
    items: files,
    selectedItems: selectionController.selectedItems,
    onItemTap: (item, index) {
      selectionController.toggleSelection(item);
    },
    // ...
  ),
)

// 批量操作
ElevatedButton(
  onPressed: () {
    final selected = selectionController.selectedItems;
    // 处理选中的项目
  },
  child: Text('处理选中项目'),
)
```

---

在这个组件被发掘出“终极大一统展平防挂载 SliverList”算法之前，大列表中调用 `setState` 会导致所有渲染子对象全部自毁并触发无尽的重建与越界计算。

使用本库进行上万+图片多选时，**切记千万不要** 在 `onDragSelectUpdate` 里面触发全局大页面的 `setState`。
本库在 `Example` 工程的 `PhotoGalleryDemoPage` 中为您预留了神仙级别的标准范例解答，它不仅包含了 **O(1) 级别的吸顶索引检索算法**，核心还包括两点：
1. **数据与坐标分离计算体系**。
2. **`_SelectionStatusWrapper` 配合 `ValueNotifier` 进行 `O(1)` 的局部精确更新**，它确保如果你的手指滑过 100 张图时，引擎只给这状态发生改变的 100 张图片重上油漆，其余一万张图连理都不理你。

详细可移步仓库内的 [example 文件夹查看演示](https://github.com/yuni/yuni_file_list_view/tree/main/example/lib/pages/photo_gallery_demo_page.dart)。

---

## License

本组件采用 MIT 许可授权协议。
