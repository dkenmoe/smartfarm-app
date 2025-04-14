class AnimalBreed {
  final int id;
  final String name;
  final int animalTypeId;

  AnimalBreed({
    required this.id, 
    required this.name,
    required this.animalTypeId,
  });

  factory AnimalBreed.fromJson(Map<String, dynamic> json) {
    return AnimalBreed(
      id: json['id'],
      name: json['name'],
      animalTypeId: json['animal_type'],
    );
  }
}
