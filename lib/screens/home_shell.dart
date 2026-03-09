import 'package:flutter/material.dart';

import 'garden_page.dart';
import 'inventory_page.dart';
import 'missions_page.dart';
import 'perfil_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    GardenPage(),
    InventoryPage(),
    MissionsPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Jardí',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Inventari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Missions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}