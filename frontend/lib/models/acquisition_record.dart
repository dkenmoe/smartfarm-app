class AcquisitionRecord {
  final int animalTypeId;
  final int breedId;
  final int quantity;
  final double weight;
  final String gender;
  final String dateOfAcquisition;
  final double unitPreis;

  AcquisitionRecord({
    required this.animalTypeId,
    required this.breedId,
    required this.quantity,
    required this.weight,
    required this.gender,
    required this.unitPreis,
    required this.dateOfAcquisition,
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
}