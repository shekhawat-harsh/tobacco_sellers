import 'package:tobacco_sellers/screens/home_page.dart';
import 'package:tobacco_sellers/screens/login_page.dart';
import 'package:tobacco_sellers/screens/onboarding_Screen.dart';
import 'package:tobacco_sellers/screens/splash_screen.dart';
import 'package:tobacco_sellers/const/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper().initialize();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home:  SplashScreen(),
      // home: HomePage(),
      routes: <String, WidgetBuilder>{
        '/onboarding': (BuildContext context) => const OnboardingScreen(),
        '/signup': (BuildContext context) => const LoginPage()
      },
    );
  }
}


