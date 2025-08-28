import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/change_password_screen.dart';
import 'models/auth_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nike Store',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthCheckScreen(),
      routes: {
        '/payment_methods': (context) => const PaymentMethodsScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initializeAuth();
      }
    });
  }
  
  Future<void> _initializeAuth() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      await Provider.of<AuthModel>(context, listen: false).checkAuthStatus();
    } catch (e) {
      debugPrint('Error during auth initialization: $e');
    } finally {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);

    if (!_initialized || authModel.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Nike-Logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Загрузка приложения...'),
            ],
          ),
        ),
      );
    }

    return authModel.isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}