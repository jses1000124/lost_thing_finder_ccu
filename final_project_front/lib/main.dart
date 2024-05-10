import 'package:final_project/firebase_options.dart';
import 'package:final_project/screens/bottom_bar.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF6200EE),
  ),
  textTheme: GoogleFonts.latoTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool autoLogin = prefs.getBool('autoLogin') ?? false;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((fn) {
    runApp(MyApp(isLoggedIn: isLoggedIn && autoLogin));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: isLoggedIn ? const BottomBar() : const LoginScreen(),
    );
  }
}
