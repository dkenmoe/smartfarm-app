import 'package:firstapp/screens/acquisition/acquisition_form_screen.dart';
import 'package:firstapp/screens/acquisition/acquisition_list_screen.dart';
import 'package:firstapp/screens/animal_breeds_list_screen.dart';
import 'package:firstapp/screens/animal_inventory_list_screen.dart';
import 'package:firstapp/screens/birth/birth_form_screen.dart';
import 'package:firstapp/screens/birth/birth_list_screen.dart';
import 'package:firstapp/screens/died/died_form_screen.dart';
import 'package:firstapp/screens/died/died_list_screen.dart';
import 'package:firstapp/screens/finance/expense_form_screen.dart';
import 'package:firstapp/screens/finance/expenses_list_screen.dart';
import 'package:firstapp/services/acquisition_service.dart';
import 'package:firstapp/services/birth_service.dart';
import 'package:firstapp/services/died_record_service.dart';
import 'package:firstapp/services/expense_service.dart';
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

            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(Icons.agriculture, color: Colors.green),
              title: const Text(
                "Production",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text("Registration"),
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        title: const Text("Register a birth"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder:
                                  (context) => BirthFormScreen(
                                    onSubmit: (birthRecord) async {
                                      await BirthService.registerBirth(
                                        birthRecord,
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        title: const Text("Register a acquisition"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder:
                                  (context) => AcquisitionFormScreen(
                                    onSubmit: (expense) async {
                                      await AcquisitionService.createAcquisition(
                                        expense,
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: Colors.green,
                        ),
                        title: const Text("Register a died"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder:
                                  (context) => DiedFormScreen(
                                    onSubmit: (diedRecord) async {
                                      await DiedRecordService.createDiedRecord(
                                        diedRecord,
                                      );
                                    },
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ExpansionTile(
                    initiallyExpanded: false,
                    title: const Text("Records"),
                    children: [
                      ListTile(
                        leading: Icon(Icons.list, color: Colors.green),
                        title: const Text("Animals Inventory"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => AnimalInventoryListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list, color: Colors.green),
                        title: const Text("Birth List"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => BirthListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list, color: Colors.green),
                        title: const Text("Acquisition List"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => AcquisitionListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list, color: Colors.green),
                        title: const Text("Animal breeds"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => AnimalBreedsListScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list, color: Colors.green),
                        title: const Text("Died records"),
                        contentPadding: EdgeInsets.only(left: 32),
                        onTap: () {
                          final nav = Navigator.of(context);
                          nav.pop();
                          nav.push(
                            MaterialPageRoute(
                              builder: (context) => DiedListScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.bar_chart, color: Colors.grey),
                  title: const Text(
                    "Statistics",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 16),
                ),
                ListTile(
                  enabled: false,
                  leading: Icon(Icons.healing, color: Colors.grey),
                  title: const Text(
                    "Health records",
                    style: TextStyle(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.only(left: 16),
                ),
              ],
            ),

            ExpansionTile(
              leading: Icon(Icons.account_balance, color: Colors.green),
              title: const Text(
                "Finance",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  leading: Icon(Icons.list, color: Colors.green),
                  title: const Text("Expenses List"),
                  contentPadding: EdgeInsets.only(left: 32),
                  onTap: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.push(
                      MaterialPageRoute(
                        builder: (context) => ExpenseListScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add, color: Colors.green),
                  title: const Text("Add Expense"),
                  contentPadding: EdgeInsets.only(left: 32),
                  onTap: () {
                    final nav = Navigator.of(context);
                    nav.pop();
                    nav.push(
                      MaterialPageRoute(
                        builder:
                            (context) => ExpenseFormScreen(
                              onSubmit: (expense) async {
                                await ExpenseService().createExpense(expense);
                              },
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),

            ExpansionTile(
              enabled: false,
              leading: Icon(Icons.shopping_cart, color: Colors.grey),
              title: const Text("Sales", style: TextStyle(color: Colors.grey)),
            ),

            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
              style: TextStyle(fontSize: 16, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'Open the menu to access all features',
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
