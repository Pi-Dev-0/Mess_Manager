import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'pages/mess_manager_page.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MessManagerApp());
}

class MessManagerApp extends StatelessWidget {
  const MessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'মেস ম্যানেজার',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MessManagerHome(),
    );
  }
}

class MessManagerHome extends StatefulWidget {
  const MessManagerHome({super.key});

  @override
  State<MessManagerHome> createState() => _MessManagerHomeState();
}

class _MessManagerHomeState extends State<MessManagerHome> {
  final LocalAuthentication auth = LocalAuthentication();
  
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
    Future.microtask(() => _initNotifications());
  }

  Future<void> _initNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.init();
      await notificationService.scheduleDailyMealReminder();
      debugPrint('Notification Service initialized successfully');
    } catch (e) {
      debugPrint('Notification Init Error: $e');
    }
  }

  Future<void> _authenticate() async {
    try {
      if (mounted) {
        setState(() {
          _isAuthenticating = true;
        });
      }

      final bool isDeviceSupported = await auth.isDeviceSupported();
      
      if (!isDeviceSupported) {
        if (mounted) {
          setState(() {
            _isAuthenticated = true; // Skip if device doesn't support any local auth
            _isAuthenticating = false;
          });
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'অ্যাপটি আনলক করতে ফিঙ্গারপ্রিন্ট বা প্যাটার্ন ব্যবহার করুন',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows device PIN/Pattern as fallback
          useErrorDialogs: true,
        ),
      );

      if (mounted) {
        setState(() {
          _isAuthenticated = didAuthenticate;
          _isAuthenticating = false;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Auth Error: $e');
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
      // If it's a specific "NotAvailable" error (no security set up on device), 
      // we might want to let them in or show a warning. 
      // Usually, if the device is supported but nothing is set up, it's safer to allow entrance.
      if (e.code == 'NotAvailable') {
        setState(() => _isAuthenticated = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          SystemNavigator.pop();
        },
        child: const MessManagerPage(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'মেস ম্যানেজার সুরক্ষিত',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                'অ্যাপটি ব্যবহার করতে প্রমাণীকরণ সম্পন্ন করুন',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),
              
              if (_isAuthenticating)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('আনলক করুন', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text('বন্ধ করুন', style: TextStyle(color: Colors.grey.shade700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
