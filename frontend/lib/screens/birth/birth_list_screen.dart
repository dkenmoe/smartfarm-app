import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/services/birth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'birth_form_screen.dart';

class BirthListScreen extends StatefulWidget {
  const BirthListScreen({Key? key}) : super(key: key);

  @override
  _BirthListScreenState createState() => _BirthListScreenState();
}

class _BirthListScreenState extends State<BirthListScreen> {
  List<BirthRecord> _birthRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBirthRecords();
  }

  Future<void> _loadBirthRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final birthRecords = await BirthService.fetchBirthRecords();
      setState(() {
        _birthRecords = birthRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar("Failed to load birth records: ${e.toString()}");
    }
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

  void _navigateToAddBirthRecordScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BirthFormScreen()),
    );

    if (result == true) {
      _loadBirthRecords();
    }
  }

  void _navigateToEditBirthRecordScreen(BirthRecord birthRecord) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BirthFormScreen(birthRecord: birthRecord),
      ),
    );

    if (result == true) {
      _loadBirthRecords();
    }
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
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.green))
              : _birthRecords.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No birth records found",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddBirthRecordScreen,
                      icon: Icon(Icons.add),
                      label: Text("Add Birth Record"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _birthRecords.length,
                itemBuilder: (context, index) {
                  final birthRecord = _birthRecords[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap:
                          () => _navigateToEditBirthRecordScreen(birthRecord),
                      borderRadius: BorderRadius.circular(12),
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
                                    "${birthRecord.animalTypeName ?? 'Unknown'} - ${birthRecord.breedName ?? 'Unknown Breed'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Weight: ${birthRecord.weight}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Date: ${birthRecord.dateOfBirth}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                _buildCountBadge(
                                  Icons.male,
                                  Colors.blue,
                                  "Male: ${birthRecord.number_of_male}",
                                ),
                                SizedBox(width: 8),
                                _buildCountBadge(
                                  Icons.female,
                                  Colors.pink,
                                  "Female: ${birthRecord.number_of_female}",
                                ),
                                if (birthRecord.number_of_died > 0) ...[
                                  SizedBox(width: 8),
                                  _buildCountBadge(
                                    Icons.error_outline,
                                    Colors.red,
                                    "Died: ${birthRecord.number_of_died}",
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Total births: ${birthRecord.number_of_male + birthRecord.number_of_female + birthRecord.number_of_died}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBirthRecordScreen,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCountBadge(IconData icon, Color color, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
