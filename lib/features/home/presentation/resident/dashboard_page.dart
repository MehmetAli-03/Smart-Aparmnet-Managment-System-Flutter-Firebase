import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_page.dart';
import '../../../settings/presentation/pages/settings.dart';
import '../admin/admin_page.dart';
import '../../../auth/presentation/pages/resident/auth_page.dart';
import 'resident_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // --- YÖNLENDİRME MANTIĞI ---
  Future<void> _navigateToBuilding(BuildContext context, String apartmentId, Map<String, dynamic> aptData) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu binada kaydınız bulunamadı.")));
      return;
    }

    final userData = userDoc.data()!;
    final role = userData['role'];

    if (!context.mounted) return;

    if (role == 'admin') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(
        apartmentId: apartmentId,
        adminCode: aptData['adminCode'],
        residentCode: aptData['residentCode'],
      )));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResidentPage(
        apartmentId: apartmentId,
        flatNo: userData['flatNo'],
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const AuthPage();

    // Tarih Formatı (Türkçe)
    String dateStr = DateFormat('d MMMM, EEEE', 'tr_TR').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Column(
        children: [
          // --- HEADER (Ayarlar ve Çıkış Butonları Yan Yana) ---
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x402563EB),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Binalarım",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12), // İki buton arası boşluk
                    // ÇIKIŞ BUTONU
                    InkWell(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8), // Çıkış olduğunu belli etmek için hafif kırmızımsı yapabiliriz veya aynı bırakabiliriz
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- LİSTE ALANI ---
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Veri alınamadı"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var userData = snapshot.data!.data() as Map<String, dynamic>?;
                List<dynamic> joinedApartments = userData?['joinedApartments'] ?? [];

                if (joinedApartments.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: joinedApartments.length,
                  itemBuilder: (context, index) {
                    return _buildModernCard(context, joinedApartments[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // --- FAB ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage())),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  // --- KART TASARIMI ---
  Widget _buildModernCard(BuildContext context, String apartmentId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('apartments').doc(apartmentId).get(),
      builder: (context, aptSnapshot) {
        if (!aptSnapshot.hasData) {
          return Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          );
        }

        var aptData = aptSnapshot.data!.data() as Map<String, dynamic>;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64748B).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _navigateToBuilding(context, apartmentId, aptData),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      height: 56, width: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aptData['name'] ?? "İsimsiz Bina",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.door_front_door_outlined, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                "${aptData['totalFlat']} Daire",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- BOŞ DURUM ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: const Icon(Icons.add_business_outlined, size: 64, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Henüz Bir Bina Yok",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Yönetmeye başlamak veya bir siteye katılmak için sağ alttaki butonu kullanın.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}


