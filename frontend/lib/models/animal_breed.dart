class AnimalBreed {
  final int id;
  final String name;

  AnimalBreed({required this.id, required this.name});

  factory AnimalBreed.fromJson(Map<String, dynamic> json) {
    return AnimalBreed(id: json['id'], name: json['name']);
  }
}
