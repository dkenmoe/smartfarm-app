class AcquisitionRecord {
  final int? id;
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
    this.id,
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
      id: json['id'],
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      quantity: json['quantity'],
      weight:
          json['weight'] != null
              ? (json['weight'] is String
                  ? double.parse(json['weight'])
                  : json['weight'].toDouble())
              : null,
      gender: json['gender'],
      unitPreis:
          json['unit_preis'] != null
              ? (json['unit_preis'] is String
                  ? double.parse(json['unit_preis'])
                  : json['unit_preis'].toDouble())
              : null,
      dateOfAcquisition: json['date_of_acquisition'],
      createdById: json['created_by'],
      createdByName: json['created_by_name'],
    );
  }
}
