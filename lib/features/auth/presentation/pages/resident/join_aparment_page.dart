import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../home/data/services/apartment_service.dart';
import '../../../data/services/user_dao.dart';


class JoinApartmentPage extends StatefulWidget {
  const JoinApartmentPage({super.key});

  @override
  State<JoinApartmentPage> createState() => _JoinApartmentPageState();
}

class _JoinApartmentPageState extends State<JoinApartmentPage> {
  final codeController = TextEditingController();
  final flatController = TextEditingController();

  final apartmentDao = ApartmentDao();
  final userDao = UserDao();

  bool isLoading = false;

  Future<void> joinApartment() async {
    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bina kodu boş olamaz")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final snap = await apartmentDao.findByCode(codeController.text.trim());

      if (snap.docs.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz bina kodu")));
        return;
      }

      final apartmentDoc = snap.docs.first;
      final apartmentId = apartmentDoc.id;
      final data = apartmentDoc.data() as Map<String, dynamic>;

      final adminCode = data["adminCode"];
      final residentCode = data["residentCode"];
      final totalFlat = data["totalFlat"];

      late String role;
      if (codeController.text.trim() == adminCode) role = "admin";
      else if (codeController.text.trim() == residentCode) role = "resident";
      else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kod eşleşmedi")));
        return;
      }

      // --- ADMIN GİRİŞİ ---
      if (role == "admin") {
        final adminExists = await userDao.adminExists(apartmentId);
        if (!adminExists) {
          await userDao.addUser(apartmentId: apartmentId, flatNo: 0, role: "admin");
        }

        // 🆕 Global Profile Ekle
        await userDao.addApartmentToGlobalUser(apartmentId);

        if (!mounted) return;
        Navigator.pop(context); // Dashboard'a dön
        return;
      }

      // --- RESIDENT GİRİŞİ ---
      if (flatController.text.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Daire numarası giriniz")));
        return;
      }

      final flatNo = int.parse(flatController.text);
      if (flatNo < 1 || flatNo > totalFlat) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Geçerli daire: 1 - $totalFlat")));
        return;
      }

      final isOccupied = await userDao.isFlatOccupied(apartmentId: apartmentId, flatNo: flatNo);
      if (isOccupied) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu daire zaten dolu")));
        return;
      }

      // Binaya kullanıcıyı ekle
      await userDao.addUser(apartmentId: apartmentId, flatNo: flatNo, role: "resident");

      // 🆕 Global Profile Ekle
      await userDao.addApartmentToGlobalUser(apartmentId);

      if (!mounted) return;
      Navigator.pop(context); // Dashboard'a dön

    } catch (e) {
      setState(() => isLoading = false);
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bir hata oluştu")));
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Binaya Katıl"),
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
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: codeController,
                          decoration: _inputDecoration("Bina Kodu", Icons.vpn_key_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: flatController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Daire Numaranız", Icons.door_front_door_outlined),
                        ),
                        const SizedBox(height: 32),
                        isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: joinApartment,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            child: const Text("Giriş Yap", style: TextStyle(color: Colors.white, fontSize: 16)),
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