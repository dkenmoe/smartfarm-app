import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:flutter/material.dart';

class AnimalTypeSelector extends StatefulWidget{
  final Function(int) onAnimalTypeSelected;
  final int? initialValue;

  const AnimalTypeSelector({
    Key? key,
    required this.onAnimalTypeSelected,
    this.initialValue,
  }):super(key: key);

  @override
  _AnimalTypeSelectorState createState() => _AnimalTypeSelectorState();
}

class _AnimalTypeSelectorState extends State<AnimalTypeSelector>{
  final ApiService apiService = ApiService();
  late Future<List<AnimalType>> _animalTypes;
  int? _selectedAnimalTypeId;

  @override
  void initState(){
    super.initState();
    _animalTypes = ApiService.fetchAnimalTypes();
    _selectedAnimalTypeId = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AnimalType>>(
      future: _animalTypes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error loading animal types: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No animal types available");
        }

        final animalTypes = snapshot.data!;
        
        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Animal Type',
            border: OutlineInputBorder(),
          ),
          value: _selectedAnimalTypeId,
          items: animalTypes.map((type) {
            return DropdownMenuItem<int>(
              value: type.id,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAnimalTypeId = value;
            });
            if (value != null) {
              widget.onAnimalTypeSelected(value);
            }
          },
        );
      },
    );
  }
}