class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final String description;
  final List<String> colors;
  final String category;
  final bool isNew;
  final bool isPopular;
  final List<String> storeIds; 
  
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sizes,
    this.description = '',
    this.colors = const ['Белый', 'Чёрный'],
    this.category = 'Кроссовки',
    this.isNew = false,
    this.isPopular = false,
    this.storeIds = const ['1', '2', '3'], 
  });
  
  List<Product> getRelatedProducts() {
    return demoProducts
        .where((product) => 
            product.id != id && 
            product.name.contains('Nike'))
        .toList();
  }
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      sizes: json['sizes'] != null 
          ? List<String>.from(json['sizes']) 
          : ['40', '41', '42'],
      description: json['description'] ?? '',
      colors: json['colors'] != null 
          ? List<String>.from(json['colors']) 
          : ['Белый', 'Чёрный'],
      category: json['category'] ?? 'Кроссовки',
      isNew: json['isNew'] ?? false,
      isPopular: json['isPopular'] ?? false,
      storeIds: json['storeIds'] != null 
          ? List<String>.from(json['storeIds']) 
          : ['1', '2', '3'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'sizes': sizes,
      'description': description,
      'colors': colors,
      'category': category,
      'isNew': isNew,
      'isPopular': isPopular,
      'storeIds': storeIds,
    };
  }
}

List<Product> demoProducts = [
  Product(
    id: 1,
    name: 'NIKE AIR MAX SC',
    price: 12399,
    imageUrl: 'assets/images/Nike AIR MAX SC.jpg',
    sizes: ['36', '37', '38', '39', '40', '41', '42'],
    description: 'Классические кроссовки Nike Air Max SC с технологией амортизации Air и комфортным верхом из натуральной кожи и дышащего текстиля.',
    isPopular: true,
  ),
  Product(
    id: 2,
    name: 'NIKE REAX 8 TR MESH',
    price: 14399,
    imageUrl: 'assets/images/Nike M Reax 8 Tr Mesh.jpg',
    sizes: ['40', '41', '42', '43', '44', '45'],
    description: 'Тренировочные кроссовки Nike Reax 8 TR Mesh с технологией амортизации Reax, обеспечивающей стабильность и поддержку во время тренировок.',
    isNew: true,
  ),
  Product(
    id: 3,
    name: 'NIKE AIR JORDAN 1 DIOR',
    price: 102500,
    imageUrl: 'assets/images/Nike Nike Air Jordan 1 Dior X High Chicago.jpg',
    sizes: ['38', '39', '40', '41', '42', '43'],
    description: 'Коллаборация Nike и Dior - лимитированная версия культовых Air Jordan 1 в премиальном исполнении.',
    isPopular: true,
    isNew: true,
  ),
  Product(
    id: 4,
    name: 'NIKE AIR MAX PLUS',
    price: 18500,
    imageUrl: 'assets/images/Nike Nike Air Max Plus.jpg',
    sizes: ['36', '37', '38', '39', '40', '41', '42'],
    description: 'Nike Air Max Plus с фирменной системой амортизации Tuned Air и стильным градиентным верхом.',
  ),
  Product(
    id: 5,
    name: 'NIKE AIR FORCE 1 LOW X REIGNING CHAMP',
    price: 15990,
    imageUrl: 'assets/images/Nike Nike Men sAir Force1 Low x Reigning Champ.jpg',
    sizes: ['40', '41', '42', '43', '44', '45'],
    description: 'Коллаборация Nike x Reigning Champ для классических Air Force 1 в минималистичном дизайне.',
  ),
  Product(
    id: 6,
    name: 'NIKE SB DUNK HIGH PRO MEDIUM',
    price: 16790,
    imageUrl: 'assets/images/Nike Nike SB Dunk High Pro Medium.jpg',
    sizes: ['36', '37', '38', '39', '40', '41', '42'],
    description: 'Высокие кеды Nike SB Dunk для скейтбординга с прочным верхом и зонированной амортизацией.',
    isNew: true,
  ),
];