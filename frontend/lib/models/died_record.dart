class DiedRecord {
  final int animalTypeId;
  final int breedId;
  final double weight;
  final int quantity;
  final String dateOfDeath;

  DiedRecord({
    required this.animalTypeId,
    required this.breedId,
    required this.weight,
    required this.quantity,
    required this.dateOfDeath,
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalTypeId,
      'breed': breedId,
      'weight': weight,
      'quantity': quantity,
      'date_of_death': dateOfDeath,
    };
  }
}