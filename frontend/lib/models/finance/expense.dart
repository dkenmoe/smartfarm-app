class Expense {
  final int? id;
  final int categoryId;
  final String? categoryName;
  final String description;
  final double amount;
  final String date;
  final int? animalTypeId;
  final int? animalBreedId;
  final int? supplierId;
  final int? paymentMethodId;
  final String? invoiceNumber;
  final bool isRecurrent;
  final String status;
  final String? attachmentUrl;

  Expense({
    this.id,
    required this.categoryId,
    required this.description,
    required this.amount,
    required this.date,
    this.categoryName,
    this.animalTypeId,
    this.animalBreedId,
    this.supplierId,
    this.paymentMethodId,
    this.invoiceNumber,
    this.isRecurrent = false,
    this.status = 'completed',
    this.attachmentUrl,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      categoryId: json['category']["id"],
      description: json['description'] ?? '',
      amount: double.parse(json['amount'].toString()),
      date: json['date'],
      animalTypeId: json['animal_type'],
      animalBreedId: json['animal_breed'],
      supplierId: json['supplier'],
      paymentMethodId: json['payment_method'],
      invoiceNumber: json['invoice_number'],
      isRecurrent: json['is_recurrent'] ?? false,
      status: json['status'] ?? 'completed',
      attachmentUrl: json['attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'category_id': categoryId,
      'description': description,
      'amount': amount,
      'date': date,
      'is_recurrent': isRecurrent,
      'status': status,
    };

    // Add optional fields only if they have values
    if (animalTypeId != null) data['animal_type_id'] = animalTypeId;
    if (animalBreedId != null) data['animal_type_id'] = animalBreedId;
    if (supplierId != null) data['supplier_id'] = supplierId;
    if (paymentMethodId != null) data['payment_method_id'] = paymentMethodId;
    if (invoiceNumber != null && invoiceNumber!.isNotEmpty) {
      data['invoice_number'] = invoiceNumber;
    }
    
    return data;
  }

  // Create a copy of this expense with updated fields
  Expense copyWith({
    int? id,
    int? categoryId,
    String? description,
    double? amount,
    String? date,
    int? animalTypeId,
    int? animalBreedId,
    int? supplierId,
    int? paymentMethodId,
    String? invoiceNumber,
    bool? isRecurrent,
    String? status,
    String? attachmentUrl,
  }) {
    return Expense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      animalTypeId: animalTypeId ?? this.animalTypeId,
      animalBreedId: animalBreedId ?? this.animalBreedId,
      supplierId: supplierId ?? this.supplierId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      isRecurrent: isRecurrent ?? this.isRecurrent,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}