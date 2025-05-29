class Animal {
  final int id;
  final String trackingId;
  final int animalTypeId;
  final String? animalTypeName;
  final int breedId;
  final String? breedName;
  final String gender;
  final DateTime? dateOfBirth;
  final DateTime? dateOfAcquisition;
  final int farmId;
  final String? farmName;
  final double? initialWeight;
  final double? currentWeight;
  final DateTime? lastWeighDate;
  final String? notes;
  final String? qrCodeUrl;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Animal({
    required this.id,
    required this.trackingId,
    required this.animalTypeId,
    this.animalTypeName,
    required this.breedId,
    this.breedName,
    required this.gender,
    this.dateOfBirth,
    this.dateOfAcquisition,
    required this.farmId,
    this.farmName,
    this.initialWeight,
    this.currentWeight,
    this.lastWeighDate,
    this.notes,
    this.qrCodeUrl,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

factory Animal.fromJson(Map<String, dynamic> json) {
  return Animal(
    id: json['id'],
    trackingId: json['tracking_id'],
    animalTypeId: json['animal_type'] != null ? json['animal_type']['id'] : json['animal_type_id'],
    animalTypeName: json['animal_type']?['name'],
    breedId: json['breed'] != null ? json['breed']['id'] : json['breed_id'],
    breedName: json['breed']?['name'],
    gender: json['gender'],
    dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
    dateOfAcquisition: json['date_of_acquisition'] != null ? DateTime.parse(json['date_of_acquisition']) : null,
    farmId: json['farm'] != null ? json['farm']['id'] : json['farm_id'],
    farmName: json['farm']?['name'],
    initialWeight: json['initial_weight']?.toDouble(),
    currentWeight: json['current_weight']?.toDouble(),
    lastWeighDate: json['last_weigh_date'] != null ? DateTime.parse(json['last_weigh_date']) : null,
    notes: json['notes'],
    qrCodeUrl: json['qr_code'],
    status: json['status'],
    createdBy: json['created_by'],
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'tracking_id': trackingId,
      'animal_type': animalTypeId,
      'breed': breedId,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'date_of_acquisition': dateOfAcquisition?.toIso8601String(),
      'farm': farmId,
      'initial_weight': initialWeight,
      'current_weight': currentWeight,
      'last_weigh_date': lastWeighDate?.toIso8601String(),
      'notes': notes,
      'status': status,
    };
  }
}
