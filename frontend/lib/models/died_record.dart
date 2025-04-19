class DiedRecord {
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final double weight;
  final int quantity;
  final String dateOfDeath;
  final int? createdById;
  final String? createdByName;

  DiedRecord({
    required this.animalTypeId,
    this.animalTypeName,
    required this.breedId,
    this.breedName, 
    required this.weight,
    required this.quantity,
    required this.dateOfDeath,
    this.createdById,
    this.createdByName,
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

    factory DiedRecord.fromJson(Map<String, dynamic> json) {
    return DiedRecord(
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      weight: json['weight'].toDouble(),
      quantity: json['quantity'],
      dateOfDeath: json['date_of_death']
    );
  }
}