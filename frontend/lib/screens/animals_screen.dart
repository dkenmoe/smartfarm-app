import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/api_service.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  _AnimalsScreenState createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Animal>> animals;

  @override
  void initState() {
    super.initState();
    animals = apiService.fetchAnimals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of animals')),
      body: FutureBuilder<List<Animal>>(
        future: animals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final animal = snapshot.data![index];
                return ListTile(
                  title: Text(animal.name),
                  subtitle: Text('Type: ${animal.species}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
