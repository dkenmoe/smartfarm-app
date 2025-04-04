import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Permet d'utiliser async dans main()
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');

  runApp(SmartFarmApp(isLoggedIn: token != null)); 
}

class SmartFarmApp extends StatelessWidget {
  final bool isLoggedIn;
  const SmartFarmApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFarm',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
