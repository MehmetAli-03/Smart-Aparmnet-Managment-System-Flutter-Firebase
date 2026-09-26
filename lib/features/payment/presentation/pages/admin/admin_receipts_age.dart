import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'PdfViewerPage.dart';

class AdminReceiptsPage extends StatefulWidget {
  final String apartmentId;

  const AdminReceiptsPage({super.key, required this.apartmentId});

  @override
  State<AdminReceiptsPage> createState() => _AdminReceiptsPageState();
}

class _AdminReceiptsPageState extends State<AdminReceiptsPage> {
  DateTime _selectedDate = DateTime.now();

  // Ay değiştirme
  void _changeMonth(int months) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + months);
    });
  }

  // Base64 temizleme
  Uint8List? _decodeBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      return base64Decode(base64String!);
    } catch (e) {
      debugPrint("Base64 Hatası: $e");
      return null;
    }
  }

  // Durum Güncelleme
  Future<void> _updateStatus(String docId, bool isApproved) async {
    await FirebaseFirestore.instance.collection('payments').doc(docId).update({
      'status': isApproved ? 'approved' : 'rejected',
      'isApproved': isApproved,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApproved ? "Ödeme Onaylandı ✅" : "Ödeme Reddedildi ❌"),
          backgroundColor: isApproved ? Colors.green : Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    String monthName = DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Gelen Dekontlar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // --- TARİH SEÇİCİ ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => _changeMonth(-1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    monthName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- LİSTE ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('payments')
                  .where('apartmentId', isEqualTo: widget.apartmentId)
                  .where('date', isGreaterThanOrEqualTo: startOfMonth)
                  .where('date', isLessThanOrEqualTo: endOfMonth)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text("Bu ay yüklenen dekont yok.", style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id;

                    // Durum Rengi
                    String status = data['status'] ?? 'pending';
                    Color statusColor = Colors.orange;
                    String statusText = "Bekliyor";

                    if (status == 'approved') {
                      statusColor = Colors.green;
                      statusText = "Onaylandı";
                    } else if (status == 'rejected') {
                      statusColor = Colors.red;
                      statusText = "Reddedildi";
                    }

                    // Tarih
                    Timestamp? ts = data['uploadedAt'] as Timestamp?;
                    String dateStr = ts != null
                        ? DateFormat('dd MMM HH:mm', 'tr_TR').format(ts.toDate())
                        : "-";

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _showReceiptDetail(context, data, docId),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // İkon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  data['fileType'] == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Orta Alan: İsim ve Bilgiler
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔥 DÜZELTİLEN KISIM BAŞLANGIÇ 🔥
                                    _buildUserInfo(data),
                                    // 🔥 DÜZELTİLEN KISIM BİTİŞ 🔥

                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['fileName'] ?? "Dosya",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),

                              // Durum Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withOpacity(0.5)),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 KULLANICI ADI VE DAİRE NO GÖSTERME (DÜZELTİLMİŞ) 🔥
  Widget _buildUserInfo(Map<String, dynamic> data) {

    // --- Yardımcı: Daire No Temizleme ---
    // Eğer daire no yoksa, boşsa veya 5 karakterden uzunsa (ID ise) '?' döndürür.
    String cleanFlatNo(dynamic flat) {
      String s = flat?.toString() ?? '';
      if (s.isEmpty) return '?';
      if (s.length > 5) return '?'; // Uzun ID'leri engeller
      return s;
    }

    // 1. ADIM: Dekontun içine kaydedilmiş mi? (En Hızlı Yöntem)
    if (data.containsKey('userName') && data['userName'] != null) {
      String name = data['userName'];
      String flat = cleanFlatNo(data['flatNo']);

      return Text(
        flat != '?' ? "Daire: $flat - $name" : "👤 $name",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      );
    }

    // 2. ADIM: Veritabanından Kullanıcıyı Bul (Eski Kayıtlar İçin)
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(data['userId']).get(),
      builder: (context, userSnapshot) {

        // Yüklenirken...
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 15, width: 120,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
          );
        }

        // Kullanıcı Bulundu
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          // İsim
          String name = userData['name'] ?? userData['fullName'] ?? 'İsimsiz Üye';

          // Daire No (flatNo yoksa apartmentNo'ya bak, o da yoksa ?)
          String flat = cleanFlatNo(userData['flatNo'] ?? userData['apartmentNo']);

          return Text(
            flat != '?' ? "Daire: $flat - $name" : "👤 $name",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          );
        }

        // Kullanıcı Silinmişse
        return const Text(
          "Kullanıcı Bulunamadı",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
        );
      },
    );
  }

  // --- DETAY POPUP ---
  void _showReceiptDetail(BuildContext context, Map<String, dynamic> data, String docId) {
    Uint8List? imageBytes;
    bool isPdf = data['fileType'] == 'pdf';

    if (!isPdf && data['receiptData'] != null) {
      imageBytes = _decodeBase64(data['receiptData']);
    }

    // İsim bilgisini popup'ta da göstermek için hazırla
    String displayName = "Yükleyen Bilgisi Alınıyor...";
    if (data.containsKey('userName')) {
      displayName = "Daire: ${data['flatNo'] ?? '?'} - ${data['userName']}";
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dekont İnceleme", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              // İsim Bilgisi Popup Başlığının Altında
              if (data.containsKey('userName'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                ),

              const Divider(height: 1),

              // GÖRÜNTÜLEME
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey.shade100,
                child: isPdf
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                    const SizedBox(height: 10),
                    const Text("PDF Dosyası", style: TextStyle(fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Text(
                        data['fileName'] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(
                              base64String: data['receiptData'],
                              fileName: data['fileName'] ?? "dekont.pdf",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("PDF'i Görüntüle"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                    )
                  ],
                )
                    : (imageBytes != null
                    ? InteractiveViewer(
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                )
                    : const Center(child: Text("Görüntü yüklenemedi"))),
              ),

              const Divider(height: 1),

              // BUTONLAR
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(docId, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("REDDET"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus(docId, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("ONAYLA",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}