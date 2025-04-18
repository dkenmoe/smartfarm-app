class AcquisitionRecord {
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final int quantity;
  final double? weight;
  final String gender;
  final double unitPreis;
  final String dateOfAcquisition;
  final int? createdById;
  final String? createdByName;

  AcquisitionRecord({
    required this.animalTypeId,
    this.animalTypeName,
    required this.breedId,
    this.breedName,
    required this.quantity,
    this.weight,
    required this.gender,
    required this.unitPreis,
    required this.dateOfAcquisition,
    this.createdById,
    this.createdByName,
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalTypeId,
      'breed': breedId,
      'quantity': quantity,
      'weight': weight,
      'gender': gender,
      'unit_preis': unitPreis,
      'date_of_acquisition': dateOfAcquisition,
    };
  }

   factory AcquisitionRecord.fromJson(Map<String, dynamic> json) {
    return AcquisitionRecord(
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      quantity: json['quantity'],
      weight: json['weight'] != null ? json['weight'].toDouble() : null,
      gender: json['gender'],
      unitPreis: json['unit_preis'].toDouble(),
      dateOfAcquisition: json['date_of_acquisition'],
      createdById: json['created_by'],
      createdByName: json['created_by_name'],
    );
  }
}