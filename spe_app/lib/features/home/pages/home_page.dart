import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/colors.dart';
import '../../explore/explore_page.dart';
import '../../auth/auth_controller.dart';
import '../../community/pages/community_list_page.dart';
import '../../sparring/pages/user_sparring_page.dart';
import '../../sparring/pages/sparring_list_page.dart';
import '../../../router/app_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              const SizedBox(height: 16),
              const _QuickActions(),
              const SizedBox(height: 20),
              const _PromoBanner(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    Icon(Icons.mic_none, color: Colors.grey, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _CircleIcon(icon: Icons.notifications_none, onTap: () {}),
          ],
        ),
        const SizedBox(height: 14),
        _Greeting(ref: ref),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  final WidgetRef ref;
  const _Greeting({required this.ref});

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState.user?.name ?? 'SportEase';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $userName! 👋',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Yuk cari lawan sparing atau booking lapangan',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        title: 'Booking Lapangan',
        image:
            'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=800',
        icon: Icons.event_available,
        onTap: () {
          Navigator.pushNamed(context, AppRouter.fieldList);
        },
      ),
      _ActionItem(
        title: 'Main Bareng',
        image:
            'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
        icon: Icons.groups_2,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunityListPage()),
          );
        },
      ),
      _ActionItem(
        title: 'Lapangan Terdekat',
        image:
            'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?w=800',
        icon: Icons.location_on,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.locationPicker,
            arguments: {'viewOnly': true},
          );
        },
      ),
      _ActionItem(
        title: 'Sparing Cepat',
        image:
            'https://images.unsplash.com/photo-1483721310020-03333e577078?w=800',
        icon: Icons.sports_soccer,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SizedBox(
              height: 200,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Sparring',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Buat Sparring'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserSparringPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Daftar Sparring'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SparringListPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) => _QuickCard(item: a)).toList(),
    );
  }

  static void _openSparringMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExplorePage()),
    );
  }
}

class _ActionItem {
  final String title;
  final String image;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionItem({
    required this.title,
    required this.image,
    required this.icon,
    required this.onTap,
  });
}

class _QuickCard extends StatelessWidget {
  final _ActionItem item;

  const _QuickCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.15),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: _CircleIcon(
                icon: item.icon,
                background: Colors.white,
                color: AppColors.primary,
                onTap: item.onTap,
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Bosan lawan tim yang itu-itu aja?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Temukan ratusan lawan mainmu di SportEase',
                  style: TextStyle(color: AppColors.dark, fontSize: 13),
                ),
                SizedBox(height: 12),
                _SmallButton(text: 'Buat sparing sekarang'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String text;
  const _SmallButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;

  const _CircleIcon({
    required this.icon,
    this.background = Colors.white,
    this.color = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
