class AnimalBreed {
  final int id;
  final int animalTypeId;
  final String? animalTypeName;
  final String name;
  final String? description;
  final String? image;
  final String? thumbnail;
  final int? createdById;
  final String? createdByName;

  AnimalBreed({
    required this.id,
    required this.animalTypeId,
    this.animalTypeName,
    required this.name,
    this.description,
    this.image,
    this.thumbnail,
    this.createdById,
    this.createdByName,
  });

  factory AnimalBreed.fromJson(Map<String, dynamic> json) {
    return AnimalBreed(
      id: json['id'],
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      thumbnail: json['thumbnail'],
      createdById: json['created_by'],
      createdByName: json['created_by_name'],
    );
  }
}
