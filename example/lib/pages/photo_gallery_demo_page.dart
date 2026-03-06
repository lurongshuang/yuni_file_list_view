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

  List<YFileGroup<YFileItem>> _groups = [];
  List<YFileItem> _flatItems = [];
  List<int> _groupOffsets = [];

  Set<String> _dragStartSelectedIds = {};
  bool _isSelecting = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateData() {
    _groups = DemoData.getGroupsByDimension(_dimension);
    _flatItems = _groups.expand((g) => g.items).toList();
    _groupOffsets = [];
    int offset = 0;
    for (var g in _groups) {
      _groupOffsets.add(offset);
      offset += g.items.length;
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
      _updateData();
    });
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == YFileGroupedMode.grid ? YFileGroupedMode.list : YFileGroupedMode.grid;
    });
  }

  void _onDragSelectStart(int index) {
    if (index < 0 || index >= _flatItems.length) return;
    final id = _flatItems[index].id;
    
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
    if (startIndex < 0 || currentIndex < 0 || _flatItems.isEmpty) return;
    if (startIndex >= _flatItems.length || currentIndex >= _flatItems.length) return;
    
    final int minIdx = startIndex < currentIndex ? startIndex : currentIndex;
    final int maxIdx = startIndex > currentIndex ? startIndex : currentIndex;
    
    final Set<String> newSelection = Set.from(_dragStartSelectedIds);
    
    for (int i = minIdx; i <= maxIdx; i++) {
      final id = _flatItems[i].id;
      if (_isSelecting) {
        newSelection.add(id);
      } else {
        newSelection.remove(id);
      }
    }
    
    if (newSelection.length != _selectedIds.length || !newSelection.containsAll(_selectedIds)) {
      setState(() {
        _selectedIds.clear();
        _selectedIds.addAll(newSelection);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 4;
    if (_dimension == 'year') crossAxisCount = 5;
    if (_dimension == 'day') crossAxisCount = 3;

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

          YDragSelectRegion(
            scrollController: _scrollController,
            onDragSelectStart: (idx) => _onDragSelectStart(idx),
            onDragSelectUpdate: (start, current) => _onDragSelectUpdate(start, current),
            child: CustomScrollView(
              key: const PageStorageKey('gallery_shared_scroll_position'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(_mode == YFileGroupedMode.grid ? Icons.format_list_bulleted : Icons.grid_view, color: Colors.blue),
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
                      const Text('2025年春节', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black)),
                      const SizedBox(height: 2),
                      Text(
                        '3012张图片  124个视频  80个其他文件',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
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
                  groups: _groups,
                  config: YFileGroupedConfig(
                    mode: _mode,
                    gridConfig: YFileGridConfig(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 1.0,
                      mainAxisSpacing: 1.0,
                      padding: EdgeInsets.zero, 
                    ),
                    listConfig: const YFileListConfig(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  headerBuilder: (context, group, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      color: Colors.white,
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
                    int globalIndex = _groupOffsets[groupIndex] + itemIndex;

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
                        config: const YFileListUIConfig(showDivider: true, dividerIndent: 76),
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
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
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
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade500),
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
            boxShadow: selected ? [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ] : [],
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
