import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../../home/presentation/resident/dashboard_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  void _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen alanları doldurun")));
      return;
    }

    setState(() => isLoading = true);

    var user;
    try {
      if (isLogin) {
        user = await _authService.signIn(email, password);
      } else {
        if (name.isEmpty) {
          throw Exception("İsim alanı boş olamaz");
        }
        user = await _authService.register(email, password, name);
      }

      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const DashboardPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Modern Input Tasarımı (Kenarlıksız, Dolgulu)
  InputDecoration _modernInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 22),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), // Çok açık gri
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ALANI (Gradient & Kavis) ---
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)], // Koyu Mavi -> Açık Mavi
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.apartment_rounded, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("Bina Yönetim", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text("Profesyonel Yaşam Alanı", style: TextStyle(color: Colors.blue.shade100, fontSize: 16)),
                ],
              ),
            ),

            // --- FORM KARTI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Transform.translate(
                offset: const Offset(0, -40), // Kartı yukarı kaydırıp header ile birleştirme efekti
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isLogin ? "Giriş Yap" : "Yeni Hesap", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      Text(isLogin ? "Devam etmek için giriş yapın" : "Hemen aramıza katılın", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),

                      if (!isLogin) ...[
                        TextField(controller: _nameController, decoration: _modernInputDecoration("Ad Soyad", Icons.person_outline_rounded)),
                        const SizedBox(height: 16),
                      ],
                      TextField(controller: _emailController, decoration: _modernInputDecoration("E-posta Adresi", Icons.email_outlined), keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      TextField(controller: _passwordController, decoration: _modernInputDecoration("Şifre", Icons.lock_outline_rounded), obscureText: true),
                      const SizedBox(height: 30),

                      // --- BUTON ---
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _authenticate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            shadowColor: Colors.blue.withOpacity(0.5),
                          ),
                          child: Text(isLogin ? "Giriş Yap" : "Kayıt Ol", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- ALT METİN ---
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: RichText(
                text: TextSpan(
                  text: isLogin ? "Hesabın yok mu? " : "Zaten üye misin? ",
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  children: [
                    TextSpan(
                      text: isLogin ? "Kayıt Ol" : "Giriş Yap",
                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}