import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String base64String;
  final String fileName;

  const PdfViewerPage({super.key, required this.base64String, required this.fileName});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localFilePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    createFileFromBase64();
  }

  Future<void> createFileFromBase64() async {
    try {
      // 1. Base64 temizliği (virgülden sonrasını al)
      String cleanBase64 = widget.base64String;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }

      // 2. Byte'a çevir
      Uint8List bytes = base64Decode(cleanBase64);

      // 3. Geçici klasörü bul
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/${widget.fileName}");

      // 4. Dosyayı yaz
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          localFilePath = file.path;
          isLoading = false;
        });
      }
    } catch (e) {
      print("PDF Oluşturma Hatası: $e");
      if(mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(color: Colors.black, fontSize: 14)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localFilePath == null
          ? const Center(child: Text("PDF yüklenemedi."))
          : PDFView(
        filePath: localFilePath!,
        enableSwipe: true,
        swipeHorizontal: false, // Dikey kaydırma
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          print(error.toString());
        },
      ),
    );
  }
}