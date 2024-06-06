import 'package:flutter/material.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import '../widgets/chaticon_with_notification.dart';
import 'add_lost_thing.dart';
import '../screens/finded_lost_thing_screen.dart';
import '../screens/lost_thing_screen.dart';
import 'map_screen.dart';
import '../screens/setting_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String _title = '尋獲物';
  static String searchVal = '';
  String searchType = 'title';
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    setOptimalDisplayMode();
    super.initState();
    _widgetOptions = [
      const LostThingScreen(),
      const FindedThingScreen(),
      const MapPage(),
      const SettingsPage(),
    ];
  }

  Future<void> setOptimalDisplayMode() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> sameResolution = supported
        .where((DisplayMode m) =>
            m.width == active.width && m.height == active.height)
        .toList()
      ..sort((DisplayMode a, DisplayMode b) =>
          b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode =
        sameResolution.isNotEmpty ? sameResolution.first : active;

    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _title = '尋獲物';
      } else {
        _title = '待尋物';
      }
    });
  }

  void _updateSearch(String value) {
    setState(() {
      searchVal = value;
      _widgetOptions = [
        LostThingScreen(searchedThingName: searchVal),
        FindedThingScreen(searchedThingName: searchVal),
        const MapPage(),
        const SettingsPage(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _selectedIndex != 2 && _selectedIndex != 3
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: EasySearchBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                searchHintText: '$_title搜尋',
                showClearSearchIcon: true,
                putActionsOnRight: true,
                title: Text(_title),
                onSearch: _updateSearch,
                actions: const [
                  ChatIconWithNotification(),
                ],
                suggestions: const [],
                searchCursorColor: Theme.of(context).colorScheme.brightness ==
                        Brightness.light
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : AppBar(
              title: _selectedIndex == 2 ? const Text('地圖') : const Text('設定'),
              actions: const [ChatIconWithNotification()],
            ),
      body: Center(child: _widgetOptions[_selectedIndex]),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              // web won't use mini
              mini: true,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddLostThing()));
              },
              backgroundColor:
                  Theme.of(context).colorScheme.onPrimaryFixedVariant,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          elevation: 10,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
          ),
          backgroundColor:
              Theme.of(context).colorScheme.brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
          selectedItemColor: const Color.fromARGB(255, 35, 108, 243),
          unselectedItemColor: const Color(0xFF546480),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.question, size: 20),
                activeIcon: Icon(FontAwesomeIcons.question),
                label: "尋獲物"),
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
                activeIcon: Icon(FontAwesomeIcons.magnifyingGlass),
                label: "待尋物"),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map, size: 30),
                label: "地圖"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings, size: 30),
                label: "設定"),
          ],
        ),
      ),
    );
  }
}
