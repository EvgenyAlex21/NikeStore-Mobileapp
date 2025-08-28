import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/store.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';
import 'create_pre_order_screen.dart';
import 'stores_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product, String, int)? onAddToCart;
  
  const ProductDetailScreen({
    super.key, 
    required this.product, 
    this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = '';
  int _quantity = 1;
  late List<Product> _relatedProducts;
  String? _selectedColor;
  late List<Store> _availableStores;
  
  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes[0];
    }
    _relatedProducts = widget.product.getRelatedProducts();
  _selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors.first : null;
  _availableStores = demoStores.where((s) => widget.product.storeIds.contains(s.id)).toList();
  }
  
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }
  
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            if (widget.product.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'НОВИНКА',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.product.price.toInt()} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (widget.product.colors.isNotEmpty) ...[
                          const Text('Цвета:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: widget.product.colors.map((c) {
                              final sel = c == _selectedColor;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.primary : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(c, style: TextStyle(color: sel ? Colors.white : Colors.black)),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        const Text(
                          'Размеры:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.product.sizes.length,
                            itemBuilder: (context, index) {
                              final size = widget.product.sizes[index];
                              final isSelected = size == _selectedSize;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            const Text(
                              'Количество:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: _decrementQuantity,
                                    color: AppColors.primary,
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _incrementQuantity,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        if (widget.product.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Описание:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.product.description),
                        ],
                        
                        const SizedBox(height: 24),

                        if (_availableStores.isNotEmpty) ...[
                          const Text('Доступен в магазинах:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(
                            children: _availableStores.map((s) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(backgroundImage: AssetImage(s.imageUrl)),
                              title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              subtitle: Text(s.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: IconButton(
                                icon: const Icon(Icons.store_mall_directory),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => StoresScreen(stores: demoStores)));
                                },
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        if (_relatedProducts.isNotEmpty) ...[
                          const Text(
                            'Вам также может понравиться:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _relatedProducts.length,
                              itemBuilder: (context, index) {
                                final relatedProduct = _relatedProducts[index];
                                return SizedBox(
                                  width: 180,
                                  child: ProductCard(
                                    product: relatedProduct,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailScreen(
                                            product: relatedProduct,
                                          ),
                                        ),
                                      );
                                    },
                                    onAddToCart: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Выберите размер'),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: relatedProduct.sizes.length,
                                              itemBuilder: (context, sizeIndex) {
                                                return ListTile(
                                                  title: Text(relatedProduct.sizes[sizeIndex]),
                                                  onTap: () {
                                                    final size = relatedProduct.sizes[sizeIndex];
                                                    if (widget.onAddToCart != null) {
                                                      widget.onAddToCart!(
                                                          relatedProduct, size, 1);
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoresScreen(stores: demoStores),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Найти в магазинах'),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePreOrderScreen(
                            product: widget.product,
                            preselectedSize: _selectedSize,
                            initialQuantity: _quantity,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.gradientEnd,
                    ),
                    child: const Text('Предзаказ'),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onAddToCart != null) {
                        widget.onAddToCart!(
                            widget.product, _selectedSize, _quantity);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Добавить в корзину'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}