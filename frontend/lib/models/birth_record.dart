class BirthRecord {
  final int animalTypeId;
  final int breedId;
  final String gender;
  final int weightCategoryId;
  final int quantity;
  final String dateOfBirth;

  BirthRecord({
    required this.animalTypeId,
    required this.breedId,
    required this.gender,
    required this.weightCategoryId,
    required this.quantity,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalTypeId,
      'breed': breedId,
      'gender': gender,
      'weight_category': weightCategoryId,
      'quantity': quantity,
      'date_of_birth': dateOfBirth,
    };
  }
}