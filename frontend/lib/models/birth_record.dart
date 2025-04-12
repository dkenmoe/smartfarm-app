
class BirthRecord {
  final int animalTypeId;
  final int breedId;  
  final double weight;
  final int number_of_male;
  final int number_of_female;
  final int number_of_died;
  final String dateOfBirth;

  BirthRecord({
    required this.animalTypeId,
    required this.breedId,
    required this.weight,
    required this.number_of_male,
    required this.number_of_female,
    required this.number_of_died,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'animal_type': animalTypeId,
      'breed': breedId,
      'weight': weight,
      'number_of_male': number_of_male,
      'number_of_female': number_of_female,
      'number_of_died': number_of_died,
      'date_of_birth': dateOfBirth,
    };
  }
}