import 'product.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String status;
  final String address;
  final String? paymentMethodId; 
  
  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = 'Доставлен',
    required this.address,
    this.paymentMethodId, 
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: json['totalAmount'] ?? 0.0,
      orderDate: json['orderDate'] != null 
        ? DateTime.parse(json['orderDate']) 
        : DateTime.now(),
      status: json['status'] ?? 'Доставлен',
      address: json['address'] ?? '',
      paymentMethodId: json['paymentMethodId'], 
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'address': address,
      'paymentMethodId': paymentMethodId, 
    };
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final String size;
  
  OrderItem({
    required this.product,
    required this.quantity,
    required this.size,
  });
  
  double get totalPrice => product.price * quantity;
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      size: json['size'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
    };
  }
}

List<Order> demoOrders = [
  Order(
    id: 'ORD-001',
    items: [
      OrderItem(
        product: demoProducts[0], 
        quantity: 1,
        size: '42',
      ),
    ],
    totalAmount: 12399.0,
    orderDate: DateTime.now().subtract(const Duration(days: 5)),
    status: 'Доставлен',
    address: 'г. Москва, ул. Тверская, д. 10, кв. 45',
    paymentMethodId: 'pm1', 
  ),
  Order(
    id: 'ORD-002',
    items: [
      OrderItem(
        product: demoProducts[1], 
        quantity: 1,
        size: '43',
      ),
      OrderItem(
        product: demoProducts[4], 
        quantity: 1,
        size: '42',
      ),
    ],
    totalAmount: 30389.0,
    orderDate: DateTime.now().subtract(const Duration(days: 15)),
    status: 'Доставлен',
    address: 'г. Москва, ул. Арбат, д. 20, кв. 15',
    paymentMethodId: 'pm1', 
  ),
  Order(
    id: 'ORD-003',
    items: [
      OrderItem(
        product: demoProducts[5], 
        quantity: 2,
        size: '41',
      ),
    ],
    totalAmount: 33580.0,
    orderDate: DateTime.now().subtract(const Duration(days: 30)),
    status: 'Доставлен',
    address: 'г. Москва, Ленинский пр-т, д. 80, кв. 120',
    paymentMethodId: 'pm2', 
  ),
];