import 'dart:convert'; // Base64 çözmek için şart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/complaint_service.dart';

class ComplaintListPage extends StatelessWidget {
  final String apartmentId;
  final bool isAdmin; // Yönetici mi?
  final _dao = ComplaintDao();

  ComplaintListPage({
    super.key,
    required this.apartmentId,
    this.isAdmin = false
  });

  // Base64 Çözücü
  Uint8List? _decodeBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Açık gri arka plan

      // --- APPBAR ---
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Talepler & Şikayetler",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),

      // --- BODY ---
      body: StreamBuilder<QuerySnapshot>(
        stream: _dao.getComplaints(apartmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_chat_unread_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Henüz talep yok.", style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          // DÜZELTME 1: Liste üzerinde sort yapabilmek için .toList() ile kopyasını aldık
          var docs = snapshot.data!.docs.toList();

          // Tarihe göre sırala (Yeniden eskiye)
          docs.sort((a, b) {
            var t1 = (a.data() as Map)['createdAt'] as Timestamp?;
            var t2 = (b.data() as Map)['createdAt'] as Timestamp?;
            if (t1 == null || t2 == null) return 0;
            return t2.compareTo(t1);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;
              String docId = docs[index].id;

              // Tarih formatlama
              Timestamp? ts = data['createdAt'] as Timestamp?;
              String dateStr = ts != null
                  ? DateFormat('dd MMM, HH:mm', 'tr_TR').format(ts.toDate())
                  : "-";

              // Fotoğraf verisi
              Uint8List? imageBytes = _decodeBase64(data['photoBase64']);

              return _buildComplaintCard(context, data, dateStr, docId, imageBytes);
            },
          );
        },
      ),
    );
  }

  // --- KART TASARIMI ---
  Widget _buildComplaintCard(BuildContext context, Map<String, dynamic> data, String dateStr, String docId, Uint8List? imageBytes) {
    bool isResolved = data['status'] == 'resolved'; // Çözüldü mü?

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: Başlık + Durum
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isResolved ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isResolved ? Icons.check_circle_outline : Icons.pending_actions,
                          size: 20,
                          color: isResolved ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data['title'] ?? "Başlık Yok",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarih
                Text(dateStr, style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // İçerik Metni
            Text(
              data['content'] ?? "",
              style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.5),
            ),

            // Varsa Fotoğraf Göster
            if (imageBytes != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            // Yönetici Butonları (SİL / DURUM DEĞİŞTİR)
            if (isAdmin) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Silme Butonu
                  InkWell(
                    onTap: () => _confirmDelete(context, docId),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text("Sil", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Durum Değiştir Butonu
                  InkWell(
                    onTap: () => _showStatusDialog(context, docId, isResolved),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.edit_note, size: 16, color: Colors.blue),
                          SizedBox(width: 4),
                          Text("Durum", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- SİLME ONAY ---
  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silinsin mi?"),
        content: const Text("Bu talep kalıcı olarak silinecektir."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Vazgeç", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              _dao.deleteComplaint(docId); // ARTIK SADECE ID YETERLİ
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  // --- DURUM GÜNCELLEME PENCERESİ (YÖNETİCİ İÇİN) ---
  void _showStatusDialog(BuildContext context, String docId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Durumu Güncelle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Bekliyor"),
              leading: const Icon(Icons.pending_actions, color: Colors.orange),
              onTap: () {
                // DÜZELTME 2: apartmentId eklendi!
                _dao.updateStatus(docId, 'pending', apartmentId);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("Çözüldü"),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                // DÜZELTME 3: apartmentId eklendi!
                _dao.updateStatus(docId, 'resolved', apartmentId);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}