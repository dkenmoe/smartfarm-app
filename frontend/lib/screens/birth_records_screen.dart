import 'package:flutter/material.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/models/birth_record.dart';

class BirthRecordsScreen extends StatefulWidget {
  const BirthRecordsScreen({super.key});

  @override
  _BirthRecordsScreenState createState() => _BirthRecordsScreenState();
}

class _BirthRecordsScreenState extends State<BirthRecordsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<BirthRecord>> _birthRecords;
  
  // Define column definitions with their labels and field accessors
  final List<ColumnDefinition> _columnDefinitions = [
    ColumnDefinition(
      id: 'animalType',
      label: 'Animal Type',
      visible: true,
      accessor: (record) => record.animalTypeName!,
    ),
    ColumnDefinition(
      id: 'breed',
      label: 'Breed',
      visible: true,
      accessor: (record) => record.breedName!,
    ),
    ColumnDefinition(
      id: 'male',
      label: 'Males',
      visible: true,
      accessor: (record) => record.number_of_male.toString(),
    ),
    ColumnDefinition(
      id: 'female',
      label: 'Females',
      visible: true,
      accessor: (record) => record.number_of_female.toString(),
    ),
    ColumnDefinition(
      id: 'died',
      label: 'Died',
      visible: true, 
      accessor: (record) => record.number_of_died.toString(),
    ),
    ColumnDefinition(
      id: 'total',
      label: 'Total',
      visible: true,
      accessor: (record) => (record.number_of_male + record.number_of_female + record.number_of_died).toString(),
    ),
    ColumnDefinition(
      id: 'weight',
      label: 'Weight',
      visible: true,
      accessor: (record) => record.weight.toString()
    ),
    ColumnDefinition(
      id: 'date',
      label: 'Date of Birth',
      visible: true,
      accessor: (record) => record.dateOfBirth,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _birthRecords = apiService.fetchBirthRecords();
  }

  // Toggle column visibility
  void _toggleColumnVisibility(String columnId) {
    setState(() {
      final index = _columnDefinitions.indexWhere((col) => col.id == columnId);
      if (index != -1) {
        _columnDefinitions[index] = _columnDefinitions[index].copyWith(
          visible: !_columnDefinitions[index].visible,
        );
      }
    });
  }

  // Show dialog to manage column visibility
  void _showColumnVisibilityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Show/Hide Columns'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _columnDefinitions.map((column) {
                    return CheckboxListTile(
                      title: Text(column.label),
                      value: column.visible,
                      onChanged: (bool? value) {
                        setState(() {
                          _toggleColumnVisibility(column.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Records'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [          
          // Add a button to control column visibility
          IconButton(
            icon: const Icon(Icons.view_column),
            onPressed: _showColumnVisibilityDialog,
            tooltip: 'Show/Hide Columns',
          ),
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
      body: FutureBuilder<List<BirthRecord>>(
        future: _birthRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No birth records found."));
          }

          final records = snapshot.data!;
          
          // Get only visible columns
          final visibleColumns = _columnDefinitions.where((column) => column.visible).toList();
          
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information text about column visibility
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Showing ${visibleColumns.length} of ${_columnDefinitions.length} columns',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                // The data table with scrolling
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        border: TableBorder.all(color: Colors.grey.shade300),
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) => Colors.green.shade100),
                        columns: visibleColumns
                            .map(
                              (column) => DataColumn(
                                label: Text(
                                  column.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                            .toList(),
                        rows: records
                            .map(
                              (record) => DataRow(
                                cells: visibleColumns
                                    .map(
                                      (column) => DataCell(
                                        Text(column.accessor(record)),
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// A class to define table columns
class ColumnDefinition {
  final String id;
  final String label;
  final bool visible;
  final String Function(BirthRecord) accessor;

  const ColumnDefinition({
    required this.id,
    required this.label,
    required this.visible,
    required this.accessor,
  });

  // Create a copy with updated values
  ColumnDefinition copyWith({
    String? id,
    String? label,
    bool? visible,
    String Function(BirthRecord)? accessor,
  }) {
    return ColumnDefinition(
      id: id ?? this.id,
      label: label ?? this.label,
      visible: visible ?? this.visible,
      accessor: accessor ?? this.accessor,
    );
  }
}