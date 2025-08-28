class PaymentMethod {
  final String id;
  final String type; 
  final String cardNumber; 
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.cardNumber,
    this.expiryMonth = '12',
    this.expiryYear = '25',
    this.cvv = '***',
    this.isDefault = false,
  });
  
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiryMonth: json['expiryMonth'] ?? '12',
      expiryYear: json['expiryYear'] ?? '25',
      cvv: json['cvv'] ?? '***',
      isDefault: json['isDefault'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'isDefault': isDefault,
    };
  }
}