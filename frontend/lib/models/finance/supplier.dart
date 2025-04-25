class Supplier {
  final int id;
  final String name;
  final String? contactPerson;
  final String? email;
  final String? phone;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.email,
    this.phone,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contact_person'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}