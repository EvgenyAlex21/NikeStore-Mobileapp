import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/auth_model.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Product, String, int) onAddToCart;
  final VoidCallback? onOpenProfile;
  const HomeScreen({super.key, required this.onAddToCart, this.onOpenProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentSlide = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;

  void _startAutoPlay() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentSlide + 1) % demoProducts.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<AuthModel>(context).currentUser?.name ?? 'Гость'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              widget.onOpenProfile?.call();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: demoProducts.length,
                onPageChanged: (i) => setState(() => _currentSlide = i),
                itemBuilder: (ctx, i) {
                  final p = demoProducts[i];
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              product: p,
                              onAddToCart: widget.onAddToCart,
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(p.imageUrl, fit: BoxFit.cover),
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(p.name, style: const TextStyle(color: Colors.white,fontSize: 12)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(demoProducts.length, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                width: _currentSlide == index ? 10 : 6,
                height: _currentSlide == index ? 10 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentSlide == index ? Colors.blue : Colors.grey.withAlpha(120),
                ),
              )),
            ),
            
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Подборка для вас',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            
            const SizedBox(height: 16),
            
            LayoutBuilder(builder: (context, constraints) {
              const horizontalPadding = 16.0; 
              const crossAxisSpacing = 10.0;
              const mainAxisSpacing = 10.0;
              final crossAxisCount = 2; 
              final totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
              final usableWidth = constraints.maxWidth - horizontalPadding * 2 - totalSpacing;
              final itemWidth = usableWidth / crossAxisCount;
              final itemHeight = itemWidth + 86;
              final ratio = itemWidth / itemHeight; 
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: ratio,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                  ),
                  itemCount: demoProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: demoProducts[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: demoProducts[index],
                              onAddToCart: widget.onAddToCart,
                            ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}