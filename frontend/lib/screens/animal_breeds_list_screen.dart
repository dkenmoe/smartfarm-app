import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalBreedsListScreen extends StatefulWidget {
  const AnimalBreedsListScreen({super.key});

  @override
  _AnimalBreedsScreenState createState() => _AnimalBreedsScreenState();
}

class _AnimalBreedsScreenState extends State<AnimalBreedsListScreen> {
  late Future<List<AnimalBreed>> _animalBreedsFuture;

  @override
  void initState() {
    super.initState();
    _animalBreedsFuture = ApiService.fetchBreeds();
  }

  void _showFullImage(BuildContext context, AnimalBreed breed) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(breed.name),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Flexible(
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4,
                    child: CachedNetworkImage(
                      imageUrl: breed.image ?? '',
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
                if (breed.description != null && breed.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      breed.description!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Animal Breeds', style: GoogleFonts.lato(fontSize: 20)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: FutureBuilder<List<AnimalBreed>>(
        future: _animalBreedsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No breeds found",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          final breeds = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: breeds.length,
            itemBuilder: (context, index) {
              final breed = breeds[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showFullImage(context, breed),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (breed.thumbnail != null &&
                                breed.thumbnail!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: breed.thumbnail!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          Icon(Icons.broken_image, size: 60),
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 30,
                                ),
                              ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    breed.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    breed.animalTypeName ?? 'Unknown Type',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (breed.description != null &&
                            breed.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              breed.description!,
                              style: TextStyle(color: Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new breed if needed
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
