import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/colors.dart';
import '../home/pages/home_page.dart';
import '../explore/explore_page.dart';
import '../profile/profile_page.dart';
import 'main_tab_controller.dart';

class MainTabPage extends ConsumerWidget {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(mainTabIndexProvider);

    final pages = [const HomePage(), const ExplorePage(), const ProfilePage()];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => ref.read(mainTabIndexProvider.notifier).state = i,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,

        elevation: 12,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore_outlined),
            activeIcon: Icon(Icons.travel_explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
