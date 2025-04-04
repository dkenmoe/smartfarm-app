import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/weight_category.dart';
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
  final TextEditingController quantityController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  int? selectedAnimalTypeId;
  int? selectedBreedId;
  String? selectedGender;
  int? selectedWeightCategoryId;

  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};
  Map<String, WeightCategory> weightCategoryMap = {};
  List<String> genders = ["Male", "Female"];

  List<String> animalTypeNames = [];
  List<String> breedNames = [];
  List<String> weightCategoryNames = [];

  String? selectedAnimalTypeName;
  String? selectedBreedName;
  String? selectedWeightCategoryName;

  @override
  void initState() {
    super.initState();
    _loadAnimalTypes();
    _loadWeightCategories();
  }

  Future<void> _loadAnimalTypes() async {
    try {
      List<AnimalType> types = await ApiService.fetchAnimalTypes();
      setState(() {
        animalTypeMap = {for (var type in types) type.name: type};
        animalTypeNames = animalTypeMap.keys.toList();
      });
    } catch (e) {
      _showSnackbar(
        "Error loading animal types.",
        Colors.red,
      );
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

  Future<void> _loadWeightCategories() async {
    try {
      List<WeightCategory> categories =
          await ApiService.fetchWeightCategories();
      setState(() {
        weightCategoryMap = {for (var cat in categories) cat.name: cat};
        weightCategoryNames = weightCategoryMap.keys.toList();
      });
    } catch (e) {
      _showSnackbar(
        "Error loading weight categories.",
        Colors.red,
      );
    }
  }

  Future<void> _registerBirth() async {
    if (selectedAnimalTypeId == null ||
        selectedBreedId == null ||
        selectedGender == null ||
        selectedWeightCategoryId == null) {
      _showSnackbar("Please fill in all fields.", Colors.orange);
      return;
    }

    int quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      _showSnackbar("The quantity must be greater than zero.", Colors.orange);
      return;
    }

    BirthRecord birthRecord = BirthRecord(
      animalTypeId: selectedAnimalTypeId!,
      breedId: selectedBreedId!,
      gender: selectedGender!,
      weightCategoryId: selectedWeightCategoryId!,
      quantity: quantity,
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
      selectedGender = null;
      selectedWeightCategoryName = null;
      selectedAnimalTypeId = null;
      selectedBreedId = null;
      selectedWeightCategoryId = null;
      quantityController.clear();
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
        title: Text(
          "Birth record",
          style: GoogleFonts.lato(fontSize: 20),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
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
              _buildDropdown("Gender", genders, selectedGender, (value) {
                setState(() {
                  selectedGender = value;
                });
              }),
              _buildDropdown(
                "Weight categories",
                weightCategoryNames,
                selectedWeightCategoryName,
                (value) {
                  setState(() {
                    selectedWeightCategoryName = value;
                    if (value != null) {
                      selectedWeightCategoryId = weightCategoryMap[value]!.id;
                    } else {
                      selectedWeightCategoryId = null;
                    }
                  });
                },
              ),
              _buildTextField(
                "Quantity",
                quantityController,
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
