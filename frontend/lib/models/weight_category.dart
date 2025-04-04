class WeightCategory {
  final int id;
  final String name;

  WeightCategory({required this.id, required this.name});

  factory WeightCategory.fromJson(Map<String, dynamic> json) {
    return WeightCategory(
      id: json['id'],
      name: '${json['min_weight']}-${json['max_weight']} kg',
    );
  }
}
