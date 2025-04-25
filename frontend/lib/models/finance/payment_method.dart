class PaymentMethod {
  final int id;
  final String name;
  final String? description;

  PaymentMethod({
    required this.id,
    required this.name,
    this.description,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}