import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/mess_manager_page.dart';

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

class MessManagerHome extends StatelessWidget {
  const MessManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: const MessManagerPage(),
    );
  }
}
