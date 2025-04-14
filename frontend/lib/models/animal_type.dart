class AnimalType {
  final int id;
  final String name;

  AnimalType({required this.id, required this.name});

  factory AnimalType.fromJson(Map<String, dynamic> json) {
    return AnimalType(
      id: json['id'],
      name: json['name'],
    );
  }
}