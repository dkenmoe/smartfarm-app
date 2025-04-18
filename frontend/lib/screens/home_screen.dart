import 'package:firstapp/screens/acquisition_registration_screen.dart';
import 'package:firstapp/screens/animal_breeds_screen.dart';
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

      // Redesigned Navigation Drawer with expandable modules
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
            
            // Production Module (expanded by default)
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(Icons.agriculture, color: Colors.green),
              title: const Text(
                "Production",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                // Register a birth
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: Colors.green),
                  title: const Text("Register a birth"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BirthRegistrationScreen()),
                    );
                  },
                ),

                // Register acquisition
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: Colors.green),
                  title: const Text("Register a acquisition"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AcquisitionRegistrationScreen()),
                    );
                  },
                ),

                // Register died
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: Colors.green),
                  title: const Text("Register a died"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiedRegistrationScreen()),
                    );
                  },
                ),
                
                // Animals inventory
                ListTile(
                  leading: Icon(Icons.list_alt, color: Colors.green),
                  title: const Text("Animals inventory"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnimalInventoryScreen()),
                    );
                  },
                ),
                
                // Birth records (new)
                ListTile(
                  leading: Icon(Icons.baby_changing_station, color: Colors.green),
                  title: const Text("Birth records"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BirthRecordsScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(Icons.pets, color: Colors.green),
                  title: const Text("Animal breeds"),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnimalBreedsScreen()),
                    );
                  },
                ),
                
                // Statistics (to be implemented)
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.bar_chart, color: Colors.grey),
                  title: const Text(
                    "Statistics",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: null,
                ),
                
                // Health records (to be implemented)
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.healing, color: Colors.grey),
                  title: const Text(
                    "Health records",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 30),
                  onTap: null,
                ),
              ],
            ),
            
            // Finance Module (to be implemented)
            ExpansionTile(
              enabled: false,
              leading: Icon(Icons.account_balance, color: Colors.grey),
              title: const Text(
                "Finance",
                style: TextStyle(color: Colors.grey),
              ),
              children: [
                // Placeholder for future implementation
              ],
            ),
            
            // Sales Module (to be implemented)
            ExpansionTile(
              enabled: false,
              leading: Icon(Icons.shopping_cart, color: Colors.grey),
              title: const Text(
                "Sales",
                style: TextStyle(color: Colors.grey),
              ),
              children: [
                // Placeholder for future implementation
              ],
            ),
            
            // Divider and other potential menu items
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title: const Text("Settings"),
              onTap: () {
                // Navigate to settings screen (to be implemented)
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // Main body remains the same
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