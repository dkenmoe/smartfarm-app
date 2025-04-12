class AnimalInventory {
  final int id;
  final int animalTypeId;
  final String animalTypeName;
  final int breedId;
  final String breedName;
  final int quantity;

  AnimalInventory({
    required this.id,
    required this.animalTypeId,
    required this.animalTypeName,
    required this.breedId,
    required this.breedName,
    required this.quantity,
  });

  factory AnimalInventory.fromJson(Map<String, dynamic> json) {
    return AnimalInventory(
      id: json['id'],
      animalTypeId: json['animal_type'],
      animalTypeName: json['animal_type_name'],
      breedId: json['breed'],
      breedName: json['breed_name'],
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animal_type': animalTypeId,
      // Lors de l'envoi, on n'a pas besoin d'envoyer les noms car le serveur les ignore
      'breed': breedId,
      'quantity': quantity,
    };
  }
}