import 'package:firstapp/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/animal_breed.dart';
import '../models/animal_type.dart';
import '../models/died_record.dart';
import '../services/api_service.dart';

class DiedRegistrationScreen extends StatefulWidget {
  const DiedRegistrationScreen({super.key});

  @override
  _DiedRegistrationScreenState createState() => _DiedRegistrationScreenState();
}

class _DiedRegistrationScreenState extends State<DiedRegistrationScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  int? selectedAnimalTypeId;
  int? selectedBreedId;

  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};

  List<String> animalTypeNames = [];
  List<String> breedNames = [];

  String? selectedAnimalTypeName;
  String? selectedBreedName;

  @override
  void initState() {
    super.initState();
    _loadAnimalTypes();
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
        "Error loading animal types.",
        Colors.red,
      );
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
        selectedBreedName = null;
        selectedBreedId = null;
      });
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Error loading breeds.",
        Colors.red,
      );
    }
  }

  Future<void> _registerDied() async {
    if (selectedAnimalTypeId == null || selectedBreedId == null) {
      FormWidgets.showSnackbar(
        context,
        "Please fill in all fields.",
        Colors.orange,
      );
      return;
    }

    int quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      FormWidgets.showSnackbar(
        context,
        "The quantity must be greater than zero.",
        Colors.orange,
      );
      return;
    }

    double weight = double.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      FormWidgets.showSnackbar(
        context,
        "The weight must be greater than zero.",
        Colors.orange,
      );
      return;
    }

    DiedRecord diedRecord = DiedRecord(
      animalTypeId: selectedAnimalTypeId!,
      breedId: selectedBreedId!,
      quantity: quantity,
      weight: weight,
      dateOfDeath: DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    try {
      bool success = await ApiService.registerDied(diedRecord);
      if (success) {
        FormWidgets.showSnackbar(
          context,
          "Death record successfully registered!",
          Colors.green,
        );
        _resetForm();
      } else {
        FormWidgets.showSnackbar(
          context,
          "Error while saving.",
          Colors.red,
        );
      }
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Exception: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _resetForm() {
    setState(() {
      selectedAnimalTypeName = null;
      selectedBreedName = null;
      selectedAnimalTypeId = null;
      selectedBreedId = null;
      weightController.clear();
      quantityController.clear();
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Death record", style: GoogleFonts.lato(fontSize: 20)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              FormWidgets.buildTextField(
                "Quantity",
                quantityController,
                TextInputType.number,
              ),
              FormWidgets.buildTextField(
                "Weight",
                weightController,
                TextInputType.numberWithOptions(decimal: true),
              ),
              FormWidgets.buildDatePicker(
                context,
                "Date of death",
                selectedDate,
                (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerDied,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
