import 'package:build_managment/features/payment/presentation/pages/resident/upload_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/payment_model.dart';
import '../../../../home/data/services/apartment_service.dart';
import '../../../data/services/payment_service.dart';
import '../../../../home/presentation/admin/BuildingFinancialPage.dart';
import '../admin/iban_edit.dart';
// Gider Tablosu Sayfasını İmport Ediyoruz


class IbanPage extends StatelessWidget {
  final String apartmentId;
  final String userId;
  final bool isAdmin;
  final bool showAppBar;

  IbanPage({
    super.key,
    required this.apartmentId,
    required this.userId,
    required this.isAdmin,
    this.showAppBar = true,
  });

  final apartmentDao = ApartmentDao();
  final paymentDao = PaymentDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Arka plan şeffaf bırakıldı (Tab yapısına uygun)
      body: FutureBuilder(
        future: apartmentDao.getApartment(apartmentId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          final data = snap.data?.data() as Map<String, dynamic>? ?? {};

          // Verileri çekiyoruz
          final iban = data["iban"] ?? "IBAN Tanımlanmamış";
          final apartmentName = data["name"] ?? "Apartman Yönetimi";

          // Yeni eklenen Aidat Bilgileri
          final String duesAmount = data["duesAmount"]?.toString() ?? "Belirlenmedi";
          final int dueDay = int.tryParse(data["dueDay"]?.toString() ?? "15") ?? 15;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔥 YENİ EKLENEN: GİDER TABLOSUNA GİT BUTONU 🔥
                _buildNavigationCard(
                  context: context,
                  title: "Gider Tablosu & Raporlar",
                  subtitle: "Apartman harcamalarını ve faturaları inceleyin.",
                  icon: Icons.analytics_rounded,
                  color: const Color(0xFFF59E0B), // Turuncu tonu (Finans rengi)
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuildingFinancialPage(
                          apartmentId: apartmentId,
                          isAdmin: false, // Sakinler sadece görüntüleyebilir
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 1. AİDAT DURUM KARTI
                _buildDuesStatusCard(duesAmount, dueDay),

                const SizedBox(height: 24),

                // 2. IBAN KARTI
                _buildModernIbanCard(apartmentName, iban, context),

                const SizedBox(height: 32),

                // 3. BİLGİ KUTUCUKLARI
                _buildModernInfoTile(
                  icon: Icons.copy_all_rounded,
                  title: "Kopyala ve Gönder",
                  subtitle: "IBAN'ı kopyalayıp, açıklama kısmına daire numaranızı yazarak transfer yapın.",
                ),
                const SizedBox(height: 16),
                _buildModernInfoTile(
                  icon: Icons.notification_important_rounded,
                  title: "Dekont Saklayın",
                  subtitle: "Olası karışıklıklar için ödeme dekontunu saklamanız önerilir.",
                ),

                const SizedBox(height: 40),

                // 4. AKSİYON BUTONLARI
                if (!isAdmin) _buildPaymentAction(context),
                if (isAdmin) _buildAdminAction(context),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 🔥 YENİ NAVIGATION KART TASARIMI 🔥 ---
  Widget _buildNavigationCard({
    required BuildContext context,
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

  // --- AİDAT DURUM KARTI ---
  Widget _buildDuesStatusCard(String amount, int day) {
    // Tarih Hesaplama
    final now = DateTime.now();
    // Eğer bugünün günü, son ödeme gününü geçtiyse gelecek aya atabiliriz veya aynı ay kalabilir.
    // Şimdilik basitçe bu ayın o günü olarak alıyoruz.
    final dueDate = DateTime(now.year, now.month, day);
    final formattedDate = DateFormat("d MMMM", "tr_TR").format(dueDate);

    // Tutar Formatlama
    String displayAmount = amount;
    if (double.tryParse(amount) != null) {
      displayAmount = "$amount ₺";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Sol: Tutar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 18, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text("BU AYIN AİDATI", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  displayAmount,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),

          // Dikey Çizgi
          Container(height: 40, width: 1, color: Colors.grey.shade200),

          // Sağ: Tarih
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text("SON ÖDEME", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2), // Kırmızımsı arka plan
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626), // Kırmızı metin
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN IBAN KARTI ---
  Widget _buildModernIbanCard(String name, String iban, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("RESMİ IBAN ADRESİ", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2)),
                      Icon(Icons.account_balance_rounded, color: Colors.white.withOpacity(0.8), size: 24),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    iban,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ALICI", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: iban));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("IBAN Kopyalandı ✅"),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1)
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text("Kopyala", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BİLGİ KUTUSU ---
  Widget _buildModernInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ÖDEME BUTONU ---
  Widget _buildPaymentAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: ()  {
          Navigator.push(context, MaterialPageRoute(builder: (builder)=>UploadReceiptPage(apartmentId: apartmentId, userId: userId)));


        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: const Text("ÖDEMEYİ YAPTIM, BİLDİR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  // --- ADMİN DÜZENLEME BUTONU ---
  Widget _buildAdminAction(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IbanEditPage(apartmentId: apartmentId))),
      icon: const Icon(Icons.edit_rounded),
      label: const Text("BİLGİLERİ GÜNCELLE"),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFF2563EB), width: 2),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}