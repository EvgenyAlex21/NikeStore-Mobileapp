import 'product.dart';

class PreOrder {
  final String id;
  final Product product;
  final String size;
  final DateTime estimatedDeliveryDate;
  final String status;
  final int quantity;

  PreOrder({
    required this.id,
    required this.product,
    required this.size,
    required this.estimatedDeliveryDate,
    this.status = 'В обработке',
    this.quantity = 1,
  });
  
  factory PreOrder.fromJson(Map<String, dynamic> json) {
  return PreOrder(
    id: json['id'] ?? '',
    product: Product.fromJson(json['product']),
    size: json['size'] ?? '',
    estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
      ? DateTime.parse(json['estimatedDeliveryDate'])
      : DateTime.now().add(const Duration(days: 14)),
    status: json['status'] ?? 'В обработке',
    quantity: (json['quantity'] ?? 1) is int
      ? json['quantity'] ?? 1
      : int.tryParse(json['quantity'].toString()) ?? 1,
  );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'size': size,
      'estimatedDeliveryDate': estimatedDeliveryDate.toIso8601String(),
  'status': status,
  'quantity': quantity,
    };
  }
}

List<PreOrder> demoPreOrders = [
  PreOrder(
    id: '1',
    product: demoProducts[2],
    size: '42',
    estimatedDeliveryDate: DateTime.now().add(const Duration(days: 14)),
    status: 'Ожидает поставки',
    quantity: 2,
  ),
  PreOrder(
    id: '2',
    product: demoProducts[5],
    size: '41',
    estimatedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
    status: 'В пути',
    quantity: 1,
  ),
  PreOrder(
    id: '3',
    product: demoProducts[3],
    size: '43',
    estimatedDeliveryDate: DateTime.now().add(const Duration(days: 21)),
    status: 'Ожидает подтверждения',
    quantity: 1,
  ),
  PreOrder(
    id: '4',
    product: demoProducts[4],
    size: '42',
    estimatedDeliveryDate: DateTime.now().add(const Duration(days: 10)),
    status: 'В пути',
    quantity: 3,
  ),
  PreOrder(
    id: '5',
    product: demoProducts[1],
    size: '44',
    estimatedDeliveryDate: DateTime.now().add(const Duration(days: 30)),
    status: 'Ожидает поступления на склад',
    quantity: 1,
  ),
];