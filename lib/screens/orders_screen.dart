import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../utils/theme.dart';

class OrdersScreen extends StatelessWidget {
  final List<Order> orders;
  final void Function(Order order)? onRepeat;
  
  const OrdersScreen({
    super.key,
    required this.orders,
    this.onRepeat,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('У вас нет заказов'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final DateFormat formatter = DateFormat('dd.MM.yyyy');
                final String formattedDate = formatter.format(order.orderDate);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Заказ ${order.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _StatusBadge(status: order.status, color: _getStatusColor(order.status)),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'от $formattedDate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        
                        const Divider(height: 24),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = order.items[itemIndex];
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: AssetImage(item.product.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Размер: ${item.size} • Кол-во: ${item.quantity}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.product.price.toInt()} ₽',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        const Divider(),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Итого:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${order.totalAmount.toInt()} ₽',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Адрес: ${order.address}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    isScrollControlled: true,
                                    builder: (_) => DraggableScrollableSheet(
                                      expand: false,
                                      builder: (ctx, scrollCtrl) => Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: ListView(
                                          controller: scrollCtrl,
                                          children: [
                                            Text('Заказ ${order.id}', style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Text('Статус: ${order.status}'),
                                            const SizedBox(height: 8),
                                            ...order.items.map((it) => ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(backgroundImage: AssetImage(it.product.imageUrl)),
                                              title: Text(it.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                              subtitle: Text('Размер: ${it.size}  Кол-во: ${it.quantity}'),
                                              trailing: Text('${it.product.price.toInt()} ₽'),
                                            )),
                                            const Divider(),
                                            Text('Адрес доставки:\n${order.address}'),
                                            const SizedBox(height: 12),
                                            Text('Итого: ${order.totalAmount.toInt()} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              onPressed: () { Navigator.pop(ctx); },
                                              child: const Text('Закрыть'),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                                child: const Text('Детали'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (onRepeat != null) {
                                    onRepeat!(order);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Товары добавлены. Переходим в корзину')));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Повторить заказ'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'доставлен':
        return Colors.green;
      case 'в пути':
        return AppColors.primary;
      case 'в обработке':
      case 'обрабатывается':
        return Colors.orange;
      case 'отменен':
        return Colors.red;
      case 'ожидает подтверждения':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}