import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../utils/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _errorMessage;
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Изменить пароль'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ),
              
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Текущий пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите текущий пароль';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Новый пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите новый пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен содержать не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Подтвердите новый пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, подтвердите новый пароль';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Пароли не совпадают';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Изменить пароль'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isSubmitting = true;
      });
      
      final authModel = Provider.of<AuthModel>(context, listen: false);
      
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      
      final email = authModel.currentUser?.email ?? '';
      
      bool isCurrentPasswordValid = await _validateCurrentPassword(email, currentPassword);
      
      if (!isCurrentPasswordValid) {
        if (!mounted) return; 
        setState(() {
          _errorMessage = 'Текущий пароль неверен';
          _isSubmitting = false;
        });
        return;
      }
      
      bool success = await _updatePassword(email, newPassword);
      
      if (!mounted) return;
      if (success) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('Пароль успешно изменен')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Не удалось изменить пароль. Пожалуйста, попробуйте еще раз.';
          _isSubmitting = false;
        });
      }
    }
  }
  
  Future<bool> _validateCurrentPassword(String email, String password) async {
    
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final currentUser = authModel.currentUser;
      
  bool isValid = await authModel.login(email, password);
      
      if (currentUser != null && !isValid) {
        authModel.clearError();
      }
      
      return isValid;
    } catch (e) {
      debugPrint('Ошибка при проверке пароля: $e');
      return false;
    }
  }
  
  Future<bool> _updatePassword(String email, String newPassword) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final updatedUser = authModel.currentUser!.copyWith(
        password: newPassword,
      );
      
  bool success = await authModel.updateUserProfile(updatedUser);
      
      return success;
    } catch (e) {
      debugPrint('Ошибка при обновлении пароля: $e');
      return false;
    }
  }
}