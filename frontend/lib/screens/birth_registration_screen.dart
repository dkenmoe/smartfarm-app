// screens/birth_registration_screen.dart
import 'package:firstapp/widgets/registration_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/animal_breed.dart';
import '../models/animal_type.dart';
import '../models/birth_record.dart';
import '../services/api_service.dart';

class BirthRegistrationScreen extends StatefulWidget {
  const BirthRegistrationScreen({super.key});

  @override
  _BirthRegistrationScreenState createState() =>
      _BirthRegistrationScreenState();
}

class _BirthRegistrationScreenState extends State<BirthRegistrationScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController numberOfMaleController = TextEditingController();
  final TextEditingController numberOfFemaleController =
      TextEditingController();
  final TextEditingController numberOfDiedController = TextEditingController();
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
      RegistrationWidgets.showSnackbar(
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
      RegistrationWidgets.showSnackbar(
        context,
        "Error loading breeds.",
        Colors.red,
      );
    }
  }

  Future<void> _registerBirth() async {
    if (selectedAnimalTypeId == null || selectedBreedId == null) {
      RegistrationWidgets.showSnackbar(
        context,
        "Please fill in all fields.",
        Colors.orange,
      );
      return;
    }

    double weight = double.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      RegistrationWidgets.showSnackbar(
        context,
        "The weight must be greater than zero.",
        Colors.orange,
      );
      return;
    }

    int numberOfMale = int.tryParse(numberOfMaleController.text) ?? 0;
    if (numberOfMale < 0) {
      RegistrationWidgets.showSnackbar(
        context,
        "The number of male must be greater or equal to zero.",
        Colors.orange,
      );
      return;
    }

    int numberOfFemale = int.tryParse(numberOfFemaleController.text) ?? 0;
    if (numberOfFemale < 0) {
      RegistrationWidgets.showSnackbar(
        context,
        "The number of female must be greater or equal to zero.",
        Colors.orange,
      );
      return;
    }

    int numberOfDied = int.tryParse(numberOfDiedController.text) ?? 0;
    if (numberOfDied < 0) {
      RegistrationWidgets.showSnackbar(
        context,
        "The number of died must be greater or equal to zero.",
        Colors.orange,
      );
      return;
    }

    // Additional validation to ensure total number is greater than 0
    if (numberOfMale + numberOfFemale + numberOfDied == 0) {
      RegistrationWidgets.showSnackbar(
        context,
        "The total number of births must be greater than zero.",
        Colors.orange,
      );
      return;
    }

    BirthRecord birthRecord = BirthRecord(
      animalTypeId: selectedAnimalTypeId!,
      breedId: selectedBreedId!,
      weight: weight,
      number_of_male: numberOfMale,
      number_of_female: numberOfFemale,
      number_of_died: numberOfDied,
      dateOfBirth: DateFormat('yyyy-MM-dd').format(selectedDate),
    );

    try {
      bool success = await ApiService.registerBirth(birthRecord);
      if (success) {
        RegistrationWidgets.showSnackbar(
          context,
          "Birth successfully registered!",
          Colors.green,
        );
        _resetForm();
      } else {
        RegistrationWidgets.showSnackbar(
          context,
          "Error while saving.",
          Colors.red,
        );
      }
    } catch (e) {
      RegistrationWidgets.showSnackbar(
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
      numberOfMaleController.clear();
      numberOfFemaleController.clear();
      numberOfDiedController.clear();
      selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Birth record", style: GoogleFonts.lato(fontSize: 20)),
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
              RegistrationWidgets.buildDropdown(
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
              RegistrationWidgets.buildDropdown(
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
              RegistrationWidgets.buildTextField(
                "Weight",
                weightController,
                TextInputType.number,
              ),
              RegistrationWidgets.buildTextField(
                "Number of male",
                numberOfMaleController,
                TextInputType.number,
              ),
              RegistrationWidgets.buildTextField(
                "Number of female",
                numberOfFemaleController,
                TextInputType.number,
              ),
              RegistrationWidgets.buildTextField(
                "Number of died",
                numberOfDiedController,
                TextInputType.number,
              ),
              RegistrationWidgets.buildDatePicker(
                context,
                "Birthdate",
                selectedDate,
                (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerBirth,
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
