import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:maze_tales_multiplatform/firebase/firebase_options.dart';
import 'package:maze_tales_multiplatform/screens/game_container_screen.dart';
import 'package:maze_tales_multiplatform/screens/splash_screen.dart';
import 'package:page_transition/page_transition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Flame.device.setLandscapeLeftOnly();

  // runApp(const GameContainerScreen());

  runApp(
    MaterialApp(
      home: AnimatedSplashScreen(
        duration: 10000,
        splash: const SplashScreen(),
        nextScreen: const GameContainerScreen(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        splashIconSize: double.infinity,
        backgroundColor: Colors.white,
      ),
    ),
  );
}
