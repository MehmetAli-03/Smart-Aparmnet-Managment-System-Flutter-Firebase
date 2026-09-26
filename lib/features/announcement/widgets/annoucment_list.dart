import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/services/annoucment_service.dart';


class AnnouncementList extends StatelessWidget {
  final String apartmentId;
  final dao = FirebaseDao();

  AnnouncementList({super.key, required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // 1. Önce kullanıcının rolünü öğreniyoruz (Admin mi?)
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('apartments')
          .doc(apartmentId)
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, userSnapshot) {
        // Kullanıcı verisi yüklenirken
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }

        // Admin kontrolü
        bool isAdmin = false;
        if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          isAdmin = userData['role'] == 'admin';
        }

        // 2. Şimdi duyuruları listeliyoruz
        return StreamBuilder<QuerySnapshot>(
          stream: dao.announcementStream(apartmentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final announcementId = doc.id; // Silme işlemi için ID lazım
                final DateTime date = (doc["createdAt"] != null)
                    ? (doc["createdAt"] as dynamic).toDate()
                    : DateTime.now();

                return _buildAnnouncementCard(
                    context,
                    doc,
                    date,
                    isAdmin,
                    announcementId
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, QueryDocumentSnapshot doc, DateTime date, bool isAdmin, String announcementId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Sol Şerit
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 6,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık ve İkon
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 4),
                            Icon(Icons.info_outline_rounded, color: const Color(0xFF2563EB).withOpacity(0.7), size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                doc["title"] ?? "Duyuru",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.4,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Saat Pulu
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(date),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // İçerik
                  Text(
                    doc["content"] ?? "",
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.6,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Alt Satır
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMMM yyyy', 'tr_TR').format(date),
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      // Eğer Admin değilse normal ok ikonu, Admin ise burada bir şey göstermiyoruz (yukarıya aldık veya buraya koyabiliriz)
                      if (!isAdmin)
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ],
              ),
            ),

            // 🔥 SADECE ADMİNE GÖRÜNEN SİLME BUTONU (SAĞ ÜST KÖŞE)
            if (isAdmin)
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteDialog(context, announcementId),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(24),
                        ),
                        border: Border.all(color: Colors.red.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 4),
                          Text(
                            "Sil",
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String announcementId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Duyuruyu Sil"),
        content: const Text("Bu duyuruyu kalıcı olarak silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await dao.deleteAnnouncement(apartmentId, announcementId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Duyuru silindi"), backgroundColor: Colors.red),
              );
            },
            child: const Text("Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            "Henüz duyuru yayınlanmadı.",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}