import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tarih formatı için gerekli olabilir

class BuildingFinancialPage extends StatefulWidget {
  final String apartmentId;
  final bool isAdmin; // Admin ise ekleme/silme yapabilir

  const BuildingFinancialPage({
    super.key,
    required this.apartmentId,
    required this.isAdmin,
  });

  @override
  State<BuildingFinancialPage> createState() => _BuildingFinancialPageState();
}

class _BuildingFinancialPageState extends State<BuildingFinancialPage> {
  // Varsayılan olarak şu anki ayı gösterir
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null); // Türkçe tarih formatı
  }

  // Ay Değiştirme Fonksiyonu
  void _changeMonth(int months) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ayın başı ve sonunu hesapla (Sorgu için)
    final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final endOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      appBar: AppBar(
        title: const Text("Gider Tablosu", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),

      // Admin ise Ekleme Butonu Göster
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add_rounded,color: Colors.white,),
        label: const Text("Gider Ekle" ,style: TextStyle(color: Colors.white),),
      )
          : null,

      body: Column(
        children: [
          // --- 1. AY SEÇİCİ HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF64748B)),
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Aylık Gider Raporu",
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // --- 2. LİSTE VE TOPLAM ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('apartments')
                  .doc(widget.apartmentId)
                  .collection('expenses')
                  .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
                  .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];

                // Toplam Hesabı
                double totalAmount = 0;
                for (var doc in docs) {
                  totalAmount += (doc['amount'] as num).toDouble();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Bu ay için kayıtlı gider yok.",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // --- TOPLAM KART ---
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF334155)], // Koyu Slate Gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF1E293B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Toplam Gider", style: TextStyle(color: Colors.white70, fontSize: 14)),
                                SizedBox(height: 4),
                                Text("Dönem Harcaması", style: TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                            Text(
                              "${NumberFormat('#,##0.00', 'tr_TR').format(totalAmount)} ₺",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- HARCAMA LİSTESİ ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final date = (data['date'] as Timestamp).toDate();
                          final docId = docs[index].id;

                          return Dismissible(
                            key: Key(docId),
                            direction: widget.isAdmin ? DismissDirection.endToStart : DismissDirection.none,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.shade400,
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await _confirmDelete(context);
                            },
                            onDismissed: (direction) {
                              _deleteExpense(docId);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                children: [
                                  // İkon Kutusu
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 16),
                                  // Bilgiler
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? 'Gider',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd MMMM', 'tr_TR').format(date),
                                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Tutar
                                  Text(
                                    "-${NumberFormat('#,##0', 'tr_TR').format(data['amount'])} ₺",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFFEF4444), // Kırmızı renk (Gider olduğu için)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HARCAMA EKLEME DİYALOG ---
  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye açılınca yukarı kayması için
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Yeni Gider Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Gider Adı (Örn: Elektrik Faturası)",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Tutar (TL)",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixText: "₺",
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                      _addExpense(titleController.text, double.tryParse(amountController.text) ?? 0);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Kaydet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Firestore Ekleme İşlemi
  Future<void> _addExpense(String title, double amount) async {
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(widget.apartmentId)
        .collection('expenses')
        .add({
      'title': title,
      'amount': amount,
      'date': Timestamp.now(), // Şu anki zamanla kaydeder
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore Silme İşlemi
  Future<void> _deleteExpense(String docId) async {
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(widget.apartmentId)
        .collection('expenses')
        .doc(docId)
        .delete();
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Silinsin mi?"),
        content: const Text("Bu gider kaydı kalıcı olarak silinecek."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sil", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}