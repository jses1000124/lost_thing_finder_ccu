import '../screens/chatlist_screen.dart';
import 'package:flutter/material.dart';
import '../screens/add_lost_thing.dart';
import '../screens/finded_lost_thing_screen.dart';
import '../screens/lost_thing_screen.dart';
import 'map_screen.dart';
import '../screens/setting_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  String _title = '遺失物';
  static String searchVal = '';
  String searchType = 'title';
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      const LostThingScreen(),
      const FindedThingScreen(),
      const MapPage(),
      const SettingsPage(),
    ];
  }

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
        _title = '遺失物';
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
      appBar: _selectedIndex != 2 && _selectedIndex != 3
          ? AppBar(
              title: SearchAppBar(
                hintLabel: '$_title搜尋',
                onSubmitted: _updateSearch,
                clearSearch: _updateSearch,
              ),
              titleSpacing: 0,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatListScreen())),
                )
              ],
            )
          : AppBar(
              title: _selectedIndex == 2 ? const Text('地圖') : const Text('設定'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatListScreen())),
                )
              ],
            ),
      body: Center(child: _widgetOptions[_selectedIndex]),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              mini: true,
              onPressed: _openAddLostThing,
              backgroundColor: Theme.of(context).colorScheme.background,
              child: const Icon(Icons.add),
            )
          : null,
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
          showUnselectedLabels: true,
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedItemColor: const Color.fromARGB(255, 35, 108, 243),
          unselectedItemColor: const Color(0xFF546480),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.question, size: 20),
                activeIcon: Icon(FontAwesomeIcons.question),
                label: "遺失物"),
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

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({
    super.key,
    required this.hintLabel,
    required this.onSubmitted,
    this.clearSearch,
  });

  final String hintLabel;
  final Function(String) onSubmitted;
  final Function(String)? clearSearch;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _controller = TextEditingController();

  void _clearSearch() {
    _controller.clear();
    widget.clearSearch?.call(''); // Invoke the clear search callback
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 40,
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintLabel,
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            icon: const Icon(Icons.search, size: 18),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() => _controller.text = value);
          },
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }
}
