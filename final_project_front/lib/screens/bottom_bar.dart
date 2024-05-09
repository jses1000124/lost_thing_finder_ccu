import 'package:flutter/material.dart';
import '../screens/add_lost_thing.dart';
import '../screens/finded_lost_thing_screen.dart';
import '../screens/lost_thing_screen.dart';
import '../drawer/main_drawer.dart';
import '../screens/chatlist_screen.dart';

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
  final List<Widget> _widgetOptions = <Widget>[
    const LostThingScreen(),
    FindedThingScreen(
      searchedThingName: searchVal,
    ),
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
        _title = '遺失物';
      } else {
        _title = '待尋物';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchAppBar(
          hintLabel: '$_title搜尋',
          onSubmitted: (value) {
            setState(() {
              searchVal = value;
            });
          },
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
      ),
      drawer: const MainDrawer(),
      body: Center(child: _widgetOptions[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          _openAddLostThing();
        },
        backgroundColor: Theme.of(context).colorScheme.background,
        child: const Icon(Icons.add),
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

class SearchAppBar extends StatefulWidget {
  const SearchAppBar(
      {super.key, required this.hintLabel, required this.onSubmitted});
  final String hintLabel;
  // 回调函数
  final Function(String) onSubmitted;

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  // 文本的值
  String searchVal = '';
  //用于清空输入框
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    MediaQueryData queryData = MediaQuery.of(context);
    return Container(
      // 宽度为屏幕的0.8
      width: queryData.size.width * 0.8,
      // appBar默认高度是56，这里搜索框设置为40
      height: 40,
      // 设置padding
      padding: const EdgeInsets.only(left: 20),
      // 设置子级位置
      alignment: Alignment.centerLeft,
      // 设置修饰
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: widget.hintLabel,
            hintStyle: const TextStyle(color: Colors.grey),
            // 取消掉文本框下面的边框
            border: InputBorder.none,
            icon: const Padding(
                padding: EdgeInsets.only(left: 0, top: 0),
                child: Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.white,
                )),
            //  关闭按钮，有值时才显示
            suffixIcon: searchVal.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    style: ButtonStyle(
                      iconColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      //   清空内容
                      setState(() {
                        searchVal = '';
                        _controller.clear();
                      });
                    },
                  )
                : null),
        onChanged: (value) {
          setState(() {
            searchVal = value;
          });
        },
        onSubmitted: (value) {
          widget.onSubmitted(value);
        },
      ),
    );
  }
}
