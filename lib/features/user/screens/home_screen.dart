import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skill_link_new/features/authentication/providers/auth_controller.dart';
import 'package:skill_link_new/features/post/screens/post_page.dart';
import 'package:skill_link_new/features/search/screens/search_page.dart';
import 'package:skill_link_new/features/tasks/screens/my_tasks_page.dart';
import 'package:skill_link_new/features/user/screens/messages_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const List<String> _pageTitles = [
    'Post',
    'Search',
    'My Tasks',
    'Messages',
  ];

  static final List<Widget> _pages = [
  // Pages — PostPage implemented in separate file
  const PostPage(),
  const SearchPage(),
    const MyTasksPage(),
    const MessagesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () async {
                try {
                  await ref.read(authControllerProvider.notifier).signOut();
                  // After sign out the global router (if configured) will handle redirects.
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
              icon: const Icon(Icons.logout),
            );
          },
        ),
      ),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add_outlined),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}
