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
  const HomeShell({super.key});

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

    final List<Widget> pages = [
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
        icon: Icons.local_florist_outlined,
        activeIcon: Icons.local_florist,
        label: l10n.navGarden,
      ),
      _NavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: l10n.navFriends,
      ),
      _NavItem(
        icon: Icons.camera_alt_outlined,
        activeIcon: Icons.camera_alt,
        label: l10n.navCamera,
      ),
      _NavItem(
        icon: Icons.flag_outlined,
        activeIcon: Icons.flag,
        label: l10n.navMissions,
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: l10n.navProfile,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: _GameNavBar(
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

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _GameNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GameNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7FB77E),
        border: Border(
          top: BorderSide(color: Color(0xFF3E6B48), width: 3),
          bottom: BorderSide(color: Color(0xFF3E6B48), width: 3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: IntrinsicHeight(
          child: Row(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _GameNavTile(
                        item: items[i],
                        isSelected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        color: const Color(0xFF3E6B48),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GameNavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _GameNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFCFE8CF)
              : const Color(0xFF9ED2A0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 20,
              color: const Color(0xFF1E3D2B),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E3D2B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}