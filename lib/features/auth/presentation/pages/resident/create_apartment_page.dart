import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../home/data/services/apartment_service.dart';
import '../../../data/services/user_dao.dart';


class CreateApartmentPage extends StatefulWidget {
  const CreateApartmentPage({super.key});

  @override
  State<CreateApartmentPage> createState() => _CreateApartmentPageState();
}

class _CreateApartmentPageState extends State<CreateApartmentPage> {
  final nameController = TextEditingController();
  final flatController = TextEditingController();
  final ibanController = TextEditingController();

  final apartmentDao = ApartmentDao();
  final userDao = UserDao();

  bool isLoading = false;
  final Random _random = Random.secure();

  /// 6 haneli random sayı üretir
  String _generate6DigitCode() {
    return (_random.nextInt(900000) + 100000).toString();
  }

  /// Admin & Resident kodlarını çakışmayacak şekilde üretir
  Map<String, String> _generateCodes() {
    String adminCode;
    String residentCode;

    do {
      adminCode = _generate6DigitCode();
      residentCode = _generate6DigitCode();
    } while (adminCode == residentCode);

    return {
      "admin": adminCode,
      "resident": residentCode,
    };
  }

  Future<void> createApartment() async {
    if (nameController.text.isEmpty || flatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen zorunlu alanları doldurun!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Kullanıcı oturumu bulunamadı");

      final codes = _generateCodes();

      // 1. Binayı Oluştur
      final apartmentRef = await apartmentDao.createApartment(
        name: nameController.text.trim(),
        totalFlat: int.parse(flatController.text),
        iban: ibanController.text.trim(),
        adminCode: codes["admin"]!,
        residentCode: codes["resident"]!,
      );

      // 2. Kullanıcıyı Bina İÇİNE Admin Olarak Ekle
      await userDao.addUser(
        apartmentId: apartmentRef.id,
        flatNo: 0,
        role: "admin",
      );

      await userDao.addApartmentToGlobalUser(apartmentRef.id);

      if (!mounted) return;

      // 4. İşlem Başarılı - Dialog'u kapat ve Dashboard'a dön
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bina başarıyla oluşturuldu!")),
      );

    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Bina Oluştur"),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: _inputDecoration("Bina / Site Adı", Icons.business),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: flatController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Toplam Daire Sayısı", Icons.layers),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: ibanController,
                          decoration: _inputDecoration("Aidat IBAN No", Icons.account_balance_wallet),
                        ),
                        const SizedBox(height: 32),
                        isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: createApartment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Binayı Oluştur", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}