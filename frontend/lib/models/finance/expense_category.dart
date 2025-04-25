class ExpenseCategory {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}