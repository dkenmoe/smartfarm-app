import 'package:firstapp/models/acquisition_record.dart';
import 'package:firstapp/screens/acquisition/acquisition_form_screen.dart';
import 'package:firstapp/services/acquisition_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AcquisitionListScreen extends StatefulWidget {
  const AcquisitionListScreen({Key? key}) : super(key: key);

  @override
  _AcquisitionListScreenState createState() => _AcquisitionListScreenState();
}

class _AcquisitionListScreenState extends State<AcquisitionListScreen> {
  List<AcquisitionRecord> _acquisitions = [];
  bool _isLoading = true;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadAcquisitions();
  }

  Future<void> _loadAcquisitions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Assuming ApiService has a method to fetch acquisitions
      final acquisitions = await AcquisitionService.fetchAcquisitions();
      setState(() {
        _acquisitions = acquisitions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar("Failed to load acquisitions: ${e.toString()}");
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

  void _navigateToAddAcquisitionScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AcquisitionFormScreen()),
    );

    if (result == true) {
      _loadAcquisitions();
    }
  }

  void _navigateToEditAcquisitionScreen(AcquisitionRecord acquisition) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AcquisitionFormScreen(acquisition: acquisition),
      ),
    );

    if (result == true) {
      _loadAcquisitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Acquisitions", style: GoogleFonts.lato(fontSize: 20)),
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
              : _acquisitions.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No acquisitions found",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddAcquisitionScreen,
                      icon: Icon(Icons.add),
                      label: Text("Add Acquisition"),
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
                itemCount: _acquisitions.length,
                itemBuilder: (context, index) {
                  final acquisition = _acquisitions[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap:
                          () => _navigateToEditAcquisitionScreen(acquisition),
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
                                    "${acquisition.animalTypeName ?? 'Unknown'} - ${acquisition.breedName ?? 'Unknown'}",
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
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    acquisition.gender,
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
                                  "Date: ${acquisition.dateOfAcquisition}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  "${_currencyFormat.format(acquisition.unitPreis)} FCFA/unit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quantity: ${acquisition.quantity}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                if (acquisition.weight != null)
                                  Text(
                                    "Weight: ${acquisition.weight} kg",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Total: ${_currencyFormat.format(acquisition.quantity * acquisition.unitPreis)} FCFA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
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
        onPressed: _navigateToAddAcquisitionScreen,
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
