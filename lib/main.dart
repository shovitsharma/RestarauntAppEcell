import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- 1. IMPORT GOOGLE FONTS
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled2/auth/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We get the base theme for the text from Google Fonts
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber, 
          brightness: Brightness.light,
        ),
        
        
        textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
          // For headlines and titles
          displayLarge: GoogleFonts.poppins(textStyle: textTheme.displayLarge, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.poppins(textStyle: textTheme.displayMedium, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.poppins(textStyle: textTheme.displaySmall, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.poppins(textStyle: textTheme.headlineLarge, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.poppins(textStyle: textTheme.headlineMedium, fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.poppins(textStyle: textTheme.headlineSmall, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.poppins(textStyle: textTheme.titleLarge, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.poppins(textStyle: textTheme.titleMedium, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.poppins(textStyle: textTheme.titleSmall, fontWeight: FontWeight.w600),

          // For body text, buttons, captions etc.
          bodyLarge: GoogleFonts.merriweather(textStyle: textTheme.bodyLarge),
          bodyMedium: GoogleFonts.merriweather(textStyle: textTheme.bodyMedium),
          bodySmall: GoogleFonts.merriweather(textStyle: textTheme.bodySmall),
          labelLarge: GoogleFonts.poppins(textStyle: textTheme.labelLarge, fontWeight: FontWeight.w500), // For buttons
          labelMedium: GoogleFonts.poppins(textStyle: textTheme.labelMedium),
          labelSmall: GoogleFonts.poppins(textStyle: textTheme.labelSmall),
        ),
        
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}