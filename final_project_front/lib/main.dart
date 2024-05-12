import '../widgets/auto_login_handler.dart';
import 'package:final_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';
import '../models/user_preferences.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 42, 76, 190),
    onBackground: Colors.white,
    background: Colors.grey[100],
  ),
  textTheme: GoogleFonts.latoTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[450],
    titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.grey[800]),
  ),
);

final ThemeData darkTheme = ThemeData(
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();
  final userPreferences = UserPreferences();
  await userPreferences.loadPreferences();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => themeProvider),
      ChangeNotifierProvider(create: (_) => userPreferences),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.dark, // Dark status bar icons
        systemNavigationBarColor: themeProvider.themeMode == ThemeMode.dark
            ? darkTheme.primaryColor
            : Colors.white, // Navigation bar color based on theme mode
        systemNavigationBarIconBrightness:
            themeProvider.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark, // Navigation bar icons based on theme mode
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.themeMode,
        home: const AutoLoginHandler(),
      ),
    );
  }
}
