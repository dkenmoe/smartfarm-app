import 'package:firstapp/models/died_record.dart';
import 'package:firstapp/services/died_record_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'died_form_screen.dart';

class DiedListScreen extends StatefulWidget {
  const DiedListScreen({Key? key}) : super(key: key);

  @override
  _DiedListScreenState createState() => _DiedListScreenState();
}

class _DiedListScreenState extends State<DiedListScreen> {
  List<DiedRecord> _diedRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiedRecords();
  }

  Future<void> _loadDiedRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await DiedRecordService.fetchDiedRecords();
      setState(() {
        _diedRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar("Failed to load death records: ${e.toString()}");
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

  void _navigateToAddDiedRecordScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiedFormScreen(),
      ),
    );

    if (result == true) {
      _loadDiedRecords();
    }
  }

  void _navigateToEditDiedRecordScreen(DiedRecord record) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiedFormScreen(diedRecord: record),
      ),
    );

    if (result == true) {
      _loadDiedRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Death Records",
          style: GoogleFonts.lato(fontSize: 20),
        ),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : _diedRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No death records found",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddDiedRecordScreen,
                        icon: Icon(Icons.add),
                        label: Text("Add Death Record"),
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
                  itemCount: _diedRecords.length,
                  itemBuilder: (context, index) {
                    final record = _diedRecords[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToEditDiedRecordScreen(record),
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
                                      "${record.animalTypeName ?? 'Unknown Type'} - ${record.breedName ?? 'Unknown Breed'}",
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
                                      color: _getStatusColor(record.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusText(record.status),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Date: ${record.dateOfDeath}",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    "Quantity: ${record.quantity}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Weight: ${record.weight} kg",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDiedRecordScreen,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'recorded':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'recorded':
        return 'Recorded';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}