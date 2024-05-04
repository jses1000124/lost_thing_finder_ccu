import 'package:flutter/material.dart ';
import '../screens/finded_lost_thing_screen.dart';
import '../screens/lost_thing_screen.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const LostThingScreen(),
    const FindedThingScreen(),
  ];
  // fun to change index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        elevation: 10,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: const Color.fromARGB(255, 35, 108, 243),
        unselectedItemColor: const Color(0xFF546480),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: "Lost Thing"),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: "Finded Thing"),
        ],
      ),
    );
  }
}
