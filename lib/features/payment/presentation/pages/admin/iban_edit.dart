import 'package:build_managment/features/payment/presentation/pages/admin/admin_receipts_age.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../home/data/services/apartment_service.dart';
import '../../../../home/presentation/admin/BuildingFinancialPage.dart';

class IbanEditPage extends StatefulWidget {
  final String apartmentId;

  const IbanEditPage({super.key, required this.apartmentId});

  @override
  State<IbanEditPage> createState() => _IbanEditPageState();
}

class _IbanEditPageState extends State<IbanEditPage> {
  final _nameController = TextEditingController();
  final _ibanController = TextEditingController();
  final _amountController = TextEditingController();

  int _selectedDay = 15;
  bool _isLoading = true;

  final _dao = ApartmentDao();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await _dao.getApartment(widget.apartmentId);
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _ibanController.text = data['iban'] ?? '';
          _amountController.text = data['duesAmount']?.toString() ?? '';
          _selectedDay = int.tryParse(data['dueDay']?.toString() ?? "15") ?? 15;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("YÖNETİM PANELİ", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 YENİ EKLENEN KISIM: GİDER TABLOSU BUTONU 🔥
            _buildNavigationCard(
              title: "Gider Tablosu & Raporlar",
              subtitle: "Aylık bina harcamalarını yönetin ve düzenleyin.",
              icon: Icons.analytics_rounded,
              color: const Color(0xFFF59E0B), // Amber/Turuncu renk dikkat çeker
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuildingFinancialPage(
                      apartmentId: widget.apartmentId,
                      isAdmin: true, // Bu sayfada olan kişi zaten admindir
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildNavigationCard(
              title: "Ödenen Aidatlar & Dekontlar",
              subtitle: "Aylık ödenen aidatların dekontları .",
              icon: Icons.analytics_rounded,
              color: const Color(0xFFFF0000), // Amber/Turuncu renk dikkat çeker
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminReceiptsPage(
                      apartmentId: widget.apartmentId,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // --- BÖLÜM 1: BANKA BİLGİLERİ ---
            _buildSectionHeader("Banka Hesap Bilgileri", Icons.account_balance_wallet_rounded),
            const SizedBox(height: 20),
            _buildModernInput(controller: _nameController, label: "Alıcı Adı / Yönetici Adı", icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildModernInput(controller: _ibanController, label: "IBAN Adresi", icon: Icons.numbers_rounded, isIban: true),

            const SizedBox(height: 32),

            // --- BÖLÜM 2: AİDAT AYARLARI ---
            _buildSectionHeader("Aidat Yapılandırması", Icons.currency_lira_rounded),
            const SizedBox(height: 20),

            Row(
              children: [
                // Aidat Tutarı
                Expanded(
                  flex: 2,
                  child: _buildModernInput(
                      controller: _amountController,
                      label: "Aylık Tutar (TL)",
                      icon: Icons.money,
                      isNumber: true
                  ),
                ),
                const SizedBox(width: 14),
                // Ödeme Günü (Dropdown)
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 60, // Input ile aynı hizada olması için yükseklik ayarı
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Text("Son Gün", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        DropdownButton<int>(
                          value: _selectedDay,
                          isExpanded: true,
                          isDense: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                          items: List.generate(31, (index) => index + 1).map((day) {
                            return DropdownMenuItem(
                              value: day,
                              child: Text("Ayın $day'i"),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedDay = val!),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "* Sakinler bu tutarı ve tarihi ana sayfada görecektir.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 50),

            // KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI YARDIMCILARI ---

  // 🔥 YENİ NAVIGATION KART TASARIMI 🔥
  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF334155))),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 2)),
      ],
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isIban = false,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: isIban ? TextCapitalization.characters : TextCapitalization.words,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty || _ibanController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurunuz")),
      );
      return;
    }

    try {
      // 1. Apartman bilgilerini güncelliyoruz
      await FirebaseFirestore.instance.collection('apartments').doc(widget.apartmentId).update({
        'name': _nameController.text.trim(),
        'iban': _ibanController.text.trim(),
        'duesAmount': _amountController.text.trim(),
        'dueDay': _selectedDay,
      });

      // 2. 🔥 HEMEN ARDINDAN BİLDİRİM FIRLATIYORUZ 🔥
      // Bildirim tipi 'aidat' olduğu için UI tarafında otomatik turuncu cüzdan ikonuyla çıkacak.
      await FirebaseFirestore.instance
          .collection('apartments')
          .doc(widget.apartmentId)
          .collection('notifications')
          .add({
        'title': 'Aidat Bilgileri Güncellendi',
        'message': 'Yeni aidat tutarı ${_amountController.text.trim()} TL ve son ödeme tarihi ayın $_selectedDay\'i olarak belirlenmiştir.',
        'type': 'aidat',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bilgiler başarıyla güncellendi ✅"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Sayfayı kapat
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }
}