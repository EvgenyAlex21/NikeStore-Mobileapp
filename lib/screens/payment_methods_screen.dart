import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/payment_method.dart';
import '../utils/theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final user = authModel.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Пользователь не авторизован'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Способы оплаты'),
      ),
      body: Column(
        children: [
          Expanded(
            child: user.paymentMethods.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.credit_card_off, size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'Нет способов оплаты',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте вашу первую карту, чтобы оплачивать быстрее.',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPaymentMethodDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Добавить карту'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: user.paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = user.paymentMethods[index];
                      return _buildPaymentMethodCard(context, method);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddPaymentMethodDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить способ оплаты'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, PaymentMethod method) {
    final icon = method.type == 'Visa' 
        ? Icons.credit_card
        : method.type == 'MasterCard'
            ? Icons.credit_card
            : Icons.payment;
            
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          '${method.type} ${method.cardNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Истекает: ${method.expiryMonth}/${method.expiryYear}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Основная',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                if (!method.isDefault)
                  PopupMenuItem(
                    value: 'default',
                    child: const Text('Сделать основной'),
                  ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Редактировать'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Удалить'),
                ),
              ],
              onSelected: (value) {
                if (value == 'default') {
                  _setAsDefault(method);
                } else if (value == 'edit') {
                  _showEditPaymentMethodDialog(context, method);
                } else if (value == 'delete') {
                  _deletePaymentMethod(method);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _setAsDefault(PaymentMethod method) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final user = authModel.currentUser;
    
    if (user == null) return;
    
    final updatedPaymentMethods = user.paymentMethods.map((m) {
      if (m.id == method.id) {
        return PaymentMethod(
          id: m.id,
          type: m.type,
          cardNumber: m.cardNumber,
          expiryMonth: m.expiryMonth,
          expiryYear: m.expiryYear,
          cvv: m.cvv,
          isDefault: true,
        );
      } else {
        return PaymentMethod(
          id: m.id,
          type: m.type,
          cardNumber: m.cardNumber,
          expiryMonth: m.expiryMonth,
          expiryYear: m.expiryYear,
          cvv: m.cvv,
          isDefault: false,
        );
      }
    }).toList();
    
    authModel.updateUserProfile(
      user.copyWith(paymentMethods: updatedPaymentMethods),
    );
  }
  
  void _deletePaymentMethod(PaymentMethod method) {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final user = authModel.currentUser;
    
    if (user == null) return;
    
    if (user.paymentMethods.length == 1 && method.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нельзя удалить единственный способ оплаты'),
        ),
      );
      return;
    }
    
    final updatedPaymentMethods = user.paymentMethods.where((m) => m.id != method.id).toList();
    
    if (method.isDefault && updatedPaymentMethods.isNotEmpty) {
      updatedPaymentMethods[0] = PaymentMethod(
        id: updatedPaymentMethods[0].id,
        type: updatedPaymentMethods[0].type,
        cardNumber: updatedPaymentMethods[0].cardNumber,
        expiryMonth: updatedPaymentMethods[0].expiryMonth,
        expiryYear: updatedPaymentMethods[0].expiryYear,
        cvv: updatedPaymentMethods[0].cvv,
        isDefault: true,
      );
    }
    
    authModel.updateUserProfile(
      user.copyWith(paymentMethods: updatedPaymentMethods),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Способ оплаты удален'),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
  final typeController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryMonthController = TextEditingController();
  final expiryYearController = TextEditingController();
  final cvvController = TextEditingController();
  bool isDefault = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Добавить способ оплаты'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: typeController.text.isEmpty ? null : typeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Тип карты',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(value: 'MasterCard', child: Text('MasterCard')),
                        DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          typeController.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Номер карты',
                        border: OutlineInputBorder(),
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryMonthController,
                            decoration: const InputDecoration(
                              labelText: 'Месяц',
                              border: OutlineInputBorder(),
                              hintText: 'MM',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: expiryYearController,
                            decoration: const InputDecoration(
                              labelText: 'Год',
                              border: OutlineInputBorder(),
                              hintText: 'YY',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        hintText: 'XXX',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    CheckboxListTile(
                      title: const Text('Сделать основной'),
            value: isDefault,
                      onChanged: (value) {
                        setState(() {
              isDefault = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
          if (typeController.text.isEmpty ||
            cardNumberController.text.isEmpty ||
            expiryMonthController.text.isEmpty ||
            expiryYearController.text.isEmpty ||
            cvvController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Пожалуйста, заполните все поля'),
                        ),
                      );
                      return;
                    }
                    
                    final cardNumberDisplay = _formatCardNumber(cardNumberController.text);
                    final authModel = Provider.of<AuthModel>(context, listen: false);
                    final user = authModel.currentUser;
                    
                    if (user != null) {
                      final newPaymentMethod = PaymentMethod(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: typeController.text,
                        cardNumber: cardNumberDisplay,
                        expiryMonth: expiryMonthController.text,
                        expiryYear: expiryYearController.text,
                        cvv: cvvController.text,
                        isDefault: isDefault,
                      );
                      
                      final updatedPaymentMethods = [...user.paymentMethods];
                      
                      if (isDefault) {
                        for (var i = 0; i < updatedPaymentMethods.length; i++) {
                          updatedPaymentMethods[i] = PaymentMethod(
                            id: updatedPaymentMethods[i].id,
                            type: updatedPaymentMethods[i].type,
                            cardNumber: updatedPaymentMethods[i].cardNumber,
                            expiryMonth: updatedPaymentMethods[i].expiryMonth,
                            expiryYear: updatedPaymentMethods[i].expiryYear,
                            cvv: updatedPaymentMethods[i].cvv,
                            isDefault: false,
                          );
                        }
                      }
                      
                      final isFirstMethod = updatedPaymentMethods.isEmpty;
                      updatedPaymentMethods.add(PaymentMethod(
                        id: newPaymentMethod.id,
                        type: newPaymentMethod.type,
                        cardNumber: newPaymentMethod.cardNumber,
                        expiryMonth: newPaymentMethod.expiryMonth,
                        expiryYear: newPaymentMethod.expiryYear,
                        cvv: newPaymentMethod.cvv,
                        isDefault: isDefault || isFirstMethod,
                      ));
                      
                      authModel.updateUserProfile(
                        user.copyWith(paymentMethods: updatedPaymentMethods),
                      );
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditPaymentMethodDialog(BuildContext context, PaymentMethod method) {
  final typeController = TextEditingController(text: method.type);
  final cardNumberController = TextEditingController(text: _unformatCardNumber(method.cardNumber));
  final expiryMonthController = TextEditingController(text: method.expiryMonth);
  final expiryYearController = TextEditingController(text: method.expiryYear);
  final cvvController = TextEditingController(text: method.cvv);
  bool isDefault = method.isDefault;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Редактировать способ оплаты'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: typeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Тип карты',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(value: 'MasterCard', child: Text('MasterCard')),
                        DropdownMenuItem(value: 'Другое', child: Text('Другое')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          typeController.text = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Номер карты',
                        border: OutlineInputBorder(),
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryMonthController,
                            decoration: const InputDecoration(
                              labelText: 'Месяц',
                              border: OutlineInputBorder(),
                              hintText: 'MM',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: expiryYearController,
                            decoration: const InputDecoration(
                              labelText: 'Год',
                              border: OutlineInputBorder(),
                              hintText: 'YY',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        hintText: 'XXX',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    if (!method.isDefault)
                      CheckboxListTile(
                        title: const Text('Сделать основной'),
            value: isDefault,
                        onChanged: (value) {
                          setState(() {
              isDefault = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
          if (typeController.text.isEmpty ||
            cardNumberController.text.isEmpty ||
            expiryMonthController.text.isEmpty ||
            expiryYearController.text.isEmpty ||
            cvvController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Пожалуйста, заполните все поля'),
                        ),
                      );
                      return;
                    }
                    
                    final cardNumberDisplay = _formatCardNumber(cardNumberController.text);
                    final authModel = Provider.of<AuthModel>(context, listen: false);
                    final user = authModel.currentUser;
                    
                    if (user != null) {
                      final updatedPaymentMethods = [...user.paymentMethods];
                      final index = updatedPaymentMethods.indexWhere((m) => m.id == method.id);
                      
                      if (index != -1) {
                        if (isDefault && !method.isDefault) {
                          for (var i = 0; i < updatedPaymentMethods.length; i++) {
                            if (i != index) {
                              updatedPaymentMethods[i] = PaymentMethod(
                                id: updatedPaymentMethods[i].id,
                                type: updatedPaymentMethods[i].type,
                                cardNumber: updatedPaymentMethods[i].cardNumber,
                                expiryMonth: updatedPaymentMethods[i].expiryMonth,
                                expiryYear: updatedPaymentMethods[i].expiryYear,
                                cvv: updatedPaymentMethods[i].cvv,
                                isDefault: false,
                              );
                            }
                          }
                        }
                        
                        updatedPaymentMethods[index] = PaymentMethod(
                          id: method.id,
                          type: typeController.text,
                          cardNumber: cardNumberDisplay,
                          expiryMonth: expiryMonthController.text,
                          expiryYear: expiryYearController.text,
                          cvv: cvvController.text,
                          isDefault: isDefault || method.isDefault, 
                        );
                        
                        authModel.updateUserProfile(
                          user.copyWith(paymentMethods: updatedPaymentMethods),
                        );
                      }
                    }
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatCardNumber(String number) {
    if (number.length <= 4) return number;
    
    final lastDigits = number.substring(number.length - 4);
    return '**** **** **** $lastDigits';
  }
  
  String _unformatCardNumber(String number) {
    return number.replaceAll(RegExp(r'[^\d]'), '');
  }
}