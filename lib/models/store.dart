import 'favorite_store.dart';
import 'product.dart';

class Store {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final String phoneNumber;
  final List<String> workingHours;
  final bool hasDelivery;
  
  Store({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.phoneNumber,
    required this.workingHours,
    this.hasDelivery = true,
  });
  
  FavoriteStore toFavoriteStore() {
    return FavoriteStore(
      id: id,
      name: name,
      imageUrl: imageUrl,
      address: address,
    );
  }
  
  List<Product> getAvailableProducts() {
    return demoProducts.where((product) => 
      product.storeIds.contains(id)
    ).toList();
  }
}

List<Store> demoStores = [
  Store(
    id: '1',
    name: 'Nike Store Москва',
    imageUrl: 'assets/images/Nike AIR MAX SC.jpg',
    address: 'г. Москва, ТЦ "Авиапарк", Ходынский бульвар, 4',
    phoneNumber: '+7 (495) 123-45-67',
    workingHours: ['Пн-Вс: 10:00-22:00'],
  ),
  Store(
    id: '2',
    name: 'Nike Store Санкт-Петербург',
    imageUrl: 'assets/images/Nike M Reax 8 Tr Mesh.jpg',
    address: 'г. Санкт-Петербург, ТЦ "Галерея", Лиговский пр., 30',
    phoneNumber: '+7 (812) 123-45-67',
    workingHours: ['Пн-Вс: 10:00-22:00'],
  ),
  Store(
    id: '3',
    name: 'Nike Factory Store',
    imageUrl: 'assets/images/Nike Nike Air Jordan 1 Dior X High Chicago.jpg',
    address: 'г. Москва, ТЦ "Метрополис", Ленинградское шоссе, 16А',
    phoneNumber: '+7 (495) 987-65-43',
    workingHours: ['Пн-Пт: 10:00-22:00', 'Сб-Вс: 10:00-23:00'],
  ),
  Store(
    id: '4',
    name: 'Nike Store Сочи',
    imageUrl: 'assets/images/Nike Nike Men sAir Force1 Low x Reigning Champ.jpg',
    address: 'г. Сочи, ул. Навагинская, 9',
    phoneNumber: '+7 (862) 123-45-67',
    workingHours: ['Пн-Вс: 09:00-21:00'],
  ),
  Store(
    id: '5',
    name: 'Nike Store Казань',
    imageUrl: 'assets/images/Nike Nike Air Max Plus.jpg',
    address: 'г. Казань, ул. Пушкина, 2',
    phoneNumber: '+7 (843) 123-45-67',
    workingHours: ['Пн-Вс: 10:00-22:00'],
  ),
];