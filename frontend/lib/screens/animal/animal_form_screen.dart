import 'package:firstapp/models/animal/animal.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/services/animal_service.dart';
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  final Function(Animal)? onSubmit;

  const AnimalFormScreen({Key? key, this.animal, this.onSubmit})
    : super(key: key);

  @override
  _AnimalFormScreenState createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  static final LoggerService _logger = LoggerService();

  final trackingIdController = TextEditingController();
  final notesController = TextEditingController();
  final initialWeightController = TextEditingController();
  final currentWeightController = TextEditingController();

  DateTime? dateOfBirth;
  DateTime? dateOfAcquisition;
  DateTime? lastWeighDate;

  String gender = 'Male';
  String status = 'active';

  int? selectedFarmId;
  int? selectedAnimalTypeId;
  int? selectedBreedId;

  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};
  List<String> animalTypeNames = [];
  List<String> breedNames = [];
  String? selectedAnimalTypeName;
  String? selectedBreedName;

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<AnimalType> types = await ApiService.fetchAnimalTypes();
      animalTypeMap = {for (var type in types) type.name: type};
      animalTypeNames = animalTypeMap.keys.toList();

      if (widget.animal != null) _setupFormForEditing();

      setState(() => _isLoading = false);
    } catch (e) {
      FormWidgets.showSnackbar(context, "Failed to load data", Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void _setupFormForEditing() {
    final animal = widget.animal!;
    trackingIdController.text = animal.trackingId;
    notesController.text = animal.notes ?? '';
    initialWeightController.text = animal.initialWeight?.toString() ?? '';
    currentWeightController.text = animal.currentWeight?.toString() ?? '';

    gender = animal.gender;
    status = animal.status;
    selectedFarmId = animal.farmId;
    dateOfBirth = animal.dateOfBirth;
    dateOfAcquisition = animal.dateOfAcquisition;
    lastWeighDate = animal.lastWeighDate;

    selectedAnimalTypeId = animal.animalTypeId;
    selectedAnimalTypeName =
        animalTypeMap.entries
            .firstWhere((e) => e.value.id == selectedAnimalTypeId)
            .key;
    _loadBreeds().then((_) {
      selectedBreedId = animal.breedId;
      selectedBreedName = breedMap.entries.firstWhere((e) => e.value.id == selectedBreedId).key;
      // setState(() {});
    });
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
      _logger.info('selected animal id = ${selectedAnimalTypeId}');
      List<AnimalBreed> breedList = await ApiService.fetchBreedsByAnimalType(
        selectedAnimalTypeId!,
      );
      setState(() {
        breedMap = {for (var breed in breedList) breed.name: breed};
        breedNames = breedMap.keys.toList();
      });
    } catch (e) {
      FormWidgets.showSnackbar(context, "Failed to load breeds", Colors.red);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedAnimalTypeId == null ||
        selectedBreedId == null ||
        selectedFarmId == null) {
      FormWidgets.showSnackbar(
        context,
        "Please select all required fields.",
        Colors.orange,
      );
      return;
    }

    setState(() => _isSaving = true);

    final animal = Animal(
      id: widget.animal?.id ?? 0,
      trackingId: trackingIdController.text,
      animalTypeId: selectedAnimalTypeId!,
      breedId: selectedBreedId!,
      gender: gender,
      dateOfBirth: dateOfBirth,
      dateOfAcquisition: dateOfAcquisition,
      farmId: selectedFarmId!,
      initialWeight: double.tryParse(initialWeightController.text),
      currentWeight: double.tryParse(currentWeightController.text),
      lastWeighDate: lastWeighDate,
      notes: notesController.text,
      status: status,
      qrCodeUrl: widget.animal?.qrCodeUrl,
      animalTypeName: null,
      breedName: null,
      farmName: null,
      createdBy: null,
      createdAt: null,
      updatedAt: null,
    );

    bool success =
        widget.animal == null
            ? await AnimalService.createAnimal(animal)
            : await AnimalService.updateAnimal(animal.id, animal);

    setState(() => _isSaving = false);

    if (success) {
      if (widget.onSubmit != null) widget.onSubmit!(animal);
      Navigator.pop(context);
    } else {
      FormWidgets.showSnackbar(context, 'Failed to save animal.', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.animal == null ? 'Register Animal' : 'Edit Animal',
          style: GoogleFonts.lato(fontSize: 20),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
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
                        FormWidgets.buildTextField(
                          "Tracking ID",
                          trackingIdController,
                          TextInputType.text,
                        ),
                        FormWidgets.buildDropdown(
                          "Animal type",
                          animalTypeNames,
                          selectedAnimalTypeName,
                          (val) {
                            setState(() {
                              selectedAnimalTypeName = val;
                              selectedAnimalTypeId = animalTypeMap[val]?.id;
                              selectedBreedName = null;
                              selectedBreedId = null;
                            });
                            _loadBreeds();
                          },
                        ),
                        FormWidgets.buildDropdown(
                          "Breed",
                          breedNames,
                          selectedBreedName,
                          (val) {
                            setState(() {
                              selectedBreedName = val;
                              selectedBreedId = breedMap[val]?.id;
                            });
                          },
                        ),
                        FormWidgets.buildSegmentedControl<String>(
                          "Gender",
                          {"Male": "Male", "Female": "Female"},
                          gender,
                          (val) => setState(() => gender = val),
                        ),
                        FormWidgets.buildDatePicker(
                          context,
                          "Date of birth",
                          dateOfBirth ?? DateTime.now(),
                          (d) => setState(() => dateOfBirth = d),
                        ),
                        FormWidgets.buildDatePicker(
                          context,
                          "Date of acquisition",
                          dateOfAcquisition ?? DateTime.now(),
                          (d) => setState(() => dateOfAcquisition = d),
                        ),
                        FormWidgets.buildDatePicker(
                          context,
                          "Last weigh date",
                          lastWeighDate ?? DateTime.now(),
                          (d) => setState(() => lastWeighDate = d),
                        ),
                        FormWidgets.buildTextField(
                          "Initial weight (kg)",
                          initialWeightController,
                          TextInputType.number,
                        ),
                        FormWidgets.buildTextField(
                          "Current weight (kg)",
                          currentWeightController,
                          TextInputType.number,
                        ),
                        FormWidgets.buildTextField(
                          "Notes",
                          notesController,
                          TextInputType.text,
                          maxLines: 3,
                        ),
                        FormWidgets.buildDropdown<String>(
                          "Status",
                          ["active", "sold", "died", "quarantine"],
                          status,
                          (val) => setState(() => status = val ?? 'active'),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
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
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    trackingIdController.dispose();
    notesController.dispose();
    initialWeightController.dispose();
    currentWeightController.dispose();
    super.dispose();
  }
}
