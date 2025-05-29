class Farm {
  final int id;
  final String name;
  final double? sizeHectares;
  final String? owner;
  final bool isActive;

  final String street;
  final String? street2;
  final String city;
  final String postalCode;
  final String countryName;
  final String countryCode;

  Farm({
    required this.id,
    required this.name,
    this.sizeHectares,
    this.owner,
    required this.isActive,
    required this.street,
    this.street2,
    required this.city,
    required this.postalCode,
    required this.countryName,
    required this.countryCode,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'],
      name: json['name'],
      sizeHectares: (json['size_hectares'] as num?)?.toDouble(),
      owner: json['owner'] is Map
          ? json['owner']['username']
          : json['owner']?.toString(),
      isActive: json['is_active'] ?? true,
      street: json['street'] ?? '',
      street2: json['street2'],
      city: json['city'] ?? '',
      postalCode: json['postal_code'] ?? '',
      countryName: json['country_name'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size_hectares': sizeHectares,
      'owner': owner,
      'is_active': isActive,
      'street': street,
      'street2': street2,
      'city': city,
      'postal_code': postalCode,
      'country_name': countryName,
      'country_code': countryCode,
    };
  }

  @override
  String toString() => name;
}
