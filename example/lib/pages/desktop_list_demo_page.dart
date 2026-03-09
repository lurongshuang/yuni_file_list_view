import 'package:flutter/material.dart';
import 'package:yuni_file_list_view/yuni_file_list_view.dart';
import '../models/y_file_item.dart';
import '../data/demo_data.dart';

class DesktopListDemoPage extends StatefulWidget {
  const DesktopListDemoPage({super.key});

  @override
  State<DesktopListDemoPage> createState() => _DesktopListDemoPageState();
}

class _DesktopListDemoPageState extends State<DesktopListDemoPage> {
  late final YDesktopSelectionController _controller;
  final ScrollController _scrollController = ScrollController();
  
  // 外部存储的选中 ID（演示如何将索引同步到业务 ID）
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _controller = YDesktopSelectionController();
    
    // 监听选中状态并同步到外部
    _controller.onSelectionChanged = (indices) {
      setState(() {
        _selectedIds.clear();
        for (final index in indices) {
          if (index < DemoData.listItems.length) {
            _selectedIds.add(DemoData.listItems[index].id);
          }
        }
      });
    };
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
        title: Text('桌面端列表 (业务同步已选 ${_selectedIds.length})'),
        actions: [
          TextButton(
            onPressed: () => _controller.clearSelection(),
            child: const Text('清空', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => _controller.selectAll(DemoData.listItems.length),
            child: const Text('全选', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        child: YDesktopFileListView<YFileItem>(
          items: DemoData.listItems,
          controller: _controller,
          scrollController: _scrollController,
          columns: [
            YDesktopColumn(
              label: '名称',
              flex: 3,
              itemBuilder: (context, item) => Row(
                children: [
                  Icon(_getIcon(item.type), size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            YDesktopColumn(
              label: '修改日期',
              width: 150,
              itemBuilder: (context, item) {
                final date = item.modifiedAt ?? DateTime.now();
                return Text(
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                );
              },
            ),
            YDesktopColumn(
              label: '大小',
              width: 80,
              itemBuilder: (context, item) {
                final size = item.fileSize ?? 0;
                final kb = size / 1024;
                return Text(
                  kb > 1024 ? '${(kb / 1024).toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(1)} KB',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                );
              },
            ),
            YDesktopColumn(
              label: '种类',
              width: 100,
              itemBuilder: (context, item) => Text(
                _getTypeLabel(item.type),
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
              ),
            ),
          ],
          onItemDoubleTap: (item) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('打开文件: ${item.name}')),
            );
          },
        ),
      ),
    );
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

  String _getTypeLabel(YFileType type) {
    switch (type) {
      case YFileType.folder: return '文件夹';
      case YFileType.image: return '图片';
      case YFileType.video: return '视频';
      case YFileType.audio: return '音频';
      default: return '文件';
    }
  }
}
