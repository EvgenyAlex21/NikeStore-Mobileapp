import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../models/order.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Cart _cart = Cart();
  bool _isLoadingCart = true;

  @override
  void initState() {
    super.initState();
    _restoreCart();
  }

  Future<void> _restoreCart() async {
    final prefs = await SharedPreferences.getInstance();
    _cart.loadFromJsonString(prefs.getString(CartStorageKeys.cartItems));
    setState(() {
      _isLoadingCart = false;
    });
  }

  Future<void> _persistCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CartStorageKeys.cartItems, _cart.dump());
  }

  void addToCart(Product product, String size, int quantity) {
    setState(() {
      _cart.addItem(product, size, quantity: quantity);
    });
    _persistCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Добавлено в корзину: ${product.name} x$quantity'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void clearCart() {
    setState(() {
      _cart.clear();
    });
    _persistCart();
  }

  void openProfile() => setState(() => _selectedIndex = 2);
  void openCart() => setState(() => _selectedIndex = 1);

  void repeatOrder(Order order) {
    for (final item in order.items) {
      _cart.addItem(item.product, item.size, quantity: item.quantity);
    }
    setState(() => _selectedIndex = 1);
    _persistCart();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товары добавлены в корзину')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCart) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      HomeScreen(onAddToCart: addToCart, onOpenProfile: openProfile),
      CartScreen(
        cart: _cart,
        onOrderComplete: clearCart,
        onChanged: () {
          if (mounted) setState(() {});
          _persistCart();
        },
      ),
      ProfileScreen(
        onRepeatOrder: repeatOrder,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppColors.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withAlpha(153),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (_cart.totalItems > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _cart.totalItems > 99 ? '99+' : _cart.totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Корзина',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}