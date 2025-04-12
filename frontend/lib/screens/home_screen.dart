import 'package:firstapp/screens/animal_inventory_screen.dart';
import 'package:firstapp/screens/birth_registration_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFarm'),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset(
              'assets/images/smartfarm_2_16x16.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),

      // Ajout du Navigation Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/smartfarm.png', width: 80),
                  const SizedBox(height: 10),
                  const Text(
                    "SmartFarm Menu",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: Colors.green),
              title: const Text("Register a birth"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BirthRegistrationScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list, color: Colors.green),
              title: const Text("Animals inventory"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnimalInventoryScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // Corps principal de la page d'accueil
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/smartfarm.png', width: 150),
            const Text(
              'Welcome to SmartFarm!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
