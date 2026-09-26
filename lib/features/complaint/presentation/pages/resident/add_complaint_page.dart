import 'dart:convert'; // Base64 için şart
import 'dart:io'; // Dosya işlemleri için şart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/services/complaint_service.dart'; // pubspec.yaml'da olmalı


class AddComplaintPage extends StatefulWidget {
  final String apartmentId;
  const AddComplaintPage({super.key, required this.apartmentId});

  @override
  State<AddComplaintPage> createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _dao = ComplaintDao(); // DAO dosyanı güncellemen gerekecek (aşağıda anlattım)

  bool _isLoading = false;
  File? _selectedImage; // Seçilen resim dosyası

  // Resim Seçme Fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    // imageQuality: 30 yaptık ki Firestore 1MB limitine takılmasın
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 30);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Resim Seçim Menüsü (Alttan açılan)
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addComplaint() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen konu ve açıklama giriniz."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? base64Image;

      // Eğer resim seçildiyse Base64'e çevir
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // DAO'ya gönder (DAO fonksiyonunu güncellemen lazım, parametre olarak photoBase64 almalı)
      await _dao.addComplaint(
        apartmentId: widget.apartmentId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        photoBase64: base64Image, // Yeni parametre
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Talebiniz başarıyla oluşturuldu ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Yeni Talep",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST İKON
              Center(
                child: Container(
                  height: 80, width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFEE2E2), width: 8),
                  ),
                  child: const Icon(Icons.campaign_outlined, size: 32, color: Color(0xFFEF4444)), // Kırmızı ton
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Yönetime Bildir",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),

              const SizedBox(height: 32),

              // KONU
              const Text("Konu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              _buildProTextField(
                controller: _titleController,
                hint: "Örn: Asansör sesi",
                icon: Icons.title_rounded,
              ),

              const SizedBox(height: 20),

              // AÇIKLAMA
              const Text("Açıklama", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              _buildProTextField(
                controller: _contentController,
                hint: "Durumu kısaca özetleyiniz...",
                icon: Icons.notes_rounded,
                isMultiline: true,
              ),

              const SizedBox(height: 20),

              // FOTOĞRAF ALANI
              const Text("Fotoğraf (İsteğe Bağlı)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),

              if (_selectedImage == null)
                InkWell(
                  onTap: _showImageSourceActionSheet, // Tıklayınca menü aç
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        image: const DecorationImage(
                            image: AssetImage("assets/pattern_bg.png"), // Varsa desen yoksa renk kalır
                            opacity: 0.1, fit: BoxFit.cover
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo_rounded, color: Color(0xFF64748B)),
                        SizedBox(width: 10),
                        Text("Fotoğraf Ekle", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              else
              // FOTOĞRAF SEÇİLDİYSE GÖSTER
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _selectedImage = null), // Silme işlemi
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    )
                  ],
                ),

              const SizedBox(height: 40),

              // GÖNDER BUTONU
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Mavi
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Talebi Gönder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        minLines: isMultiline ? 3 : 1,
        maxLines: isMultiline ? 8 : 1,
        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14, right: 10, top: isMultiline ? 12 : 0, bottom: isMultiline ? 12 : 0),
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              vertical: isMultiline ? 16 : 18,
              horizontal: 16
          ),
        ),
      ),
    );
  }
}