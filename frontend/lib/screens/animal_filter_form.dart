import 'package:firstapp/screens/animal_type_selector.dart';
import 'package:firstapp/screens/breed_selector.dart';
import 'package:flutter/material.dart';

class AnimalFilterForm extends StatefulWidget {
  final Function(int?, int?) onFiltersChanged;
  
  const AnimalFilterForm({Key? key, required this.onFiltersChanged}) : super(key: key);

  @override
  _AnimalFilterFormState createState() => _AnimalFilterFormState();
}

class _AnimalFilterFormState extends State<AnimalFilterForm> {
  int? _selectedAnimalTypeId;
  int? _selectedBreedId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimalTypeSelector(
            initialValue: _selectedAnimalTypeId,
            onAnimalTypeSelected: (animalTypeId) {
              setState(() {
                _selectedAnimalTypeId = animalTypeId;
                _selectedBreedId = null; // Reset breed when animal type changes
              });
              widget.onFiltersChanged(_selectedAnimalTypeId, _selectedBreedId);
            },
          ),
          const SizedBox(height: 16),
          BreedSelector(
            animalTypeId: _selectedAnimalTypeId,
            initialValue: _selectedBreedId,
            onBreedSelected: (breedId) {
              setState(() {
                _selectedBreedId = breedId;
              });
              widget.onFiltersChanged(_selectedAnimalTypeId, _selectedBreedId);
            },
          ),
        ],
      ),
    );
  }
}