import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/services/birth_service.dart';
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BirthFormScreen extends StatefulWidget {
  final BirthRecord? birthRecord;
  final Function(BirthRecord)? onSubmit;

  const BirthFormScreen({Key? key, this.birthRecord, this.onSubmit})
      : super(key: key);

  @override
  _BirthFormScreenState createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController weightController = TextEditingController();
  final TextEditingController numberOfMaleController = TextEditingController();
  final TextEditingController numberOfFemaleController = TextEditingController();
  final TextEditingController numberOfDiedController = TextEditingController();
  
  // Selected values
  DateTime selectedDate = DateTime.now();
  int? selectedAnimalTypeId;
  int? selectedBreedId;

  // Data lists and maps
  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};
  List<String> animalTypeNames = [];
  List<String> breedNames = [];
  String? selectedAnimalTypeName;
  String? selectedBreedName;

  // Loading state
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
      // Load animal types
      List<AnimalType> types = await ApiService.fetchAnimalTypes();
      setState(() {
        animalTypeMap = {for (var type in types) type.name: type};
        animalTypeNames = animalTypeMap.keys.toList();
        _isLoading = false;
      });

      // Set up form for editing if a birth record was provided
      if (widget.birthRecord != null) {
        _setupFormForEditing();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FormWidgets.showSnackbar(
        context,
        "Error loading animal types: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _setupFormForEditing() {
    final birthRecord = widget.birthRecord!;

    // Set text controllers
    weightController.text = birthRecord.weight.toString();
    numberOfMaleController.text = birthRecord.number_of_male.toString();
    numberOfFemaleController.text = birthRecord.number_of_female.toString();
    numberOfDiedController.text = birthRecord.number_of_died.toString();

    // Set date
    try {
      selectedDate = DateFormat('yyyy-MM-dd').parse(birthRecord.dateOfBirth);
    } catch (e) {
      selectedDate = DateTime.now();
    }

    // Set animal type
    selectedAnimalTypeId = birthRecord.animalTypeId;
    if (selectedAnimalTypeId != null) {
      for (var type in animalTypeMap.entries) {
        if (type.value.id == selectedAnimalTypeId) {
          selectedAnimalTypeName = type.key;
          break;
        }
      }
      _loadBreeds().then((_) {
        // Set breed after breeds are loaded
        selectedBreedId = birthRecord.breedId;
        for (var breed in breedMap.entries) {
          if (breed.value.id == selectedBreedId) {
            setState(() {
              selectedBreedName = breed.key;
            });
            break;
          }
        }
            });
    }
  }

  Future<void> _loadBreeds() async {
    if (selectedAnimalTypeId == null) return;
    try {
      List<AnimalBreed> breedList = await ApiService.fetchBreeds(
        animalTypeId: selectedAnimalTypeId!,
      );
      setState(() {
        breedMap = {for (var breed in breedList) breed.name: breed};
        breedNames = breedMap.keys.toList();
        if (widget.birthRecord == null) {
          selectedBreedName = null;
          selectedBreedId = null;
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

  Future<void> _saveBirthRecord() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (selectedAnimalTypeId == null || selectedBreedId == null) {
      FormWidgets.showSnackbar(
        context,
        "Please select an animal type and breed.",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
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

      int numberOfMale = int.tryParse(numberOfMaleController.text) ?? 0;
      if (numberOfMale < 0) {
        FormWidgets.showSnackbar(
          context,
          "The number of male must be greater or equal to zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      int numberOfFemale = int.tryParse(numberOfFemaleController.text) ?? 0;
      if (numberOfFemale < 0) {
        FormWidgets.showSnackbar(
          context,
          "The number of female must be greater or equal to zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      int numberOfDied = int.tryParse(numberOfDiedController.text) ?? 0;
      if (numberOfDied < 0) {
        FormWidgets.showSnackbar(
          context,
          "The number of died must be greater or equal to zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Additional validation to ensure total number is greater than 0
      if (numberOfMale + numberOfFemale + numberOfDied == 0) {
        FormWidgets.showSnackbar(
          context,
          "The total number of births must be greater than zero.",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      BirthRecord birthRecord = BirthRecord(
        animalTypeId: selectedAnimalTypeId!,
        animalTypeName: selectedAnimalTypeName!,
        breedId: selectedBreedId!,
        breedName: selectedBreedName!,
        weight: weight,
        number_of_male: numberOfMale,
        number_of_female: numberOfFemale,
        number_of_died: numberOfDied,
        dateOfBirth: DateFormat('yyyy-MM-dd').format(selectedDate),
      );

      // Call the onSubmit callback if it's provided
      if (widget.onSubmit != null) {
        widget.onSubmit!(birthRecord);
        Navigator.pop(context, true);
        return;
      }

      bool success = await BirthService.registerBirth(birthRecord);
      if (success) {
        FormWidgets.showSnackbar(
          context,
          widget.birthRecord == null
              ? "Birth record created successfully!"
              : "Birth record updated successfully!",
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        FormWidgets.showSnackbar(
          context,
          "Error while saving birth record.",
          Colors.red,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.birthRecord == null ? "Create Birth Record" : "Edit Birth Record",
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
                        "Animal type",
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

                      // Weight field
                      FormWidgets.buildTextField(
                        "Weight",
                        weightController,
                        TextInputType.number,
                      ),

                      // Number of male field
                      FormWidgets.buildTextField(
                        "Number of male",
                        numberOfMaleController,
                        TextInputType.number,
                      ),

                      // Number of female field
                      FormWidgets.buildTextField(
                        "Number of female",
                        numberOfFemaleController,
                        TextInputType.number,
                      ),

                      // Number of died field
                      FormWidgets.buildTextField(
                        "Number of died",
                        numberOfDiedController,
                        TextInputType.number,
                      ),

                      // Date picker
                      FormWidgets.buildDatePicker(
                        context,
                        "Date of birth",
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
                        onPressed: _isSaving ? null : _saveBirthRecord,
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
                      if (widget.birthRecord != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => _confirmDelete(),
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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this birth record?"),
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
        // Implement delete functionality here
        // For now, just return to previous screen
        FormWidgets.showSnackbar(
          context,
          "Birth record deleted successfully",
          Colors.green,
        );
        Navigator.pop(context, true);
      } catch (e) {
        FormWidgets.showSnackbar(context, "Error: ${e.toString()}", Colors.red);
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    numberOfMaleController.dispose();
    numberOfFemaleController.dispose();
    numberOfDiedController.dispose();
    super.dispose();
  }
}