import 'package:firstapp/screens/acquisition_records_screen.dart';
import 'package:firstapp/screens/acquisition_registration_screen.dart';
import 'package:firstapp/screens/animal_breeds_screen.dart';
import 'package:firstapp/screens/died_records_screen.dart';
import 'package:firstapp/screens/died_registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/screens/animal_inventory_screen.dart';
import 'package:firstapp/screens/birth_registration_screen.dart';
import 'package:firstapp/screens/birth_records_screen.dart';

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

      // Drawer restructuré avec des sous-modules
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
            
            // Module Production
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(Icons.agriculture, color: Colors.green),
              title: const Text(
                "Production",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                // Sous-module 1: Enregistrements
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text("Registration"),
                    children: [
                      // Register a birth
                      ListTile(
                        leading: Icon(Icons.add_circle_outline, color: Colors.green),
                        title: const Text("Register a birth"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          // Garde une référence au menu avant de naviguer
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => BirthRegistrationScreen()),
                          );
                        },
                      ),

                      // Register acquisition
                      ListTile(
                        leading: Icon(Icons.add_circle_outline, color: Colors.green),
                        title: const Text("Register a acquisition"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => AcquisitionRegistrationScreen()),
                          );
                        },
                      ),

                      // Register died
                      ListTile(
                        leading: Icon(Icons.add_circle_outline, color: Colors.green),
                        title: const Text("Register a died"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => DiedRegistrationScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Sous-module 2: Consultation
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text("Records"),
                    children: [
                      // Animals inventory
                      ListTile(
                        leading: Icon(Icons.list_alt, color: Colors.green),
                        title: const Text("Animals inventory"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => AnimalInventoryScreen()),
                          );
                        },
                      ),
                      
                      // Birth records
                      ListTile(
                        leading: Icon(Icons.baby_changing_station, color: Colors.green),
                        title: const Text("Birth records"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => BirthRecordsScreen()),
                          );
                        },
                      ),

                      // Acquisition records
                      ListTile(
                        leading: Icon(Icons.price_check, color: Colors.green),
                        title: const Text("Acquisition records"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => AcquisitionRecordsScreen()),
                          );
                        },
                      ),

                      // Animal breeds
                      ListTile(
                        leading: Icon(Icons.pets, color: Colors.green),
                        title: const Text("Animal breeds"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop(); // Ferme le drawer
                          nav.push(
                            MaterialPageRoute(builder: (context) => AnimalBreedsScreen()),
                          );
                        },
                      ),

                      // Died records
                      ListTile(
                        leading: Icon(Icons.pets, color: Colors.green),
                        title: const Text("Died records"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final NavigatorState nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(builder: (context) => DiedRecordsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Fonctionnalités à venir
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.bar_chart, color: Colors.grey),
                  title: const Text(
                    "Statistics",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 16),
                  onTap: null,
                ),
                
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.healing, color: Colors.grey),
                  title: const Text(
                    "Health records",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 16),
                  onTap: null,
                ),
              ],
            ),
            
            // Module Finance (à implémenter)
            ExpansionTile(
              enabled: false,
              leading: Icon(Icons.account_balance, color: Colors.grey),
              title: const Text(
                "Finance",
                style: TextStyle(color: Colors.grey),
              ),
              children: [
                // Placeholder pour implémentation future
              ],
            ),
            
            // Module Sales (à implémenter)
            ExpansionTile(
              enabled: false,
              leading: Icon(Icons.shopping_cart, color: Colors.grey),
              title: const Text(
                "Sales",
                style: TextStyle(color: Colors.grey),
              ),
              children: [
                // Placeholder pour implémentation future
              ],
            ),
            
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers l'écran de paramètres (à implémenter)
              },
            ),
          ],
        ),
      ),

      // Corps principal inchangé
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/images/smartfarm.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'Welcome to SmartFarm!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your comprehensive farm management solution',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'Open the menu to access all features',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Icon(Icons.menu, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}