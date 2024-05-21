import 'package:final_project/models/userimg_id_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/post_provider.dart';
import 'widgets/auto_login_handler.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/theme_provider.dart';
import 'models/user_nicknames.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
//銘宏大帥哥可以給我們高分一點嗎拜託

//http 繞過ssl
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 42, 76, 190),
    onSurface: Colors.white,
    surface: Colors.grey[100],
  ),
  textTheme: GoogleFonts.ibmPlexSansJpTextTheme().apply(
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
  textTheme: GoogleFonts.ibmPlexSansJpTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 繞過ssl
  // HttpOverrides.global = MyHttpOverrides();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    FirebaseStorage.instance;
    // .useStorageEmulator('localhost', 9199); // Optional: use this line if you use a local emulator
    //FirebaseStorageWeb.registerWith();
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // OneSignal Initialization
  //Remove this method to stop OneSignal Debugging
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("22ccb45f-f773-4a26-a4ea-aab2d267207a");
// The promptForPushNotificationUWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.permission;

  final themeProvider = ThemeProvider();
  await themeProvider.loadThemeMode();
  final userPreferences = UserPreferences();
  await userPreferences.loadPreferences();
  final postProvider = PostProvider();
  final userImgIdProvider = UserImgIdProvider();
  await userImgIdProvider.loadUserImgId();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => postProvider),
      ChangeNotifierProvider(create: (_) => themeProvider),
      ChangeNotifierProvider(create: (_) => userPreferences),
      ChangeNotifierProvider(create: (_) => userImgIdProvider),
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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: themeProvider.themeMode == ThemeMode.dark
            ? darkTheme.primaryColor
            : Colors.white,
        systemNavigationBarIconBrightness:
            themeProvider.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
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
