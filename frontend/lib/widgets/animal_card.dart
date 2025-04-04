class Animal {
  final int id;
  final String name;
  final String species;
  final double weight;
  final String healthStatus;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.weight,
    required this.healthStatus,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      weight: json['weight'].toDouble(),
      healthStatus: json['health_status'],
    );
  }
}
