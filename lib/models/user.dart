import 'favorite_store.dart';
import 'order.dart';
import 'pre_order.dart';
import 'payment_method.dart';

class User {
  String name;
  String surname;
  String? avatarUrl;
  String? phoneNumber;
  String? email;
  String? password; 
  List<Order> orders;
  List<FavoriteStore> favoriteStores;
  List<PreOrder> preOrders;
  List<PaymentMethod> paymentMethods;
  
  User({
    this.name = '',
    this.surname = '',
    this.avatarUrl,
    this.phoneNumber,
    this.email,
    this.password,
    this.orders = const [],
    this.favoriteStores = const [],
    this.preOrders = const [],
    this.paymentMethods = const [],
  });
  
  User copyWith({
    String? name,
    String? surname,
    String? avatarUrl,
    String? phoneNumber,
    String? email,
    String? password,
    List<Order>? orders,
    List<FavoriteStore>? favoriteStores,
    List<PreOrder>? preOrders,
    List<PaymentMethod>? paymentMethods,
  }) {
    return User(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      orders: orders ?? this.orders,
      favoriteStores: favoriteStores ?? this.favoriteStores,
      preOrders: preOrders ?? this.preOrders,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
  
  factory User.fromJson(Map<String, dynamic> json) {
    List<Order> ordersList = [];
    List<FavoriteStore> favoritesList = [];
    List<PreOrder> preOrdersList = [];
    List<PaymentMethod> paymentsList = [];
    
    if (json['orders'] != null) {
      ordersList = List<Order>.from(
        (json['orders'] as List).map((order) => Order.fromJson(order))
      );
    }
    
    if (json['favoriteStores'] != null) {
      favoritesList = List<FavoriteStore>.from(
        (json['favoriteStores'] as List).map((store) => FavoriteStore.fromJson(store))
      );
    }
    
    if (json['preOrders'] != null) {
      preOrdersList = List<PreOrder>.from(
        (json['preOrders'] as List).map((preOrder) => PreOrder.fromJson(preOrder))
      );
    }
    
    if (json['paymentMethods'] != null) {
      paymentsList = List<PaymentMethod>.from(
        (json['paymentMethods'] as List).map((method) => PaymentMethod.fromJson(method))
      );
    }
    
    return User(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      password: json['password'],
      orders: ordersList,
      favoriteStores: favoritesList,
      preOrders: preOrdersList,
      paymentMethods: paymentsList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'orders': orders.map((order) => order.toJson()).toList(),
      'favoriteStores': favoriteStores.map((store) => store.toJson()).toList(),
      'preOrders': preOrders.map((preOrder) => preOrder.toJson()).toList(),
      'paymentMethods': paymentMethods.map((method) => method.toJson()).toList(),
    };
  }
  
  int get orderCount => orders.length;
  int get favoriteCount => favoriteStores.length;
  int get preOrderCount => preOrders.length;
  int get paymentMethodCount => paymentMethods.length;

  void addPaymentMethod(PaymentMethod method) {
    if (method.isDefault) {
      for (final m in paymentMethods) {
        m.isDefault = false;
      }
    }
    paymentMethods = [...paymentMethods, method];
  }

  void removePaymentMethod(String id) {
    paymentMethods = paymentMethods.where((m) => m.id != id).toList();
    if (paymentMethods.where((m) => m.isDefault).isEmpty && paymentMethods.isNotEmpty) {
      paymentMethods.first.isDefault = true; 
    }
  }

  void setDefaultPaymentMethod(String id) {
    for (final m in paymentMethods) {
      m.isDefault = m.id == id;
    }
  }
}

User currentUser = User(
  name: 'Travis',
  surname: 'Scott',
  avatarUrl: 'assets/images/Nike AIR MAX SC.jpg',
  phoneNumber: '+7 (999) 123-45-67',
  email: 'travis.scott@example.com',
  orders: demoOrders,
  favoriteStores: demoFavoriteStores,
  preOrders: demoPreOrders,
  paymentMethods: [
    PaymentMethod(id: 'pm1', type: 'Visa', cardNumber: '****0345', isDefault: true),
    PaymentMethod(id: 'pm2', type: 'MasterCard', cardNumber: '****1234'),
  ],
);