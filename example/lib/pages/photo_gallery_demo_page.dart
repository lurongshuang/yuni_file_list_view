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
  String _dimension = 'month'; // 'year', 'month', 'day'
  YFileGroupedMode _mode = YFileGroupedMode.grid;
  final Set<String> _selectedIds = {};
  
  // 使用相同的 ScrollController 并在维度切换时尝试保留偏移
  final ScrollController _scrollController = ScrollController();

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
      _mode = _mode == YFileGroupedMode.grid ? YFileGroupedMode.list : YFileGroupedMode.grid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = DemoData.getGroupsByDimension(_dimension);
    
    // 根据维度和模式决定布局
    int crossAxisCount = 4;
    if (_dimension == 'year') crossAxisCount = 5;
    if (_dimension == 'day') crossAxisCount = 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 背景层级做一点渐变或者干净的处理
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade50, Colors.white],
              ),
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey('switcher_$_dimension$_mode'),
              child: CustomScrollView(
                key: const PageStorageKey('gallery_shared_scroll_position'),
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. 顶部 Header (视觉升级)
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    // 模式切换按钮
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

                // 2. 模拟筛选按钮栏 (间距优化 - 加大下间距让页面透气)
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

                // 3. 分组列表核心 (支持 List/Grid 混合)
                ...buildSliverYFileGroupedListView<YFileItem>(
                  groups: groups,
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
                    if (_mode == YFileGroupedMode.grid) {
                      return YFileGridItem(
                        item: item,
                        selected: isSelected,
                        onTap: () => _toggleSelection(item.id),
                      );
                    } else {
                      return YFileListItem(
                        item: item,
                        config: const YFileListUIConfig(showDivider: true, dividerIndent: 76),
                        selected: isSelected,
                        onTap: () => _toggleSelection(item.id),
                      );
                    }
                  },
                ),

                // 底部安全留白
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          ),
        ),

        // 4. 底部切换器 (视觉全方位升级)
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
          curve: Curves.fastOutSlowIn, // 使用安全曲线，避免超调导致的阴影负值断言错误
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
