import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../utils/theme.dart';

class PreOrdersScreen extends StatelessWidget {
  const PreOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthModel>(context);
    final preOrders = auth.currentUser?.preOrders ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Предзаказы'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
  body: preOrders.isEmpty
          ? const Center(
              child: Text('У вас нет активных предзаказов'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: preOrders.length,
              itemBuilder: (context, index) {
                final preOrder = preOrders[index];
                final DateFormat formatter = DateFormat('dd.MM.yyyy');
                final String formattedDate = formatter.format(preOrder.estimatedDeliveryDate);
                
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
                              'Предзаказ №${preOrder.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(preOrder.status).withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                preOrder.status,
                                style: TextStyle(
                                  color: _getStatusColor(preOrder.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 24),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(preOrder.product.imageUrl),
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
                                    preOrder.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Размер: ${preOrder.size}  •  Кол-во: ${preOrder.quantity}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(preOrder.product.price * preOrder.quantity).toInt()} ₽',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ожидаемая дата доставки: $formattedDate',
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Отмена предзаказа'),
                                      content: Text('Вы уверены, что хотите отменить предзаказ ${preOrder.product.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text('Нет'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final navigator = Navigator.of(ctx);
                                            await auth.removePreOrder(preOrder.id);
                                            if (context.mounted) {
                                              navigator.pop();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Предзаказ отменен'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Да'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Отменить'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Открываем страницу отслеживания...'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Отследить'),
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
    switch (status) {
      case 'В обработке':
        return Colors.blue;
      case 'Ожидает поставки':
        return Colors.orange;
      case 'В пути':
        return AppColors.primary;
      case 'Ожидает подтверждения':
        return Colors.amber;
      case 'Ожидает поступления на склад':
        return Colors.purple;
      case 'Готов к выдаче':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}