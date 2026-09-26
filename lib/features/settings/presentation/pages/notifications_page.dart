import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  final String apartmentId;

  const NotificationsPage({super.key, required this.apartmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Bildirimler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // SADECE SON 8 BİLDİRİMİ ÇEKİYORUZ (Performans ve Kota Dostu)
        stream: FirebaseFirestore.instance
            .collection('apartments')
            .doc(apartmentId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(8)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Bir hata oluştu."));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              // INDEX değerini de karta gönderiyoruz ki ilk 3'ü bulabilelim
              return _buildNotificationCard(data, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data, int index) {
    // EN YENİ 3 BİLDİRİM Mİ KONTROLÜ (0, 1 ve 2. index)
    bool isNew = index < 3;

    // Bildirim tipine göre ikon ve renk belirliyoruz
    IconData icon;
    Color iconColor;
    Color bgColor;

    String type = data['type'] ?? 'duyuru';

    if (type == 'aidat') {
      icon = Icons.account_balance_wallet_rounded;
      iconColor = const Color(0xFFF59E0B); // Turuncu
      bgColor = const Color(0xFFFFFBEB);
    } else if (type == 'oylama') {
      icon = Icons.how_to_vote_rounded;
      iconColor = const Color(0xFF8B5CF6); // Mor
      bgColor = const Color(0xFFF5F3FF);
    } else if (type == 'sikayet') { // Şikayet tipi eklendi
      icon = Icons.mark_chat_unread_rounded;
      iconColor = const Color(0xFFEF4444); // Kırmızı
      bgColor = const Color(0xFFFEF2F2);
    } else {
      icon = Icons.campaign_rounded;
      iconColor = const Color(0xFF10B981); // Yeşil
      bgColor = const Color(0xFFECFDF5);
    }

    // Tarihi formatlama (Eğer null ise şu anı göster)
    DateTime date = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now();
    String formattedDate = DateFormat('d MMM HH:mm', 'tr_TR').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF64748B).withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // İLK 3'TEYSE "YENİ" ETİKETİ GÖSTER
                    if (isNew)
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB), // Uygulamanın ana mavisi
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("YENİ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                      ),

                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(data['message'] ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
              ],
            ),
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
          Icon(Icons.notifications_off_rounded, size: 80, color: Colors.blueGrey.shade100),
          const SizedBox(height: 16),
          const Text("Henüz bildirim yok", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          const Text("Yeni duyuru veya aidat eklendiğinde\nburada görebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}