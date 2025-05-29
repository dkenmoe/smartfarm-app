import 'package:firstapp/models/animal/animal.dart';
import 'package:firstapp/models/farm.dart';
import 'package:firstapp/services/animal_service.dart';
import 'package:firstapp/services/farm_service.dart';
import 'package:firstapp/screens/animal/animal_form_screen.dart';
import 'package:firstapp/widgets/list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  List<Animal> _animals = [];
  List<Farm> _farms = [];
  int? selectedFarmId;
  String? selectedFarmName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmsAndAnimals();
  }

  Future<void> _loadFarmsAndAnimals() async {
    setState(() => _isLoading = true);
    try {
      _farms = await FarmService.fetchUserFarms();
      if (_farms.isNotEmpty) {
        selectedFarmId = _farms.first.id;
        selectedFarmName = _farms.first.name;
        await _loadAnimals();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar("Failed to load farms or animals: ${e.toString()}");
    }
  }

  Future<void> _loadAnimals() async {
    if (selectedFarmId == null) return;
    final results = await AnimalService.fetchAnimals(farmId: selectedFarmId);
    setState(() {
      _animals = results;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToAddAnimalScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimalFormScreen()),
    );
    if (result == true) _loadAnimals();
  }

  void _navigateToEditAnimalScreen(Animal animal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnimalFormScreen(animal: animal)),
    );
    if (result == true) _loadAnimals();
  }

  void _showAnimalDetails(Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pets, color: Colors.green),
            SizedBox(width: 8),
            Text("Animal Details", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.badge, color: Colors.teal),
                title: Text("Tracking ID"),
                subtitle: Text(animal.trackingId),
              ),
              ListTile(
                leading: Icon(Icons.category, color: Colors.indigo),
                title: Text("Animal Type"),
                subtitle: Text(animal.animalTypeName ?? 'N/A'),
              ),
              ListTile(
                leading: Icon(Icons.pets, color: Colors.orange),
                title: Text("Breed"),
                subtitle: Text(animal.breedName ?? 'N/A'),
              ),
              ListTile(
                leading: Icon(Icons.family_restroom, color: Colors.purple),
                title: Text("Gender"),
                subtitle: Text(animal.gender),
              ),
              ListTile(
                leading: Icon(Icons.flag, color: Colors.blueGrey),
                title: Text("Status"),
                subtitle: Text(animal.status),
              ),
              ListTile(
                leading: Icon(Icons.home_work, color: Colors.green),
                title: Text("Farm"),
                subtitle: Text(animal.farmName ?? 'N/A'),
              ),
              if (animal.dateOfBirth != null)
                ListTile(
                  leading: Icon(Icons.cake, color: Colors.pinkAccent),
                  title: Text("Date of Birth"),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(animal.dateOfBirth!)),
                ),
              if (animal.dateOfAcquisition != null)
                ListTile(
                  leading: Icon(Icons.event_available, color: Colors.blue),
                  title: Text("Date of Acquisition"),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(animal.dateOfAcquisition!)),
                ),
              if (animal.lastWeighDate != null)
                ListTile(
                  leading: Icon(Icons.scale, color: Colors.deepOrange),
                  title: Text("Last Weigh Date"),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(animal.lastWeighDate!)),
                ),
              if (animal.initialWeight != null)
                ListTile(
                  leading: Icon(Icons.monitor_weight, color: Colors.grey),
                  title: Text("Initial Weight"),
                  subtitle: Text("${animal.initialWeight} kg"),
                ),
              if (animal.currentWeight != null)
                ListTile(
                  leading: Icon(Icons.monitor_weight_outlined, color: Colors.teal),
                  title: Text("Current Weight"),
                  subtitle: Text("${animal.currentWeight} kg"),
                ),
              if (animal.notes != null && animal.notes!.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.note_alt, color: Colors.brown),
                  title: Text("Notes"),
                  subtitle: Text(animal.notes!),
                ),
              if (animal.createdBy != null)
                ListTile(
                  leading: Icon(Icons.person, color: Colors.cyan),
                  title: Text("Created By"),
                  subtitle: Text(animal.createdBy!),
                ),
              if (animal.createdAt != null)
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                  title: Text("Created At"),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(animal.createdAt!)),
                ),
              if (animal.updatedAt != null)
                ListTile(
                  leading: Icon(Icons.update, color: Colors.amber),
                  title: Text("Last Updated"),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(animal.updatedAt!)),
                ),
              if (animal.qrCodeUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Image.network(animal.qrCodeUrl!, height: 100)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            label: Text("Close"),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Animals", style: GoogleFonts.lato(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset('assets/images/smartfarm_2_16x16.png', width: 24, height: 24),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                if (_farms.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedFarmName,
                      decoration: InputDecoration(
                        labelText: 'Select Farm',
                        prefixIcon: Icon(Icons.agriculture, color: Colors.green),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _farms.map((farm) {
                        return DropdownMenuItem(
                          value: farm.name,
                          child: Text(farm.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        final farm = _farms.firstWhere((f) => f.name == val);
                        setState(() {
                          selectedFarmName = val;
                          selectedFarmId = farm.id;
                        });
                        _loadAnimals();
                      },
                    ),
                  ),
                Expanded(
                  child: _animals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.pets, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("No animals found", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                              SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _navigateToAddAnimalScreen,
                                icon: Icon(Icons.add),
                                label: Text("Add Animal"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _animals.length,
                          itemBuilder: (context, index) {
                            final animal = _animals[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${animal.animalTypeName ?? 'Type'} - ${animal.breedName ?? 'Breed'}",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            animal.status,
                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    ListWidgets.BuildCountBadge(Icons.person, Colors.redAccent, "ID: ${animal.trackingId}"),
                                    if (animal.currentWeight != null)
                                      SizedBox(height: 4),
                                    ListWidgets.BuildCountBadge(Icons.scale, Colors.indigo, "Current Weight: ${animal.currentWeight} kg"),
                                    SizedBox(height: 4),
                                    if (animal.gender.isNotEmpty)
                                      ListWidgets.BuildCountBadge(
                                        animal.gender == "Male" ? Icons.male : Icons.female,
                                        animal.gender == "Male" ? Colors.blue : Colors.pink,
                                        "Gender: ${animal.gender}",
                                      ),
                                    if (animal.dateOfBirth != null)
                                      ListWidgets.BuildCountBadge(
                                        Icons.calendar_view_day,
                                        Colors.green,
                                        "Birth Date: ${DateFormat('yyyy-MM-dd').format(animal.dateOfBirth!)}",
                                      ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => _showAnimalDetails(animal),
                                          child: Text("View"),
                                        ),
                                        TextButton(
                                          onPressed: () => _navigateToEditAnimalScreen(animal),
                                          child: Text("Edit"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAnimalScreen,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
