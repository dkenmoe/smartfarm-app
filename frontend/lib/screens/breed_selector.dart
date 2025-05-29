import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:flutter/material.dart';

class BreedSelector extends StatefulWidget {
  final int? animalTypeId;
  final Function(int) onBreedSelected;
  final int? initialValue;

  const BreedSelector({
    Key? key,
    required this.animalTypeId,
    required this.onBreedSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _BreedSelectorState createState() => _BreedSelectorState();
}

class _BreedSelectorState extends State<BreedSelector> {
  //final ApiService _apiService = ApiService();
  Future<List<AnimalBreed>>? _breeds;
  int? _selectedBreedId;

  @override
  void initState() {
    super.initState();
    _selectedBreedId = widget.initialValue;
    _loadBreeds();
  }

  @override
  void didUpdateWidget(BreedSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload breeds when animal type changes
    if (widget.animalTypeId != oldWidget.animalTypeId) {
      setState(() {
        _selectedBreedId = null; // Reset selection when animal type changes
        _loadBreeds();
      });
    }
  }

  void _loadBreeds() {
    if (widget.animalTypeId != null) {
      _breeds = ApiService.fetchBreedsByAnimalType(widget.animalTypeId!);
    } else {
      _breeds = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animalTypeId == null) {
      return DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: 'Breed (select animal type first)',
          border: OutlineInputBorder(),
        ),
        items: [],
        onChanged: null,
      );
    }

    return FutureBuilder<List<AnimalBreed>>(
      future: _breeds,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Loading breeds...',
              border: OutlineInputBorder(),
            ),
            items: [],
            onChanged: null,
          );
        } else if (snapshot.hasError) {
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Error: ${snapshot.error}',
              border: OutlineInputBorder(),
            ),
            items: [],
            onChanged: null,
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'No breeds available for this animal type',
              border: OutlineInputBorder(),
            ),
            items: [],
            onChanged: null,
          );
        }

        final breeds = snapshot.data!;

        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Breed',
            border: OutlineInputBorder(),
          ),
          value: _selectedBreedId,
          items:
              breeds.map((breed) {
                return DropdownMenuItem<int>(
                  value: breed.id,
                  child: Text(breed.name),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBreedId = value;
            });
            if (value != null) {
              widget.onBreedSelected(value);
            }
          },
        );
      },
    );
  }
}
