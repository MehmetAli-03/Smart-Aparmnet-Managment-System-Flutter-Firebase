import 'package:flutter/material.dart';

import '../../../data/services/announcement_service.dart';


class AddAnnouncementPage extends StatefulWidget {
  final String apartmentId;
  const AddAnnouncementPage({super.key, required this.apartmentId});

  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dao = AnnouncementDao();

  bool _isLoading = false; // Yükleniyor durumu kontrolü

  void _addAnnouncement() async {
    // Basit doğrulama: Alanlar boşsa işlem yapma
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Lütfen başlık ve açıklama giriniz."),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Yükleniyor başlat

    try {
      await _dao.addAnnouncement(
        apartmentId: widget.apartmentId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Sayfayı kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Duyuru başarıyla yayınlandı!"),
            backgroundColor: Color(0xFF10B981), // Yeşil
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e")),
        );
        setState(() => _isLoading = false); // Hata varsa yükleniyor'u durdur
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Uygulama genel arkaplanı
      appBar: AppBar(
        title: const Text(
          "Yeni Duyuru",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Duyuru Detayları",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 1.0
                ),
              ),
              const SizedBox(height: 20),

              // --- BAŞLIK ALANI ---
              _buildModernTextField(
                controller: _titleController,
                label: "Duyuru Başlığı",
                hint: "Örn: Asansör Bakımı Hakkında",
                icon: Icons.campaign_rounded,
              ),

              const SizedBox(height: 20),

              // --- İÇERİK ALANI ---
              _buildModernTextField(
                controller: _contentController,
                label: "Açıklama",
                hint: "Duyuru detaylarını buraya yazınız...",
                icon: Icons.description_rounded,
                maxLines: 6,
              ),

              const SizedBox(height: 40),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded),
                      SizedBox(width: 12),
                      Text(
                        "DUYURUYU YAYINLA",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tekrar eden input tasarımı için yardımcı widget
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: true, // Çok satırlı ise label yukarıda kalsın
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12, top: 2),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50), // İkon hizalaması
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none, // Varsayılan border yok (Container gölgesi var)
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }
}