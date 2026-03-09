import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../widgets/y_file_list_item.dart';
import '../widgets/y_file_grid_item.dart';
import '../models/y_file_list_ui_config.dart';
import '../data/demo_data.dart';

class PhotoGalleryDemoPage extends StatefulWidget {
  const PhotoGalleryDemoPage({super.key});

  @override
  State<PhotoGalleryDemoPage> createState() => _PhotoGalleryDemoPageState();
}

class _PhotoGalleryDemoPageState extends State<PhotoGalleryDemoPage> {
  String _dimension = 'month';
  YFileGroupedMode _mode = YFileGroupedMode.grid;
  final Set<String> _selectedIds = {};

  // 独立控制器，保留各自滑动位置
  final ScrollController _yearScrollCtrl = ScrollController();
  final ScrollController _monthScrollCtrl = ScrollController();
  final ScrollController _dayScrollCtrl = ScrollController();

  // 缓存 3 维度的数据
  late final List<YFileGroup<YFileItem>> _yearGroups;
  late final List<YFileGroup<YFileItem>> _monthGroups;
  late final List<YFileGroup<YFileItem>> _dayGroups;

  // 全局展示集：由于不同维度的物理数量和时序一样，一套数据够了
  late final List<YFileItem> _globalFlatItems;

  late final List<int> _yearOffsets;
  late final List<int> _monthOffsets;
  late final List<int> _dayOffsets;

  Set<String> _dragStartSelectedIds = {};
  bool _isSelecting = true;

  @override
  void initState() {
    super.initState();
    _initDimensionData('year');
    _initDimensionData('month');
    _initDimensionData('day');
  }

  @override
  void dispose() {
    _yearScrollCtrl.dispose();
    _monthScrollCtrl.dispose();
    _dayScrollCtrl.dispose();
    super.dispose();
  }

  void _initDimensionData(String dim) {
    final groups = DemoData.getGroupsByDimension(dim);
    final flatItems = groups.expand((g) => g.items).toList();
    final groupOffsets = <int>[];
    int offset = 0;
    for (var g in groups) {
      groupOffsets.add(offset);
      offset += g.items.length;
    }

    if (dim == 'year') {
      _yearGroups = groups;
      _yearOffsets = groupOffsets;
      _globalFlatItems = flatItems; // 只需赋任一维度生成后的完整数组即可
    } else if (dim == 'month') {
      _monthGroups = groups;
      _monthOffsets = groupOffsets;
    } else if (dim == 'day') {
      _dayGroups = groups;
      _dayOffsets = groupOffsets;
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _changeDimension(String dim) {
    if (_dimension == dim) return;
    setState(() {
      _dimension = dim;
    });
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == YFileGroupedMode.grid
          ? YFileGroupedMode.list
          : YFileGroupedMode.grid;
    });
  }

  void _onDragSelectStart(int index) {
    if (index < 0 || index >= _globalFlatItems.length) return;
    final id = _globalFlatItems[index].id;

    _dragStartSelectedIds = Set.from(_selectedIds);
    _isSelecting = !_selectedIds.contains(id);

    setState(() {
      if (_isSelecting) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onDragSelectUpdate(int startIndex, int currentIndex) {
    if (startIndex < 0 || currentIndex < 0 || _globalFlatItems.isEmpty) return;
    if (startIndex >= _globalFlatItems.length ||
        currentIndex >= _globalFlatItems.length) {
      return;
    }

    final int minIdx = startIndex < currentIndex ? startIndex : currentIndex;
    final int maxIdx = startIndex > currentIndex ? startIndex : currentIndex;

    final Set<String> newSelection = Set.from(_dragStartSelectedIds);

    for (int i = minIdx; i <= maxIdx; i++) {
      final id = _globalFlatItems[i].id;
      if (_isSelecting) {
        newSelection.add(id);
      } else {
        newSelection.remove(id);
      }
    }

    if (newSelection.length != _selectedIds.length ||
        !newSelection.containsAll(_selectedIds)) {
      setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(newSelection);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int dimIndex = 0;
    if (_dimension == 'month') dimIndex = 1;
    if (_dimension == 'day') dimIndex = 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade50, Colors.white],
              ),
            ),
          ),
          IndexedStack(
            index: dimIndex,
            children: [
              _buildGalleryView('year', 5, _yearScrollCtrl, _yearGroups, _yearOffsets),
              _buildGalleryView('month', 4, _monthScrollCtrl, _monthGroups, _monthOffsets),
              _buildGalleryView('day', 3, _dayScrollCtrl, _dayGroups, _dayOffsets),
            ],
          ),
          Positioned(
            bottom: 84,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 52,
                    width: 280,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.black.withValues(alpha: 0.05),
                          width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDimensionBtn('年', 'year'),
                        _buildDimensionBtn('月', 'month'),
                        _buildDimensionBtn('日', 'day'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryView(
    String dim,
    int crossAxisCount,
    ScrollController scrollCtrl,
    List<YFileGroup<YFileItem>> groups,
    List<int> groupOffsets,
  ) {
    return YDragSelectRegion(
      scrollController: scrollCtrl,
      onDragSelectStart: (idx) => _onDragSelectStart(idx),
      onDragSelectUpdate: (start, current) =>
          _onDragSelectUpdate(start, current),
      child: CustomScrollView(
        key: PageStorageKey('gallery_view_$dim'),
        controller: scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                    _mode == YFileGroupedMode.grid
                        ? Icons.format_list_bulleted
                        : Icons.grid_view,
                    color: Colors.blue),
                tooltip: _mode == YFileGroupedMode.grid ? '切换至列表' : '切换至宫格',
                onPressed: _toggleMode,
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.black87),
                onPressed: () {},
              ),
            ],
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2025年春节',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: Colors.black)),
                const SizedBox(height: 2),
                Text(
                  '3012张图片  124个视频  80个其他文件',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
            floating: true,
            pinned: true,
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Row(
                children: [
                  _buildFilterChip('上传者'),
                  _buildFilterChip('点赞'),
                  _buildFilterChip('标签'),
                  _buildFilterChip('机型'),
                  const SizedBox(width: 12),
                  Icon(Icons.tune, color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
          ),
          ...buildSliverYFileGroupedListView<YFileItem>(
            groups: groups,
            config: YFileGroupedConfig(
              mode: _mode,
              pinnedHeader: true,
              groupHeaderHeight: 46,
              gridConfig: YFileGridConfig(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                padding: EdgeInsets.zero,
              ),
              listConfig: const YFileListConfig(
                padding: EdgeInsets.zero,
                itemExtent: 72,
              ),
            ),
            headerBuilder: (context, group, index) {
              return Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                color: Colors.white.withValues(alpha: 0.5),
                child: Text(
                  group.groupTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.4,
                  ),
                ),
              );
            },
            itemBuilder: (context, group, item, groupIndex, itemIndex) {
              final isSelected = _selectedIds.contains(item.id);
              int globalIndex = groupOffsets[groupIndex] + itemIndex;

              Widget child;
              if (_mode == YFileGroupedMode.grid) {
                child = YFileGridItem(
                  item: item,
                  selected: isSelected,
                  onTap: () => _toggleSelection(item.id),
                );
              } else {
                child = YFileListItem(
                  item: item,
                  config: const YFileListUIConfig(
                      showDivider: true, dividerIndent: 76),
                  selected: isSelected,
                  onTap: () => _toggleSelection(item.id),
                );
              }

              return YDragSelectElement(
                index: globalIndex,
                child: child,
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down,
              size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  Widget _buildDimensionBtn(String label, String dim) {
    bool selected = _dimension == dim;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeDimension(dim),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade800,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
