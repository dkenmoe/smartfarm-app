import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/models/farm.dart';
import 'package:firstapp/screens/birth/birth_form_screen.dart';
import 'package:firstapp/services/birth_service.dart';
import 'package:firstapp/services/farm_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BirthListScreen extends StatefulWidget {
  const BirthListScreen({Key? key}) : super(key: key);

  @override
  _BirthListScreenState createState() => _BirthListScreenState();
}

class _BirthListScreenState extends State<BirthListScreen> {
  List<BirthRecord> _records = [];
  List<Farm> _farms = [];
  int? selectedFarmId;
  String? selectedFarmName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmsAndRecords();
  }

  Future<void> _loadFarmsAndRecords() async {
    setState(() => _isLoading = true);
    try {
      _farms = await FarmService.fetchUserFarms();
      if (_farms.isNotEmpty) {
        selectedFarmId = _farms.first.id;
        selectedFarmName = _farms.first.name;
        await _loadBirthRecords();
      }
    } catch (e) {
      _showErrorSnackbar("Failed to load farms or records: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBirthRecords() async {
    if (selectedFarmId == null) return;
    final results = await BirthService.fetchBirthRecords(
      farmId: selectedFarmId,
    );
    setState(() => _records = results);
  }

  void _navigateToForm({BirthRecord? record}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BirthFormScreen(
              birthRecord: record,
              onSubmit: (_) => _loadBirthRecords(),
            ),
      ),
    );
  }

  void _showDetails(BirthRecord record) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.cake, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Birth Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _info(
                    "Date",
                    DateFormat('yyyy-MM-dd').format(record.dateOfBirth!),
                  ),
                  _info("Animal Type", record.animalTypeName ?? 'N/A'),
                  _info("Breed", record.breedName ?? 'N/A'),
                  _info("Males", record.numberOfMale.toString()),
                  _info("Females", record.numberOfFemale.toString()),
                  _info("Died", record.numberOfDied.toString()),
                  if (record.weight != null)
                    _info("Weight", "${record.weight} kg"),
                  if (record.notes?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note_alt, color: Colors.brown),
                              SizedBox(width: 8),
                              Text(
                                "Notes",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              border: Border.all(color: Colors.brown.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record.notes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.brown.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (record.createdBy != null)
                    _info("Created By", record.createdBy!),
                  if (record.createdAt != null)
                    _info(
                      "Created At",
                      DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt!),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                label: Text("Close"),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.label, size: 16, color: Colors.teal),
          SizedBox(width: 8),
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Birth Records", style: GoogleFonts.lato(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
      ),
      body:
          _isLoading
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
                          prefixIcon: Icon(
                            Icons.agriculture,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            _farms.map((farm) {
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
                          _loadBirthRecords();
                        },
                      ),
                    ),
                  Expanded(
                    child:
                        _records.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cake,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No birth records found",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _records.length,
                              itemBuilder: (context, index) {
                                final record = _records[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${record.animalTypeName ?? 'Type'} - ${record.breedName ?? 'Breed'}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                DateFormat(
                                                  'yyyy-MM-dd',
                                                ).format(record.dateOfBirth!),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green[900],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),

                                        /// 👇 Updated section with animal-context icons
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.male,
                                              color: Colors.teal,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "M: ${record.numberOfMale}",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.female,
                                              color: Colors.deepOrangeAccent,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "F: ${record.numberOfFemale}",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "Died: ${record.numberOfDied}",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        if (record.weight != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.scale,
                                                  color: Colors.blueGrey,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Weight: ${record.weight} kg",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed:
                                                  () => _showDetails(record),
                                              child: Text("View"),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => _navigateToForm(
                                                    record: record,
                                                  ),
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
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
