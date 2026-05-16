import 'package:flutter/material.dart';
import 'package:meteo_garden/generated/app_localizations.dart';

import 'garden_page.dart';
import 'album_page.dart';
import 'missions_page.dart';
import 'perfil_page.dart';
import 'photo_page.dart';
import 'inventory_page.dart';
import 'friends_page.dart';

import 'package:provider/provider.dart';
import '../models/dades_usr.dart';

class HomeShell extends StatefulWidget {
  final List<Widget>? pagesForTests;

  const HomeShell({
    super.key,
    this.pagesForTests,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserModel>(context).username;
    final gardenName = Provider.of<UserModel>(context).gardenName;
    final l10n = AppLocalizations.of(context)!;

   final List<Widget> pages =
    widget.pagesForTests ??
    [
      GardenPage(username: username, gardenName: gardenName),
      FriendsPage(),
      PlantCameraScreen(),
      MissionsPage(),
      PerfilPage(),
      InventoryPage(username: username),
      AlbumPage(),
    ];

    final navItems = [
      _NavItem(
        keyName: 'nav_garden',
        icon: Icons.local_florist_outlined,
        activeIcon: Icons.local_florist,
        label: l10n.navGarden,
      ),
      _NavItem(
        keyName: 'nav_friends',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: l10n.navFriends,
      ),
      _NavItem(
        keyName: 'nav_camera',
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        label: l10n.navCamera,
      ),
      _NavItem(
        keyName: 'nav_missions',
        icon: Icons.flag_outlined,
        activeIcon: Icons.flag,
        label: l10n.navMissions,
      ),
      _NavItem(
        keyName: 'nav_profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.navProfile,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: _FloatingNavBar(
        items: navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String keyName;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.keyName,
  });
}

class _FloatingNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF7FB77E).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.50),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3a7d1e).withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isSelected = i == currentIndex;
            return _FloatingNavTile(
              item: items[i],
              isSelected: isSelected,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _FloatingNavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(item.keyName),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, isSelected ? -6 : 0, 0),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3a7d1e).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF3a7d1e)
                  : Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 5 : 0,
            height: isSelected ? 5 : 0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
