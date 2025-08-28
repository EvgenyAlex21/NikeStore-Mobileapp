import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user.dart';
import 'order.dart';
import 'favorite_store.dart';
import 'pre_order.dart';

class AuthModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      try {
        String? userData = prefs.getString('userData');
        
        if (userData != null) {
          debugPrint("Found user data: $userData");
          Map<String, dynamic> userMap = jsonDecode(userData);
          _currentUser = User.fromJson(userMap);

          String? usersRaw = prefs.getString('users');
          if (usersRaw == null && _currentUser?.email != null) {
            final backupKey = _passwordBackupKey(_currentUser!.email!);
            final backupPassword = prefs.getString(backupKey);
            if (backupPassword != null) {
              final reconstructed = _currentUser!.toJson();
              reconstructed['password'] = backupPassword;
              await prefs.setString('users', jsonEncode([reconstructed]));
            }
          }
        } else {
          debugPrint("No saved user data found");
          _currentUser = null;
        }
      } catch (innerError) {
        _error = 'Ошибка при чтении данных: $innerError';
        debugPrint(_error);
        _currentUser = null;
      }
    } catch (e) {
      _error = 'Ошибка при проверке статуса авторизации: $e';
      debugPrint(_error);
      _currentUser = null;  
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _passwordBackupKey(String email) => 'userPassword:$email';

  Future<void> _backupPassword(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_passwordBackupKey(email), password);
    } catch (e) {
      debugPrint('Backup password error: $e');
    }
  }
  
  Future<bool> register(String name, String surname, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? existingUsers = prefs.getString('users');
      
      List<Map<String, dynamic>> users = [];
      if (existingUsers != null) {
        List<dynamic> usersList = jsonDecode(existingUsers);
        users = List<Map<String, dynamic>>.from(usersList);
        
        bool emailExists = users.any((user) => user['email'] == email);
        if (emailExists) {
          _error = 'Пользователь с таким email уже существует';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final newUser = User(
        name: name,
        surname: surname,
        email: email,
        phoneNumber: '',
        orders: [],
        favoriteStores: [],
        preOrders: [],
        paymentMethods: [],
      );
      
      Map<String, dynamic> userWithPassword = newUser.toJson();
      userWithPassword['password'] = password;
      
      users.add(userWithPassword);
      await prefs.setString('users', jsonEncode(users));
  await _backupPassword(email, password);
      
      _currentUser = newUser;
      
      await prefs.setString('userData', jsonEncode(newUser.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при регистрации: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? existingUsers = prefs.getString('users');
      
      if (existingUsers == null) {
        _error = 'Пользователь не найден';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      List<dynamic> usersList = jsonDecode(existingUsers);
      List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(usersList);
      
      Map<String, dynamic>? foundUser;
      try {
        foundUser = users.firstWhere(
          (user) => user['email'] == email && user['password'] == password,
        );
      } catch (e) {
        _error = 'Неверный email или пароль';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (foundUser.isEmpty) {
        _error = 'Неверный email или пароль';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      foundUser.remove('password');
      
      _currentUser = User.fromJson(foundUser);
      
      await prefs.setString('userData', jsonEncode(foundUser));
  await _backupPassword(email, password);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при входе: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка при выходе: $e';
      debugPrint(_error);
    }
  }
  
  Future<bool> updateUserProfile(User updatedUser) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      String? existingUsers = prefs.getString('users');
      if (existingUsers != null) {
        List<dynamic> usersList = jsonDecode(existingUsers);
        List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(usersList);
        
  final oldEmail = _currentUser!.email;
  int userIndex = users.indexWhere((user) => user['email'] == oldEmail);
        
        if (userIndex != -1) {
          String? password = updatedUser.password?.isNotEmpty == true 
              ? updatedUser.password 
              : users[userIndex]['password'];
          
          users[userIndex] = updatedUser.toJson();
          
          if (updatedUser.password?.isEmpty ?? true) {
            users[userIndex]['password'] = password;
          }
          
          await prefs.setString('users', jsonEncode(users));

          if (oldEmail != null && updatedUser.email != null && oldEmail != updatedUser.email) {
            final oldKey = _passwordBackupKey(oldEmail);
            final newKey = _passwordBackupKey(updatedUser.email!);
            final oldPass = prefs.getString(oldKey);
            if (oldPass != null) {
              await prefs.setString(newKey, oldPass);
              await prefs.remove(oldKey);
            }
          }
        }
      }
      
      _currentUser = updatedUser;
      
      await prefs.setString('userData', jsonEncode(updatedUser.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при обновлении профиля: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addOrder(Order order) async {
    if (_currentUser == null) return false;
    
    try {
      _currentUser!.orders.add(order);
      await _persistCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при добавлении заказа: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<void> _persistCurrentUser() async {
    if (_currentUser == null) return;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(_currentUser!.toJson()));

      String? existingUsers = prefs.getString('users');
      if (existingUsers != null) {
        List<dynamic> usersList = jsonDecode(existingUsers);
        List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(usersList);
        int userIndex = users.indexWhere((user) => user['email'] == _currentUser!.email);
        if (userIndex != -1) {
          String? password = users[userIndex]['password'];
          users[userIndex] = _currentUser!.toJson();
          users[userIndex]['password'] = password; 
          await prefs.setString('users', jsonEncode(users));
          if (_currentUser!.email != null && password != null) {
            await prefs.setString(_passwordBackupKey(_currentUser!.email!), password);
          }
        }
      }
    } catch (e) {
      debugPrint('Persist error: $e');
    }
  }

  bool toggleFavoriteStore(FavoriteStore store) {
    if (_currentUser == null) return false;
    final existingIndex = _currentUser!.favoriteStores.indexWhere((s) => s.id == store.id);
    if (existingIndex >= 0) {
      _currentUser!.favoriteStores.removeAt(existingIndex);
      _persistCurrentUser();
      notifyListeners();
      return false; 
    } else {
      _currentUser!.favoriteStores.add(store);
      _persistCurrentUser();
      notifyListeners();
      return true;
    }
  }

  Future<bool> addPreOrder(PreOrder preOrder) async {
    if (_currentUser == null) return false;
    try {
      _currentUser!.preOrders.add(preOrder);
      await _persistCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при добавлении предзаказа: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> removePreOrder(String id) async {
    if (_currentUser == null) return false;
    try {
      _currentUser!.preOrders.removeWhere((p) => p.id == id);
      await _persistCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Ошибка при удалении предзаказа: $e';
      debugPrint(_error);
      return false;
    }
  }
}