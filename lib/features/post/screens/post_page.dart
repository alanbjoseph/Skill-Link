import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/post_form_provider.dart';
import 'task_creation_flow.dart';

// Top categories - will be made dynamic later
const List<Map<String, dynamic>> _topCategories = [
  {'name': 'Cleaning', 'icon': Icons.cleaning_services_outlined},
  {'name': 'Repair', 'icon': Icons.build_outlined},
  {'name': 'Delivery', 'icon': Icons.local_shipping_outlined},
  {'name': 'Moving', 'icon': Icons.airport_shuttle_outlined},
  {'name': 'Gardening', 'icon': Icons.yard_outlined},
  {'name': 'Tech Support', 'icon': Icons.computer_outlined},
];

class PostPage extends ConsumerStatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isExpanded = _scrollController.hasClients &&
          _scrollController.offset < (200 - kToolbarHeight);
      if (_isAppBarExpanded != isExpanded) {
        setState(() {
          _isAppBarExpanded = isExpanded;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Large app bar with logo that shrinks on scroll
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'SkillLink',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: _isAppBarExpanded ? 32 : 20,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.handshake_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Categories section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _topCategories.map((category) {
                      return _buildCategoryChip(
                        context,
                        category['name'] as String,
                        category['icon'] as IconData,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_task_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Post Your Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button below to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Reset form before starting
          ref.read(postFormProvider.notifier).reset();
          
          // Navigate to task creation flow
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskCreationFlow(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Task'),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String name, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 20),
      label: Text(name),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () {
        // Navigate to search with category filter (to be implemented)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Browse $name tasks (coming soon)')),
        );
      },
    );
  }
}
