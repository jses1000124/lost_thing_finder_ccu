import 'package:final_project/models/lost_thing.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/lost_thing_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/bottom_bar.dart';

final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF6200EE),
    ),
    textTheme: GoogleFonts.latoTextTheme());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((fn) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const BottomBar(), //正式版是LoginScreen() 目前測試才直接切LostThingScreen()
    );
  }
}
