class FavoriteStore {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  
  FavoriteStore({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
  });
  
  factory FavoriteStore.fromJson(Map<String, dynamic> json) {
    return FavoriteStore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      address: json['address'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
    };
  }
}

List<FavoriteStore> demoFavoriteStores = [
  FavoriteStore(
    id: '1',
    name: 'Nike Store Москва',
    imageUrl: 'assets/images/Nike AIR MAX SC.jpg',
    address: 'г. Москва, ТЦ "Авиапарк", Ходынский бульвар, 4',
  ),
  FavoriteStore(
    id: '2',
    name: 'Nike Store Санкт-Петербург',
    imageUrl: 'assets/images/Nike M Reax 8 Tr Mesh.jpg',
    address: 'г. Санкт-Петербург, ТЦ "Галерея", Лиговский пр., 30',
  ),
  FavoriteStore(
    id: '3',
    name: 'Nike Factory Store',
    imageUrl: 'assets/images/Nike Nike Air Jordan 1 Dior X High Chicago.jpg',
    address: 'г. Москва, ТЦ "Метрополис", Ленинградское шоссе, 16А',
  ),
];