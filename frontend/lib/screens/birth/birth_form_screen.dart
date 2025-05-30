import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:firstapp/services/birth_service.dart';
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthFormScreen extends StatefulWidget {
  final BirthRecord? birthRecord;
  final Function(BirthRecord)? onSubmit;

  const BirthFormScreen({Key? key, this.birthRecord, this.onSubmit}) : super(key: key);

  @override
  _BirthFormScreenState createState() => _BirthFormScreenState();
}

class _BirthFormScreenState extends State<BirthFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final maleController = TextEditingController();
  final femaleController = TextEditingController();
  final diedController = TextEditingController();
  final weightController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? dateOfBirth;

  int? selectedAnimalTypeId;
  String? selectedAnimalTypeName;
  int? selectedBreedId;
  String? selectedBreedName;

  Map<String, AnimalType> animalTypeMap = {};
  Map<String, AnimalBreed> breedMap = {};
  List<String> animalTypeNames = [];
  List<String> breedNames = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final types = await ApiService.fetchAnimalTypes();
      animalTypeMap = {for (var type in types) type.name: type};
      animalTypeNames = animalTypeMap.keys.toList();

      if (widget.birthRecord != null) {
        final record = widget.birthRecord!;
        maleController.text = record.numberOfMale.toString();
        femaleController.text = record.numberOfFemale.toString();
        diedController.text = record.numberOfDied.toString();
        weightController.text = record.weight?.toString() ?? '';
        notesController.text = record.notes ?? '';
        dateOfBirth = record.dateOfBirth;

        selectedAnimalTypeId = record.animalTypeId;
        selectedAnimalTypeName = animalTypeMap.entries
            .firstWhere((e) => e.value.id == selectedAnimalTypeId)
            .key;

        await _loadBreeds();

        selectedBreedId = record.breedId;
        selectedBreedName = breedMap.entries
            .firstWhere((e) => e.value.id == selectedBreedId)
            .key;
      } else {
        dateOfBirth = DateTime.now();
      }
    } catch (e) {
      FormWidgets.showSnackbar(context, "Failed to load data", Colors.red);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadBreeds() async {
    if (selectedAnimalTypeId == null) return;
    try {
      final breeds = await ApiService.fetchBreedsByAnimalType(selectedAnimalTypeId!);
      setState(() {
        breedMap = {for (var b in breeds) b.name: b};
        breedNames = breedMap.keys.toList();
      });
    } catch (e) {
      FormWidgets.showSnackbar(context, "Failed to load breeds", Colors.red);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedAnimalTypeId == null || selectedBreedId == null) {
      FormWidgets.showSnackbar(context, "Please select animal type and breed", Colors.orange);
      return;
    }

    final record = BirthRecord(
      id: widget.birthRecord?.id,
      animalTypeId: selectedAnimalTypeId!,
      breedId: selectedBreedId!,
      weight: double.tryParse(weightController.text),
      numberOfMale: int.tryParse(maleController.text) ?? 0,
      numberOfFemale: int.tryParse(femaleController.text) ?? 0,
      numberOfDied: int.tryParse(diedController.text) ?? 0,
      dateOfBirth: dateOfBirth,
      notes: notesController.text,
    );

    setState(() => _isSaving = true);
    final success = widget.birthRecord == null
        ? await BirthService.registerBirth(record)
        : await BirthService.updateBirthRecord(record);
    setState(() => _isSaving = false);

    if (success) {
      if (widget.onSubmit != null) widget.onSubmit!(record);
      Navigator.pop(context);
    } else {
      FormWidgets.showSnackbar(context, "Failed to save birth record", Colors.red);
    }
  }

  @override
  void dispose() {
    maleController.dispose();
    femaleController.dispose();
    diedController.dispose();
    weightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.birthRecord == null ? 'Register Birth Record' : 'Edit Birth Record',
          style: GoogleFonts.lato(fontSize: 20),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Animal Info"),
                            SizedBox(height: 12),
                            FormWidgets.buildDropdown(
                              "Animal Type",
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
                            SizedBox(height: 16),
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
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Birth Details"),
                            SizedBox(height: 12),
                            FormWidgets.buildDatePicker(
                              context,
                              "Date of Birth",
                              dateOfBirth ?? DateTime.now(),
                              (d) => setState(() => dateOfBirth = d),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: FormWidgets.buildTextField("Males", maleController, TextInputType.number)),
                                SizedBox(width: 12),
                                Expanded(child: FormWidgets.buildTextField("Females", femaleController, TextInputType.number)),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: FormWidgets.buildTextField("Died", diedController, TextInputType.number)),
                                SizedBox(width: 12),
                                Expanded(child: FormWidgets.buildTextField("Weight (kg)", weightController, TextInputType.number)),
                              ],
                            ),
                            SizedBox(height: 12),
                            FormWidgets.buildTextField("Notes", notesController, TextInputType.text, maxLines: 3),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      icon: Icon(Icons.save),
                      label: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.info_outline, size: 20, color: Colors.green),
        SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
