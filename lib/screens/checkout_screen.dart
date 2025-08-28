import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/auth_model.dart';
import '../utils/theme.dart';
import '../models/payment_method.dart';
import '../widgets/app_text_field.dart';
import 'payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;
  final Function()? onOrderComplete;
  
  const CheckoutScreen({
    super.key, 
    required this.cart, 
    this.onOrderComplete,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _commentController = TextEditingController();
  final _cardNumberController = TextEditingController(text: '**** **** **** 0345');
  PaymentMethod? _selectedPayment;
  
  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    _commentController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
  final authModel = Provider.of<AuthModel>(context);
  final user = authModel.currentUser;
  
  if (user != null && user.paymentMethods.isNotEmpty) {
    _selectedPayment ??= user.paymentMethods.firstWhere(
      (m) => m.isDefault, 
      orElse: () => user.paymentMethods.first
    );
  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оформление заказа'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(widget.cart.items.first.product.imageUrl),
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
                                  widget.cart.items.first.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'размер ${widget.cart.items.first.size}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.cart.items.first.quantity} шт.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Адрес доставки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      label: 'Улица',
                      controller: _streetController,
                      hintText: 'Введите название улицы',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите улицу';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Дом',
                            controller: _houseController,
                            hintText: '12',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите номер';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            label: 'Квартира',
                            controller: _apartmentController,
                            hintText: '42',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      label: 'Комментарий для курьера',
                      controller: _commentController,
                      hintText: 'Код от домофона, подъезд и т.д.',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Способ оплаты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if ((user?.paymentMethods.isEmpty ?? true)) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Нет способов оплаты',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Для оформления заказа необходимо добавить способ оплаты.',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/payment_methods');
                              },
                              icon: const Icon(Icons.add_card),
                              label: const Text('Добавить способ оплаты'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPayment?.id,
                        decoration: InputDecoration(
                          labelText: 'Способ оплаты',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          isCollapsed: true,
                        ),
                        isDense: true,
                        isExpanded: true,
                        items: user!.paymentMethods.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(
                            '${m.type} ${m.cardNumber}${m.isDefault ? ' (основная)' : ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList(),
                        onChanged: (val) {
                          final u = Provider.of<AuthModel>(context, listen: false).currentUser;
                          if (u != null && val != null) {
                            setState(() {
                              _selectedPayment = u.paymentMethods.firstWhere((m) => m.id == val);
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ИТОГ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.cart.totalAmount.toInt()} рублей',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (user?.paymentMethods.isEmpty ?? true) || _selectedPayment == null
                      ? null 
                      : () {
                        if (_formKey.currentState!.validate()) {
                          final authModel = Provider.of<AuthModel>(context, listen: false);
                          final user = authModel.currentUser;
                          
                          if (user != null) {
                            if (user.paymentMethods.isEmpty || _selectedPayment == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Пожалуйста, добавьте способ оплаты перед оформлением заказа'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            final address = "г. Москва, ул. ${_streetController.text}, д. ${_houseController.text}${_apartmentController.text.isNotEmpty ? ", кв. ${_apartmentController.text}" : ""}";
                              
                            final newOrder = Order(
                              id: 'ORD-${(user.orders.length + 1).toString().padLeft(3, '0')}',
                              items: widget.cart.items.map((item) => OrderItem(
                                product: item.product,
                                quantity: item.quantity,
                                size: item.size,
                              )).toList(),
                              totalAmount: widget.cart.totalAmount,
                              orderDate: DateTime.now(),
                              status: 'В обработке',
                              address: address,
                              paymentMethodId: _selectedPayment?.id, 
                            );
                            
                            authModel.addOrder(newOrder);
                          
                            widget.cart.clear();
                            
                            if (widget.onOrderComplete != null) {
                              widget.onOrderComplete!();
                            }
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentSuccessScreen(),
                              ),
                            );
                          }
                        }
                      },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.gradientEnd,
                      disabledBackgroundColor: Colors.grey[400], 
                    ),
                    child: Text((user?.paymentMethods.isEmpty ?? true) || _selectedPayment == null
                      ? 'Добавьте способ оплаты'
                      : 'Оплатить'
                    ),
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