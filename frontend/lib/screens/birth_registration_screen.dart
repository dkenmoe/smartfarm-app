
import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/birth_record.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class BirthRegistrationScreen extends StatefulWidget {
  const BirthRegistrationScreen({super.key});

  @override
  _BirthRegistrationScreenState createState() =>
      _BirthRegistrationScreenState();
}

class _BirthRegistrationScreenState extends State<BirthRegistrationScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController numberOfMaleController = TextEditingController();
  final TextEditingController numberOfFemaleController = TextEditingController();
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
  String? selectedWeightCategoryName;

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
      _showSnackbar("Error loading animal types.", Colors.red);
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
      _showSnackbar("Error loading breeds.", Colors.red);
    }
  }

  Future<void> _registerBirth() async {
    if (selectedAnimalTypeId == null ||
        selectedBreedId == null) {
      _showSnackbar("Please fill in all fields.", Colors.orange);
      return;
    }

    double weight = double.tryParse(weightController.text) ?? 0;
    if (weight <= 0) {
      _showSnackbar("The weight must be greater than zero.", Colors.orange);
      return;
    }

    int numberOfMale = int.tryParse(numberOfMaleController.text) ?? 0;
    if (numberOfMale < 0) {
      _showSnackbar("The number of male must be greater or equal to zero.", Colors.orange);
      return;
    }

    int numberOfFemale = int.tryParse(numberOfFemaleController.text) ?? 0;
    if (numberOfFemale < 0) {
      _showSnackbar("The number of female must be greater or equal to zero.", Colors.orange);
      return;
    }

    int numberOfDied = int.tryParse(numberOfDiedController.text) ?? 0;
    if (numberOfDied < 0) {
      _showSnackbar("The number of died must be greater or equal to zero.", Colors.orange);
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
        _showSnackbar("Birth successfully registered!", Colors.green);
        _resetForm();
      } else {
        _showSnackbar("Error while saving.", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Exception: ${e.toString()}", Colors.red);
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

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
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
              _buildDropdown(
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
              _buildDropdown("Breed", breedNames, selectedBreedName, (value) {
                setState(() {
                  selectedBreedName = value;
                  if (value != null) {
                    selectedBreedId = breedMap[value]!.id;
                  } else {
                    selectedBreedId = null;
                  }
                });
              }),
              _buildTextField(
                "Weight",
                weightController,
                TextInputType.number,
              ),
              _buildTextField(
                "Number of male",
                numberOfMaleController,
                TextInputType.number,
              ),
              _buildTextField(
                "number of female",
                numberOfFemaleController,
                TextInputType.number,
              ),
              _buildTextField(
                "Number of died",
                numberOfDiedController,
                TextInputType.number,
              ),
              _buildDatePicker(context),
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

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedValue,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      title: Text(
        "Birthdate : ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
      ),
      trailing: Icon(Icons.calendar_today, color: Colors.green),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
    );
  }
}
