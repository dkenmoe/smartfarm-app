import 'package:flutter/material.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/models/animal_breed.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimalBreedsScreen extends StatefulWidget {
  const AnimalBreedsScreen({super.key});

  @override
  _AnimalBreedsScreenState createState() => _AnimalBreedsScreenState();
}

class _AnimalBreedsScreenState extends State<AnimalBreedsScreen> {
  late Future<List<AnimalBreed>> _animalBreeds;
  late List<ColumnDefinition> _columnDefinitions;

  @override
  void initState() {
    super.initState();
    _animalBreeds = ApiService.fetchBreeds();

    _columnDefinitions = [
      ColumnDefinition(
        id: 'animalType',
        label: 'Animal Type',
        visible: true,
        accessor: (breed) => breed.animalTypeName!,
        widget: null,
      ),
      ColumnDefinition(
        id: 'name',
        label: 'Name',
        visible: true,
        accessor: (breed) => breed.name,
        widget: null,
      ),
      ColumnDefinition(
        id: 'description',
        label: 'Description',
        visible: true,
        accessor: (breed) => breed.description ?? 'No description',
        widget: null,
      ),
      ColumnDefinition(
        id: 'image',
        label: 'Image',
        visible: true,
        accessor: (breed) => '',
        widget: (context, breed) {
          return breed.image != null
              ? GestureDetector(
                onTap: () {
                  _showFullImage(context, breed);
                },
                child: CachedNetworkImage(
                  imageUrl: breed.thumbnail ?? '',
                  placeholder:
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget:
                      (context, url, error) => const Icon(Icons.broken_image),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
              : const Text('No image');
        },
      ),
    ];
  }

  // Show full image dialog
  void _showFullImage(BuildContext context, AnimalBreed breed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(breed.name),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: breed.image ?? '',
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
              if (breed.description != null && breed.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    breed.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
                  children:
                      _columnDefinitions.map((column) {
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
        title: const Text('Animal Breeds'),
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
      body: FutureBuilder<List<AnimalBreed>>(
        future: _animalBreeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No animal breeds found."));
          }

          final breeds = snapshot.data!;

          // Get only visible columns
          final visibleColumns =
              _columnDefinitions.where((column) => column.visible).toList();

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
                          (states) => Colors.green.shade100,
                        ),
                        columns:
                            visibleColumns
                                .map(
                                  (column) => DataColumn(
                                    label: Text(
                                      column.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        rows:
                            breeds
                                .map(
                                  (breed) => DataRow(
                                    cells:
                                        visibleColumns
                                            .map(
                                              (column) => DataCell(
                                                column.widget != null
                                                    ? column.widget!(
                                                      context,
                                                      breed,
                                                    )
                                                    : Text(
                                                      column.accessor(breed),
                                                    ),
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
  final String Function(AnimalBreed) accessor;
  final Widget Function(BuildContext, AnimalBreed)? widget;

  const ColumnDefinition({
    required this.id,
    required this.label,
    required this.visible,
    required this.accessor,
    this.widget,
  });

  // Create a copy with updated values
  ColumnDefinition copyWith({
    String? id,
    String? label,
    bool? visible,
    String Function(AnimalBreed)? accessor,
    Widget Function(BuildContext, AnimalBreed)? widget,
  }) {
    return ColumnDefinition(
      id: id ?? this.id,
      label: label ?? this.label,
      visible: visible ?? this.visible,
      accessor: accessor ?? this.accessor,
      widget: widget ?? this.widget,
    );
  }
}
