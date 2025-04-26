class DiedRecord {
  final int? id;
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final double weight;
  final int quantity;
  final String dateOfDeath;
  final int? createdById;
  final String? createdByName;
  final String status;

  DiedRecord({
    this.id,
    required this.animalTypeId,
    this.animalTypeName,
    required this.breedId,
    this.breedName, 
    required this.weight,
    required this.quantity,
    required this.dateOfDeath,
    this.createdById,
    this.createdByName,
    this.status = 'recorded',
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalTypeId,
      'breed': breedId,
      'weight': weight,
      'quantity': quantity,
      'date_of_death': dateOfDeath,
      'status': status,
    };
  }

    factory DiedRecord.fromJson(Map<String, dynamic> json) {
    return DiedRecord(
      id: json['id'],
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      weight: json['weight'].toDouble(),
      quantity: json['quantity'],
      dateOfDeath: json['date_of_death'],
      status: json['status'] ?? 'recorded',
    );
  }
}