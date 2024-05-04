import 'package:flutter/material.dart';
import '../screens/add_lost_thing.dart';
import '../screens/finded_lost_thing_screen.dart';
import '../screens/lost_thing_screen.dart';
import '../drawer/main_drawer.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  String _title = 'Lost Thing';
  static final List<Widget> _widgetOptions = <Widget>[
    const LostThingScreen(),
    const FindedThingScreen(),
  ];
  // fun to change index

  void _openAddLostThing() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => const AddLostThing(),
        isScrollControlled: true);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _title = 'Lost Thing';
      } else {
        _title = 'Finded Thing';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      drawer: const MainDrawer(),
      body: Center(child: _widgetOptions[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          _openAddLostThing();
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          elevation: 10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedItemColor: const Color.fromARGB(255, 35, 108, 243),
          unselectedItemColor: const Color(0xFF546480),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                backgroundColor: Color.fromARGB(0, 255, 255, 255),
                label: "Lost Thing"),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search_rounded),
                backgroundColor: Color.fromARGB(0, 255, 255, 255),
                label: "Finded Thing"),
          ],
        ),
      ),
    );
  }
}
