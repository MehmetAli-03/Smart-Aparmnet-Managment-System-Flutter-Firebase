import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/services/user_dao.dart';






class UsersListPage extends StatelessWidget {
  final String apartmentId;
  final userDao = UserDao();

  UsersListPage({super.key, required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: userDao.getUsers(apartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 120),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final userId = doc.id;
              final int flatNo = data["flatNo"] ?? 0;
              final String role = data["role"] ?? "resident";

              return _buildQuickActionCard(context, userId, flatNo, role);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String userId, int flatNo, String role) {
    bool isAdmin = role == "admin";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin ? Colors.amber.shade200 : const Color(0xFFF1F5F9),
          width: isAdmin ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. NUMARA KUTUSU
          _buildBigBadge(flatNo, isAdmin),

          const SizedBox(width: 12),

          // 2. İSİM VE DURUM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  flatNo == 0 ? "YÖNETİCİ" : "DAİRE $flatNo",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin ? "Tam Yetkili" : "Sakin",
                  style: TextStyle(
                    color: isAdmin ? Colors.amber.shade900 : const Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. ROL DEĞİŞTİRME SWITCH'İ
          _buildQuickSwitch(userId, role),

          const SizedBox(width: 8),

          // 4. SİLME BUTONU (YENİ EKLENDİ)
          _buildDeleteButton(context, userId, flatNo),
        ],
      ),
    );
  }

  // YENİ EKLENEN SİLME BUTONU WIDGET'I
  Widget _buildDeleteButton(BuildContext context, String userId, int flatNo) {
    return InkWell(
      onTap: () => _showDeleteConfirmation(context, userId, flatNo),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Çok açık kırmızı
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)), // Açık kırmızı sınır
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Color(0xFFDC2626), // Koyu kırmızı ikon
          size: 20,
        ),
      ),
    );
  }

  // YENİ EKLENEN ONAY PENCERESİ
  void _showDeleteConfirmation(BuildContext context, String userId, int flatNo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Kullanıcıyı Sil"),
        content: Text(
          "Daire $flatNo kullanıcısını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
          style: const TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              // DAO sınıfınızda deleteUser metodunu çağırmalısınız
              // userDao.deleteUser(apartmentId, userId);

              // Örnek doğrudan silme (Eğer DAO'da metodunuz yoksa):
              FirebaseFirestore.instance
                  .collection('apartments')
                  .doc(apartmentId)
                  .collection('users')
                  .doc(userId)
                  .delete();

              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Kullanıcı silindi"), backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  Widget _buildBigBadge(int flatNo, bool isAdmin) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAdmin
              ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (isAdmin ? Colors.amber : Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          flatNo.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSwitch(String userId, String currentRole) {
    bool isAdmin = currentRole == "admin";

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14), // Biraz daha karemsi
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleButton(
            userId: userId,
            label: "Sakin",
            isActive: !isAdmin,
            activeColor: Colors.white,
            textColor: const Color(0xFF2563EB),
            targetRole: "resident",
          ),
          const SizedBox(width: 4),
          _roleButton(
            userId: userId,
            label: "Yönetici",
            isActive: isAdmin,
            activeColor: Colors.white,
            textColor: const Color(0xFFD97706),
            targetRole: "admin",
          ),
        ],
      ),
    );
  }

  Widget _roleButton({
    required String userId,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color textColor,
    required String targetRole,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          userDao.updateUserRole(apartmentId: apartmentId, userId: userId, role: targetRole);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? textColor : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Henüz kullanıcı yok"));
  }
}