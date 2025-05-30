class BirthRecord {
  final int? id;
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final double? weight;
  final int numberOfMale;
  final int numberOfFemale;
  final int numberOfDied;
  final DateTime? dateOfBirth;
  final String? notes;
  final String? attachmentUrl;
  final int? farmId;
  final String? farmName;
  final String? createdBy;
  final DateTime? createdAt;

  BirthRecord({
    this.id,
    required this.animalTypeId,
    this.animalTypeName,
    required this.breedId,
    this.breedName,
    this.weight,
    required this.numberOfMale,
    required this.numberOfFemale,
    required this.numberOfDied,
    required this.dateOfBirth,
    this.notes,
    this.attachmentUrl,
    this.farmId,
    this.farmName,
    this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'animal_type': animalTypeId,
      'breed': breedId,
      'weight': weight,
      'number_of_male': numberOfMale,
      'number_of_female': numberOfFemale,
      'number_of_died': numberOfDied,
      'date_of_birth': dateOfBirth != null
          ? dateOfBirth!.toIso8601String().split('T')[0]
          : null,
      'notes': notes,
    };
    if (id != null) data['id'] = id;
    return data;
  }

  factory BirthRecord.fromJson(Map<String, dynamic> json) {
    return BirthRecord(
      id: json['id'],
      animalTypeId: json['animal_type_id'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed_id'],
      breedName: json['breed_name'],
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      numberOfMale: json['number_of_male'] ?? 0,
      numberOfFemale: json['number_of_female'] ?? 0,
      numberOfDied: json['number_of_died'] ?? 0,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      notes: json['notes'],
      attachmentUrl: json['attachment'],
      farmId: json['farm'],
      farmName: json['farm_name'],
      createdBy: json['created_by_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
