import 'package:build_managment/features/home/presentation/resident/dashboard_page.dart';
import 'package:build_managment/core/services/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/auth/presentation/pages/resident/auth_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await LocalNotificationService.init();
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bina Yönetim',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      // İŞTE SİHİR BURADA:
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Durum: Firebase henüz bağlanmaya çalışıyorsa bekleme ekranı göster
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Durum: Kullanıcı verisi var (Daha önce girmiş)
          if (snapshot.hasData) {
            return const DashboardPage();
          }

          // 3. Durum: Kullanıcı yok (Giriş yapmamış)
          return const AuthPage();
        },
      ),
    );
  }
}