import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/died_record.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/services/died_record_service.dart';
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DiedFormScreen extends StatefulWidget {
  final DiedRecord? diedRecord;
  final Function(DiedRecord)? onSubmit;

  const DiedFormScreen({Key? key, this.diedRecord, this.onSubmit})
      : super(key: key);

  @override
  _DiedFormScreenState createState() => _DiedFormScreenState();
}

class _DiedFormScreenState extends State<DiedFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  // Selected values
  DateTime _selectedDate = DateTime.now();
  int? _selectedAnimalTypeId;
  int? _selectedBreedId;
  String _status = 'recorded';
  
  // Data maps and lists
  Map<String, AnimalType> _animalTypeMap = {};
  Map<String, AnimalBreed> _breedMap = {};
  List<String> _animalTypeNames = [];
  List<String> _breedNames = [];
  String? _selectedAnimalTypeName;
  String? _selectedBreedName;
  
  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Status options
  final Map<String, String> _statusOptions = {
    'recorded': 'Recorded',
    'verified': 'Verified',
    'cancelled': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load animal types
      final animalTypes = await ApiService.fetchAnimalTypes();
      
      setState(() {
        _animalTypeMap = {for (var type in animalTypes) type.name: type};
        _animalTypeNames = _animalTypeMap.keys.toList();
        _isLoading = false;
      });
      
      // Set up the form for editing if a record was provided
      if (widget.diedRecord != null) {
        _setupFormForEditing();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FormWidgets.showSnackbar(
        context,
        "Failed to load data: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _setupFormForEditing() {
    final record = widget.diedRecord!;
    
    // Set text controllers
    _weightController.text = record.weight.toString();
    _quantityController.text = record.quantity.toString();
    
    // Set date
    try {
      _selectedDate = DateFormat('yyyy-MM-dd').parse(record.dateOfDeath);
    } catch (e) {
      _selectedDate = DateTime.now();
    }
    
    // Set animal type
    _selectedAnimalTypeId = record.animalTypeId;
    if (_selectedAnimalTypeId != null) {
      for (var type in _animalTypeMap.values) {
        if (type.id == _selectedAnimalTypeId) {
          _selectedAnimalTypeName = type.name;
          break;
        }
      }
      _loadBreeds().then((_) {
        // Set breed after breeds are loaded
        _selectedBreedId = record.breedId;
        for (var breed in _breedMap.values) {
          if (breed.id == _selectedBreedId) {
            _selectedBreedName = breed.name;
            break;
          }
        }
        setState(() {});
            });
    }
  }

  Future<void> _loadBreeds() async {
    if (_selectedAnimalTypeId == null) {
      setState(() {
        _selectedBreedId = null;
        _selectedBreedName = null;
        _breedNames = [];
        _breedMap = {};
      });
      return;
    }

    try {
      final breedList = await ApiService.fetchBreeds(
        animalTypeId: _selectedAnimalTypeId!,
      );
      setState(() {
        _breedMap = {for (var breed in breedList) breed.name: breed};
        _breedNames = _breedMap.keys.toList();
        if (_selectedBreedId == null) {
          _selectedBreedName = null;
        }
      });
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Error loading breeds: ${e.toString()}",
        Colors.red,
      );
    }
  }

  Future<void> _saveDiedRecord() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedAnimalTypeId == null || _selectedBreedId == null) {
      FormWidgets.showSnackbar(
        context,
        "Please select animal type and breed",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double weight = double.tryParse(_weightController.text) ?? 0;
      if (weight <= 0) {
        FormWidgets.showSnackbar(
          context,
          "Weight must be greater than zero",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      if (quantity <= 0) {
        FormWidgets.showSnackbar(
          context,
          "Quantity must be greater than zero",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final diedRecord = DiedRecord(
        id: widget.diedRecord?.id,
        animalTypeId: _selectedAnimalTypeId!,
        animalTypeName: _selectedAnimalTypeName,
        breedId: _selectedBreedId!,
        breedName: _selectedBreedName,
        weight: weight,
        quantity: quantity,
        dateOfDeath: DateFormat('yyyy-MM-dd').format(_selectedDate)
      );

      // Call the onSubmit callback if it's provided
      if (widget.onSubmit != null) {
        widget.onSubmit!(diedRecord);
        Navigator.pop(context, true);
        return;
      }

      bool success;
      if (widget.diedRecord == null) {
        // Create new record
        success = await DiedRecordService.createDiedRecord(diedRecord);
      } else {
        // Update existing record
        success = await DiedRecordService.updateDiedRecord(diedRecord);
      }

      if (success) {
        FormWidgets.showSnackbar(
          context,
          widget.diedRecord == null
              ? "Death record created successfully"
              : "Death record updated successfully",
          Colors.green,
        );

        // Return to the previous screen with success indicator
        Navigator.pop(context, true);
      } else {
        FormWidgets.showSnackbar(
          context, 
          "Failed to save death record", 
          Colors.red
        );
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      FormWidgets.showSnackbar(context, "Error: ${e.toString()}", Colors.red);
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _confirmDelete(int recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this death record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await DiedRecordService.deleteDiedRecord(recordId);
        if (success) {
          FormWidgets.showSnackbar(
            context,
            "Death record deleted successfully",
            Colors.green,
          );
          Navigator.pop(context, true);
        } else {
          FormWidgets.showSnackbar(
            context,
            "Failed to delete death record",
            Colors.red,
          );
          setState(() {
            _isSaving = false;
          });
        }
      } catch (e) {
        FormWidgets.showSnackbar(context, "Error: ${e.toString()}", Colors.red);
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.diedRecord == null ? "Register Death" : "Edit Death Record",
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animal type dropdown
                      FormWidgets.buildDropdown(
                        "Animal Type",
                        _animalTypeNames,
                        _selectedAnimalTypeName,
                        (value) {
                          setState(() {
                            _selectedAnimalTypeName = value;
                            if (value != null) {
                              _selectedAnimalTypeId = _animalTypeMap[value]!.id;
                              _loadBreeds();
                            } else {
                              _selectedAnimalTypeId = null;
                            }
                          });
                        },
                      ),

                      // Breed dropdown
                      FormWidgets.buildDropdown(
                        "Breed",
                        _breedNames,
                        _selectedBreedName,
                        (value) {
                          setState(() {
                            _selectedBreedName = value;
                            if (value != null) {
                              _selectedBreedId = _breedMap[value]!.id;
                            } else {
                              _selectedBreedId = null;
                            }
                          });
                        },
                      ),

                      // Quantity field
                      FormWidgets.buildTextField(
                        "Quantity",
                        _quantityController,
                        TextInputType.number,
                      ),

                      // Weight field
                      FormWidgets.buildTextField(
                        "Weight (kg)",
                        _weightController,
                        TextInputType.numberWithOptions(decimal: true),
                      ),

                      // Date picker
                      FormWidgets.buildDatePicker(
                        context,
                        "Date of Death",
                        _selectedDate,
                        (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),

                      // Status selection
                      FormWidgets.buildSegmentedControl<String>(
                        "Status",
                        _statusOptions,
                        _status,
                        (value) {
                          setState(() {
                            _status = value;
                          });
                        },
                      ),

                      SizedBox(height: 24),

                      // Save button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveDiedRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),

                      // Delete button (only in edit mode)
                      if (widget.diedRecord != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => _confirmDelete(widget.diedRecord!.id!),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}