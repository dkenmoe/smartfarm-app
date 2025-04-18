import 'package:firstapp/widgets/registration_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/animal_breed.dart';
import '../models/animal_type.dart';
import '../models/acquisition_record.dart';
import '../services/api_service.dart';

class AcquisitionRegistrationScreen extends StatefulWidget {
  const AcquisitionRegistrationScreen({super.key});

  @override
  _AcquisitionRegistrationScreenState createState() =>
      _AcquisitionRegistrationScreenState();
}

class _AcquisitionRegistrationScreenState
    extends State<AcquisitionRegistrationScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPreisController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  int? selectedAnimalTypeId;
  int? selectedBreedId;

  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};

  List<String> animalTypeNames = [];
  List<String> breedNames = [];
  List<String> genderOptions = ["Male", "Female"];

  String? selectedAnimalTypeName;
  String? selectedBreedName;
  String? selectedGender;

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
          context, "Error loading animal types.", Colors.red);
    }
  }

  Future<void> _loadBreeds() async {
    if (selectedAnimalTypeId == null) return;
    try {
      List<AnimalBreed> breedList = await ApiService.fetchBreeds(
        selectedAnimalTypeId!,
      );
      setState(() {
        breedMap = {for (var breed in breedList) breed.name: breed};
        breedNames = breedMap.keys.toList();
        selectedBreedName = null;
        selectedBreedId = null;
      });
    } catch (e) {
      RegistrationWidgets.showSnackbar(
          context, "Error loading breeds.", Colors.red);
    }
  }

  Future<void> _registerAcquisition() async {
    if (selectedAnimalTypeId == null ||
        selectedBreedId == null ||
        selectedGender == null) {
      RegistrationWidgets.showSnackbar(
          context, "Please fill in all fields.", Colors.orange);
      return;
    }

    int quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      RegistrationWidgets.showSnackbar(
          context, "The quantity must be greater than zero.", Colors.orange);
      return;
    }

    double weight = double.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      RegistrationWidgets.showSnackbar(
          context, "The weight must be greater than zero.", Colors.orange);
      return;
    }

     double unitPreis = double.tryParse(unitPreisController.text) ?? 0;
    if (unitPreis <= 0) {
      RegistrationWidgets.showSnackbar(
          context, "The unit preis must be greater than zero.", Colors.orange);
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

    try {
      bool success = await ApiService.registerAcquisition(acquisitionRecord);
      if (success) {
        RegistrationWidgets.showSnackbar(
            context, "Acquisition successfully registered!", Colors.green);
        _resetForm();
      } else {
        RegistrationWidgets.showSnackbar(
            context, "Error while saving.", Colors.red);
      }
    } catch (e) {
      RegistrationWidgets.showSnackbar(
          context, "Exception: ${e.toString()}", Colors.red);
    }
  }

  void _resetForm() {
    setState(() {
      selectedAnimalTypeName = null;
      selectedBreedName = null;
      selectedGender = null;
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
        title: Text("Acquisition record", style: GoogleFonts.lato(fontSize: 20)),
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
                "Quantity",
                quantityController,
                TextInputType.number,
              ),
              RegistrationWidgets.buildTextField(
                "Weight",
                weightController,
                TextInputType.numberWithOptions(decimal: true),
              ),
               RegistrationWidgets.buildTextField(
                "Unit preis",
                unitPreisController,
                TextInputType.numberWithOptions(decimal: true),
              ),
              RegistrationWidgets.buildDropdown(
                "Gender",
                genderOptions,
                selectedGender,
                (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              RegistrationWidgets.buildDatePicker(
                context,
                "Date of acquisition",
                selectedDate,
                (date) {
                  setState(() {
                    selectedDate = date;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerAcquisition,
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