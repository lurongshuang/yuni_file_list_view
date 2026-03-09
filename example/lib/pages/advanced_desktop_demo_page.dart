import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../data/demo_data.dart';

enum ViewMode { list, grid, grouped, groupedGrid }

class AdvancedDesktopDemoPage extends StatefulWidget {
  const AdvancedDesktopDemoPage({super.key});

  @override
  State<AdvancedDesktopDemoPage> createState() => _AdvancedDesktopDemoPageState();
}

class _AdvancedDesktopDemoPageState extends State<AdvancedDesktopDemoPage> {
  ViewMode _viewMode = ViewMode.list;
  late final YDesktopSelectionController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _showHeader = true;
  bool _isResponsive = true;

  @override
  void initState() {
    super.initState();
    _controller = YDesktopSelectionController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Text('高级桌面端演示 (已选 ${_controller.selectedIndices.length})');
          },
        ),
        actions: [
          Row(
            children: [
              const Text('显示表头'),
              Switch(
                value: _showHeader,
                onChanged: (val) => setState(() => _showHeader = val),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Text('自适应'),
              Switch(
                value: _isResponsive,
                onChanged: (val) => setState(() => _isResponsive = val),
              ),
            ],
          ),
          const SizedBox(width: 8),
          DropdownButton<ViewMode>(
            value: _viewMode,
            items: const [
              DropdownMenuItem(value: ViewMode.list, child: Text('列表模式')),
              DropdownMenuItem(value: ViewMode.grid, child: Text('宫格模式')),
              DropdownMenuItem(value: ViewMode.grouped, child: Text('分组列表')),
              DropdownMenuItem(value: ViewMode.groupedGrid, child: Text('分组宫格')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _viewMode = val;
                  _controller.clearSelection();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _controller.clearSelection(),
            tooltip: '清空选择',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_viewMode) {
      case ViewMode.list:
        return YDesktopFileListView<YFileItem>(
          items: DemoData.listItems,
          controller: _controller,
          scrollController: _scrollController,
          showHeader: _showHeader,
          columns: _buildColumns(),
          // 演示：完全外部构建 Item
          itemBuilder: (context, item, index, isSelected, onPointerDown) {
            return GestureDetector(
              onTap: () {}, // 阻止冒泡
              onSecondaryTap: () => onPointerDown(true),
              child: Container(
                height: 32,
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(_getIcon(item.type), size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(item.name, style: TextStyle(color: isSelected ? Colors.blue : null)),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check, size: 14, color: Colors.blue),
                  ],
                ),
              ),
            );
          },
        );
      case ViewMode.grid:
        return YDesktopFileGridView<YFileItem>(
          items: DemoData.listItems,
          controller: _controller,
          scrollController: _scrollController,
          crossAxisCount: _isResponsive ? 0 : 6,
          maxCrossAxisExtent: _isResponsive ? 140.0 : null,
          childAspectRatio: 0.8,
          itemBuilder: (context, item, index, isSelected, onPointerDown) {
            return _buildGridItem(item, isSelected, onPointerDown);
          },
        );
      case ViewMode.grouped:
        return YDesktopGroupedListView<YFileItem>(
          groups: [
            YFileGroup(groupId: 'today', groupTitle: '今天', items: DemoData.listItems.sublist(0, 5)),
            YFileGroup(groupId: 'yesterday', groupTitle: '昨天', items: DemoData.listItems.sublist(5, 15)),
            YFileGroup(groupId: 'earlier', groupTitle: '更早', items: DemoData.listItems.sublist(15)),
          ],
          controller: _controller,
          scrollController: _scrollController,
          columns: _buildColumns(),
        );
      case ViewMode.groupedGrid:
        return YDesktopGroupedGridView<YFileItem>(
          groups: [
            YFileGroup(groupId: 'today', groupTitle: '今天', items: DemoData.listItems.sublist(0, 5)),
            YFileGroup(groupId: 'yesterday', groupTitle: '昨天', items: DemoData.listItems.sublist(5, 15)),
            YFileGroup(groupId: 'earlier', groupTitle: '更早', items: DemoData.listItems.sublist(15)),
          ],
          controller: _controller,
          scrollController: _scrollController,
          crossAxisCount: _isResponsive ? 0 : 6,
          maxCrossAxisExtent: _isResponsive ? 140.0 : null,
          childAspectRatio: 0.8,
          itemBuilder: (context, item, index, isSelected, onPointerDown) {
            return _buildGridItem(item, isSelected, onPointerDown);
          },
        );
    }
  }

  Widget _buildGridItem(YFileItem item, bool isSelected, void Function(bool isSecondary) onPointerDown) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 可以在这里演示点击不同区域触发选择
          GestureDetector(
            onSecondaryTap: () => onPointerDown(true),
            child: Icon(_getIcon(item.type), size: 48, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  List<YDesktopColumn<YFileItem>> _buildColumns() {
    return [
      YDesktopColumn(
        label: '名称',
        flex: 1,
        itemBuilder: (context, item) => Row(
          children: [
            Icon(_getIcon(item.type), size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name)),
          ],
        ),
      ),
      YDesktopColumn(
        label: '大小',
        width: 100,
        itemBuilder: (context, item) => Text(
          '${((item.fileSize ?? 0) / 1024).toStringAsFixed(1)} KB',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    ];
  }

  IconData _getIcon(YFileType type) {
    switch (type) {
      case YFileType.folder: return Icons.folder;
      case YFileType.image: return Icons.image;
      case YFileType.video: return Icons.movie;
      case YFileType.audio: return Icons.audiotrack;
      default: return Icons.insert_drive_file;
    }
  }
}
