import 'package:flutter/material.dart';
import 'grid_demo_page.dart';
import 'list_demo_page.dart';
import 'grouped_list_demo_page.dart';
import 'sliver_demo_page.dart';
import 'sliver_components_demo_page.dart';
import 'photo_gallery_demo_page.dart';
import 'desktop_list_demo_page.dart';
import 'advanced_desktop_demo_page.dart';
import 'scrollbar_demo_page.dart';
import 'multi_dimension_demo_page.dart';

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('YuniFileListView 案例集'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            context,
            title: '1. 宫格列表 (Grid)',
            subtitle: '支持动态/固定列数，自适应屏幕宽度',
            icon: Icons.grid_view,
            color: Colors.blue,
            page: const GridDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '2. 纵向明细列表 (List)',
            subtitle: '带缩略图、多行信息、右侧多选框',
            icon: Icons.view_list,
            color: Colors.green,
            page: const ListDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '3. 粘性分组列表 (Grouped List 纵向)',
            subtitle: '按时间/类型分组的单列纵向数据展示',
            icon: Icons.receipt_long,
            color: Colors.teal,
            page: const GroupedListDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '4. Sliver 组件演示',
            subtitle: 'SliverYFileGridView / SliverYFileListView 原子组件',
            icon: Icons.layers,
            color: Colors.purple,
            page: const SliverComponentsDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '5. Sliver 组合嵌套',
            subtitle: '与其他 Sliver 组件自由组合滚动',
            icon: Icons.layers,
            color: Colors.purple,
            page: const SliverDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '6. 复合相册案例 (年月日切换)',
            subtitle: '支持三级维度切换的完整相册展示逻辑',
            icon: Icons.auto_awesome_motion,
            color: Colors.pinkAccent,
            page: const PhotoGalleryDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '7. 桌面端列表 (Desktop)',
            subtitle: '类 Finder 列表，支持鼠标框选、修饰键多选',
            icon: Icons.personal_video,
            color: Colors.indigo,
            page: const DesktopListDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '8. 桌面端列表 (高级)',
            subtitle: '支持列表/宫格/分组切换，自定义表头',
            icon: Icons.dashboard_customize,
            color: Colors.deepOrange,
            page: const AdvancedDesktopDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '9. YRulerScrollbar 尺子滚动条',
            subtitle: '自定义样式、刻度节点跳转、拖拽左侧提示',
            icon: Icons.straighten,
            color: Colors.deepPurple,
            page: const ScrollbarDemoPage(),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: '10. Premium 多维度分组 (New)',
            subtitle: '毛玻璃吸顶、动态数据负载、各维度平滑切换',
            icon: Icons.auto_awesome,
            color: Colors.orange,
            page: const MultiDimensionDemoPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
