import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streak_meter/auth/auth.dart';
import 'package:streak_meter/screens/habit_screen.dart';
import 'package:streak_meter/screens/splash.dart';
import 'package:streak_meter/theme/colors.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Paint.enableDithering = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kPrimary,
        appBarTheme: const AppBarTheme().copyWith(
          color: Colors.transparent,
          iconTheme: const IconThemeData().copyWith(color: kWhite),
        ),
        textTheme: const TextTheme().copyWith(
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: kWhite,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderSide: BorderSide(color: kWhite)),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const HabitScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
