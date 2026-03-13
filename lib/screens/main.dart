import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const GenoSceneApp(),
    ),
  );
}

class GenoSceneApp extends StatelessWidget {
  const GenoSceneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'GenoScene',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0A1628),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0A1628), // Deep Navy
            primary: const Color(0xFF4DD0E1), // Cyan
            secondary: const Color(0xFF134074), // Secondary Navy
            brightness: Brightness.dark,
          ),
          textTheme:
              GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DD0E1), // Cyan buttons
              foregroundColor: const Color(0xFF0A1628), // Dark text on cyan
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const HomeScreen());
  }
}
