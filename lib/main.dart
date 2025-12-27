import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled2/auth/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  

  await dotenv.load(fileName: "key.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber, 
          brightness: Brightness.light,
        ),
        
        // Font Configuration
        textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
          displayLarge: GoogleFonts.poppins(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.poppins(textStyle: textTheme.displayMedium, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.poppins(textStyle: textTheme.displaySmall, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.poppins(textStyle: textTheme.headlineLarge, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins(textStyle: textTheme.headlineMedium, fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.poppins(textStyle: textTheme.headlineSmall, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.poppins(textStyle: textTheme.titleLarge, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(textStyle: textTheme.titleMedium, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.poppins(textStyle: textTheme.titleSmall, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.merriweather(textStyle: textTheme.bodyLarge),
          bodyMedium: GoogleFonts.merriweather(textStyle: textTheme.bodyMedium),
          bodySmall: GoogleFonts.merriweather(textStyle: textTheme.bodySmall),
          labelLarge: GoogleFonts.poppins(textStyle: textTheme.labelLarge, fontWeight: FontWeight.w500),
        ),
        
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}