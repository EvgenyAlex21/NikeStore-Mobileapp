import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../models/auth_model.dart';
import '../utils/theme.dart';
import '../widgets/app_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String? _avatarPath; 
  bool _changingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthModel>().currentUser!;
  _nameController = TextEditingController(text: user.name);
  _surnameController = TextEditingController(text: user.surname);
  _emailController = TextEditingController(text: user.email ?? '');
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    if (_changingAvatar) return;
    setState(() => _changingAvatar = true);
    try {
    final auth = context.read<AuthModel>();
    final user = auth.currentUser!;
      bool granted = true;
      if (!kIsWeb) {
        final status = await Permission.photos.request();
        granted = status.isGranted;
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Доступ к фото отклонен')),
            );
          }
        }
      }

      if (granted) {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1024,
        );
        if (picked != null) {
      if (!mounted) return; 
          setState(() => _avatarPath = picked.path);
          final updated = user.copyWith(avatarUrl: picked.path);
          await auth.updateUserProfile(updated);
        }
      } else if (kIsWeb) {
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (picked != null) {
      if (!mounted) return;
      setState(() => _avatarPath = picked.path);
          final updated = user.copyWith(avatarUrl: picked.path);
          await auth.updateUserProfile(updated);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка выбора изображения: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _changingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authModel = context.watch<AuthModel>();
    final user = authModel.currentUser!;
    final effectiveAvatar = _avatarPath ?? user.avatarUrl;

    ImageProvider? avatarProvider;
    if (effectiveAvatar != null && effectiveAvatar.isNotEmpty) {
      if (effectiveAvatar.startsWith('assets/')) {
        avatarProvider = AssetImage(effectiveAvatar);
      } else if (!kIsWeb) {
        avatarProvider = FileImage(File(effectiveAvatar));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование профиля')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: avatarProvider,
                      child: avatarProvider == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: _changingAvatar
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: _changeAvatar,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Имя',
                controller: _nameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Пожалуйста, введите имя' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Фамилия',
                controller: _surnameController,
                validator: (v) => (v == null || v.isEmpty) ? 'Пожалуйста, введите фамилию' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Пожалуйста, введите email';
                  if (!v.contains('@') || !v.contains('.')) return 'Введите корректный email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Телефон',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => null,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/change_password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Изменить пароль', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: authModel.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final updatedUser = user.copyWith(
                          name: _nameController.text.trim(),
                          surname: _surnameController.text.trim(),
                          email: _emailController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                        );
                        final success = await authModel.updateUserProfile(updatedUser);
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(
                          content: Text(success ? 'Профиль успешно обновлен' : 'Ошибка при обновлении профиля'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                        if (success) navigator.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: authModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    : const Text('Сохранить', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}