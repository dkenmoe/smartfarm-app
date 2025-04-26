import 'package:firstapp/models/acquisition_record.dart';
import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/services/acquisition_service.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AcquisitionFormScreen extends StatefulWidget {
  final AcquisitionRecord? acquisition;
  final Function(AcquisitionRecord)? onSubmit;

  const AcquisitionFormScreen({Key? key, this.acquisition, this.onSubmit})
    : super(key: key);

  @override
  _AcquisitionFormScreenState createState() => _AcquisitionFormScreenState();
}

class _AcquisitionFormScreenState extends State<AcquisitionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPreisController = TextEditingController();

  // Selected values
  DateTime selectedDate = DateTime.now();
  int? selectedAnimalTypeId;
  int? selectedBreedId;
  String? selectedGender;

  // Data lists
  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};
  List<String> animalTypeNames = [];
  List<String> breedNames = [];
  List<String> genderOptions = ["Male", "Female"];

  String? selectedAnimalTypeName;
  String? selectedBreedName;

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

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
      await _loadAnimalTypes();

      // Set up the form for editing if acquisition record was provided
      if (widget.acquisition != null) {
        _setupFormForEditing();
      }

      setState(() {
        _isLoading = false;
      });
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

  Future<void> _loadAnimalTypes() async {
    try {
      List<AnimalType> types = await ApiService.fetchAnimalTypes();
      setState(() {
        animalTypeMap = {for (var type in types) type.name: type};
        animalTypeNames = animalTypeMap.keys.toList();
      });
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Error loading animal types: ${e.toString()}",
        Colors.red,
      );
    }
  }

  Future<void> _loadBreeds() async {
    if (selectedAnimalTypeId == null) {
      setState(() {
        selectedBreedId = null;
        selectedBreedName = null;
        breedNames = [];
      });
      return;
    }

    try {
      List<AnimalBreed> breedList = await ApiService.fetchBreeds(
        animalTypeId: selectedAnimalTypeId!,
      );
      setState(() {
        breedMap = {for (var breed in breedList) breed.name: breed};
        breedNames = breedMap.keys.toList();
        selectedBreedName = null;
        selectedBreedId = null;
      });
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Error loading breeds: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _setupFormForEditing() {
    final acquisition = widget.acquisition!;

    // Set text controllers
    if (acquisition.weight != null) {
      weightController.text = acquisition.weight.toString();
    }
    quantityController.text = acquisition.quantity.toString();
    unitPreisController.text = acquisition.unitPreis.toString();

    // Set date
    try {
      selectedDate = DateFormat(
        'yyyy-MM-dd',
      ).parse(acquisition.dateOfAcquisition);
    } catch (e) {
      selectedDate = DateTime.now();
    }

    // Set animal type
    selectedAnimalTypeId = acquisition.animalTypeId;
    if (selectedAnimalTypeId != null) {
      for (var type in animalTypeMap.entries) {
        if (type.value.id == selectedAnimalTypeId) {
          selectedAnimalTypeName = type.key;
          break;
        }
      }

      // Load breeds and then set breed
      _loadBreeds().then((_) {
        setState(() {
          selectedBreedId = acquisition.breedId;
          if (selectedBreedId != null) {
            for (var breed in breedMap.entries) {
              if (breed.value.id == selectedBreedId) {
                selectedBreedName = breed.key;
                break;
              }
            }
          }
        });
      });
    }

    // Set gender
    selectedGender = acquisition.gender;
  }

  Future<void> _saveAcquisition() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (selectedAnimalTypeId == null ||
        selectedBreedId == null ||
        selectedGender == null) {
      FormWidgets.showSnackbar(
        context,
        "Please fill in all required fields.",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int quantity = int.tryParse(quantityController.text) ?? 0;
      if (quantity <= 0) {
        FormWidgets.showSnackbar(
          context,
          "The quantity must be greater than zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      double weight = double.tryParse(weightController.text) ?? 0;
      if (weight <= 0) {
        FormWidgets.showSnackbar(
          context,
          "The weight must be greater than zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      double unitPreis = double.tryParse(unitPreisController.text) ?? 0;
      if (unitPreis <= 0) {
        FormWidgets.showSnackbar(
          context,
          "The unit price must be greater than zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      AcquisitionRecord acquisitionRecord = AcquisitionRecord(
        animalTypeId: selectedAnimalTypeId!,
        breedId: selectedBreedId!,
        quantity: quantity,
        weight: weight,
        gender: selectedGender!,
        unitPreis: unitPreis,
        dateOfAcquisition: DateFormat('yyyy-MM-dd').format(selectedDate),
      );

      // Call the onSubmit callback if it's provided
      if (widget.onSubmit != null) {
        widget.onSubmit!(acquisitionRecord);
        Navigator.pop(context, true);
        return;
      }

      bool success;
      if (widget.acquisition == null) {
        // Create new acquisition
        success = await AcquisitionService.createAcquisition(acquisitionRecord);
      } else {
        // Update existing acquisition (assuming API service has an update method)
        // Implementation depends on your API service
        success = await AcquisitionService.updateAcquisition(acquisitionRecord);
      }

      if (success) {
        FormWidgets.showSnackbar(
          context,
          widget.acquisition == null
              ? "Acquisition successfully registered!"
              : "Acquisition successfully updated!",
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        FormWidgets.showSnackbar(context, "Error while saving.", Colors.red);
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Exception: ${e.toString()}",
        Colors.red,
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _confirmDelete(int acquisitionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text(
              "Are you sure you want to delete this acquisition record?",
            ),
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
        // Assuming API service has a delete method
        final success = await AcquisitionService.deleteAcquisition(
          acquisitionId,
        );
        if (success) {
          FormWidgets.showSnackbar(
            context,
            "Acquisition deleted successfully",
            Colors.green,
          );
          Navigator.pop(context, true);
        } else {
          FormWidgets.showSnackbar(
            context,
            "Failed to delete acquisition",
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
          widget.acquisition == null
              ? "Register Acquisition"
              : "Edit Acquisition",
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
      body:
          _isLoading
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
                          animalTypeNames,
                          selectedAnimalTypeName,
                          (value) {
                            setState(() {
                              selectedAnimalTypeName = value;
                              if (value != null) {
                                selectedAnimalTypeId = animalTypeMap[value]!.id;
                                _loadBreeds();
                              } else {
                                selectedAnimalTypeId = null;
                              }
                            });
                          },
                        ),

                        // Breed dropdown
                        FormWidgets.buildDropdown(
                          "Breed",
                          breedNames,
                          selectedBreedName,
                          (value) {
                            setState(() {
                              selectedBreedName = value;
                              if (value != null) {
                                selectedBreedId = breedMap[value]!.id;
                              } else {
                                selectedBreedId = null;
                              }
                            });
                          },
                        ),

                        // Quantity field
                        FormWidgets.buildTextField(
                          "Quantity",
                          quantityController,
                          TextInputType.number,
                        ),

                        // Weight field
                        FormWidgets.buildTextField(
                          "Weight",
                          weightController,
                          TextInputType.numberWithOptions(decimal: true),
                        ),

                        // Unit price field
                        FormWidgets.buildTextField(
                          "Unit Price",
                          unitPreisController,
                          TextInputType.numberWithOptions(decimal: true),
                        ),

                        // Gender dropdown
                        FormWidgets.buildDropdown(
                          "Gender",
                          genderOptions,
                          selectedGender,
                          (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),

                        // Date picker
                        FormWidgets.buildDatePicker(
                          context,
                          "Date of Acquisition",
                          selectedDate,
                          (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                        ),

                        SizedBox(height: 24),

                        // Save button
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveAcquisition,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child:
                              _isSaving
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
                        if (widget.acquisition != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: OutlinedButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : () => _confirmDelete(
                                        widget.acquisition!.id!,
                                      ),
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
    weightController.dispose();
    quantityController.dispose();
    unitPreisController.dispose();
    super.dispose();
  }
}
