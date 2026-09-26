import 'package:flutter/material.dart';
import 'package:build_managment/features/auth/presentation/pages/resident/create_apartment_page.dart';
import 'package:build_managment/features/auth/presentation/pages/resident/join_aparment_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color darkSlate = Color(0xFF0F172A);
    const Color softBg = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: softBg,

      // --- HEADER (Geri Tuşu) ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: darkSlate),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // --- 1. GÖRSEL ALAN (Modern Ikonografi) ---
              Stack(
                alignment: Alignment.center,
                children: [
                  // Arkadaki Hare
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Öndeki İkon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.apartment_rounded, // Veya business_rounded
                      size: 48,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // --- 2. BAŞLIKLAR ---
              const Text(
                "Yönetim Sistemi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkSlate,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Apartman ve site yönetim süreçlerinizi\ndijitalleştirin, kolayca takip edin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // --- 3. BUTONLAR ---
              Column(
                children: [
                  // Primary Button (Mavi)
                  _buildActionButton(
                    context: context,
                    text: "Yeni Bina Oluştur",
                    icon: Icons.add_location_alt_outlined,
                    bgColor: primaryBlue,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateApartmentPage()));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Secondary Button (Beyaz/Outline)
                  _buildActionButton(
                    context: context,
                    text: "Mevcut Binaya Katıl",
                    icon: Icons.login_rounded,
                    bgColor: Colors.white,
                    textColor: primaryBlue,
                    isOutline: true,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinApartmentPage()));
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Footer
              Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- BUTON WIDGET'I ---
  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Standart modern yükseklik
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: isOutline ? 0 : 8,
          shadowColor: isOutline ? null : bgColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Biraz daha yumuşak köşeler
            side: isOutline ? BorderSide(color: Colors.grey.shade300, width: 1.5) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}