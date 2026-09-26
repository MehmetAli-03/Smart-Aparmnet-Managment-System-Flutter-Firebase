import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class UploadReceiptPage extends StatefulWidget {
  final String apartmentId;
  final String userId;

  const UploadReceiptPage({
    super.key,
    required this.apartmentId,
    required this.userId,
  });

  @override
  State<UploadReceiptPage> createState() => _UploadReceiptPageState();
}

class _UploadReceiptPageState extends State<UploadReceiptPage> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;
  bool _isLoadingUserData = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatNoController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          String existingName = data['name'] ?? data['fullName'] ?? "";
          _nameController.text = existingName;

          String rawFlat = data['flatNo']?.toString() ?? data['apartmentNo']?.toString() ?? "";
          if (rawFlat.length < 5 && rawFlat != widget.apartmentId) {
            _flatNoController.text = rawFlat;
          }
        }
      }
    } catch (e) {
      debugPrint("Kullanıcı verisi çekilemedi: $e");
    } finally {
      if (mounted) setState(() => _isLoadingUserData = false);
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);
    if (photo != null) _checkFileSize(File(photo.path));
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      _checkFileSize(File(result.files.single.path!));
    }
  }

  void _checkFileSize(File file) {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (sizeInMb > 1.0) {
      _showErrorSnackBar("Dosya boyutu 1 MB'dan büyük olamaz!");
    } else {
      setState(() {
        _selectedFile = file;
        _fileName = path.basename(file.path);
      });
    }
  }

  Future<void> _uploadAndSave() async {
    if (_selectedFile == null) {
      _showErrorSnackBar("Lütfen bir dosya seçin.");
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar("Lütfen Ad Soyad giriniz.");
      return;
    }
    if (_flatNoController.text.trim().isEmpty) {
      _showErrorSnackBar("Lütfen Daire Numaranızı giriniz.");
      return;
    }

    setState(() => _isUploading = true);

    try {
      String extension = path.extension(_selectedFile!.path);
      List<int> fileBytes = await _selectedFile!.readAsBytes();
      String base64File = base64Encode(fileBytes);

      String header = extension == '.pdf'
          ? 'data:application/pdf;base64,'
          : 'data:image/jpeg;base64,';

      String finalBase64String = header + base64File;
      final docId = "${widget.apartmentId}_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}";

      await FirebaseFirestore.instance.collection('payments').doc(docId).set({
        'apartmentId': widget.apartmentId,
        'userId': widget.userId,
        'userName': _nameController.text.trim(),
        'flatNo': _flatNoController.text.trim(),
        'status': 'pending_approval',
        'receiptData': finalBase64String,
        'fileName': _fileName,
        'fileType': extension.replaceAll('.', ''),
        'date': FieldValue.serverTimestamp(),
        'isApproved': false,
        'uploadedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': _nameController.text.trim(),
        'flatNo': _flatNoController.text.trim(),
      }).onError((e, _) => debugPrint("Profil güncellenemedi: $e"));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dekont başarıyla gönderildi ✅"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar("Bir hata oluştu: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPdf = _fileName != null && _fileName!.toLowerCase().endsWith('.pdf');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Çok açık gri arka plan
      appBar: AppBar(
        title: const Text("Dekont Yükle", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingUserData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BİLGİ KARTI ---
            const Text("Ödeme Bilgileri", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildModernTextField(
                    controller: _nameController,
                    label: "Ad Soyad",
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _flatNoController,
                    label: "Daire Numaranız",
                    hint: "Örn: 5",
                    icon: Icons.home_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Dekont Görseli", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            // --- DOSYA YÜKLEME ALANI (Görselleştirilmiş) ---
            InkWell(
              onTap: _isUploading ? null : (_selectedFile == null ? _pickFile : null),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: _selectedFile != null ? Colors.white : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedFile != null ? Colors.transparent : const Color(0xFFBFDBFE),
                    width: 2,
                    style: _selectedFile != null ? BorderStyle.solid : BorderStyle.none, // Dashed efekt yerine düz renk daha modern
                  ),
                  boxShadow: _selectedFile != null
                      ? [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))]
                      : [],
                ),
                child: _selectedFile != null
                    ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: isPdf
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded, size: 64, color: Color(0xFFEF4444)),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(_fileName!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        )
                            : Image.file(_selectedFile!, fit: BoxFit.cover),
                      ),
                    ),
                    // Silme Butonu
                    Positioned(
                      top: 12, right: 12,
                      child: InkWell(
                        onTap: () => setState(() { _selectedFile = null; _fileName = null; }),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)]
                      ),
                      child: const Icon(Icons.cloud_upload_rounded, size: 40, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(height: 16),
                    const Text("Dosya Seçmek İçin Dokunun", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text("PDF, JPG veya PNG (Max 1MB)", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- AKSİYON BUTONLARI ---
            Row(
              children: [
                // Kamera Butonu
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: "Kamera",
                    color: const Color(0xFF10B981),
                    onTap: _isUploading ? null : _pickFromCamera,
                  ),
                ),
                const SizedBox(width: 16),
                // Galeri Butonu
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.photo_library_rounded,
                    label: "Galeri",
                    color: const Color(0xFF6366F1),
                    onTap: _isUploading ? null : _pickFile,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- GÖNDER BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedFile == null || _isUploading) ? null : _uploadAndSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isUploading
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text("Gönderiliyor...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                )
                    : const Text("DEKONTU GÖNDER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Modern TextField Widget'ı
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  // Modern Aksiyon Butonu Widget'ı
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}