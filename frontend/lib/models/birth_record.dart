class BirthRecord {
  final int? id;
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final double weight;
  final int number_of_male;
  final int number_of_female;
  final int number_of_died;
  final String dateOfBirth;

  BirthRecord({
    this.id,
    required this.animalTypeId,
    String this.animalTypeName = "",
    required this.breedId,
    String this.breedName = "",
    required this.weight,
    required this.number_of_male,
    required this.number_of_female,
    required this.number_of_died,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'animal_type': animalTypeId,
      'breed': breedId,
      'weight': weight,
      'number_of_male': number_of_male,
      'number_of_female': number_of_female,
      'number_of_died': number_of_died,
      'date_of_birth': dateOfBirth,
    };

    // Only include id when it's not null (for updates)
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  factory BirthRecord.fromJson(Map<String, dynamic> json) {
    return BirthRecord(
      id: json['id'],
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      weight:
          json['weight'] != null ? double.parse(json['weight'].toString()) : 0,
      number_of_male: json['number_of_male'],
      number_of_female: json['number_of_female'],
      number_of_died: json['number_of_died'],
      dateOfBirth: json['date_of_birth'],
    );
  }
}
