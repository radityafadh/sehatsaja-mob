import 'dart:convert';
import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:get/get.dart'; // Jika Anda menggunakan GetX untuk navigasi
import 'package:frontend/pages/User/news_detail_page.dart'; // Sesuaikan path ke NewsDetailPage

class CardNews extends StatefulWidget {
  final String id; // Hanya menerima ID

  // onTap tetap ada jika Anda ingin memicu navigasi dari luar,
  // tapi di sini kita akan memicu navigasi ke NewsDetailPage secara internal.
  final VoidCallback? onTap;

  const CardNews({Key? key, required this.id, this.onTap}) : super(key: key);

  @override
  _CardNewsState createState() => _CardNewsState();
}

class _CardNewsState extends State<CardNews> {
  // State untuk menyimpan data artikel yang diambil
  Map<String, dynamic>? _articleData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchArticleData(); // Panggil fungsi untuk mengambil data saat widget diinisialisasi
  }

  Future<void> _fetchArticleData() async {
    setState(() {
      _isLoading = true; // Set loading true saat mulai fetch
      _errorMessage = ''; // Bersihkan pesan error sebelumnya
    });
    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection(
                'news',
              ) // Pastikan nama koleksi ini benar ('news' atau 'articles')
              .doc(widget.id)
              .get();

      if (docSnapshot.exists) {
        setState(() {
          _articleData = docSnapshot.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Article with ID ${widget.id} not found.';
          _isLoading = false;
        });
        print(
          'CardNews: Document with ID ${widget.id} does not exist.',
        ); // Debugging
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching article ${widget.id}: $e';
        _isLoading = false;
      });
      print(
        'CardNews: Error fetching data for ID ${widget.id}: $e',
      ); // Debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Tampilan loading
      return Container(
        width: 150,
        height: 250,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_errorMessage.isNotEmpty || _articleData == null) {
      // Tampilan error atau jika data tidak ditemukan
      print(
        'CardNews: Displaying error/empty for ID ${widget.id}. Error: $_errorMessage',
      ); // Debugging
      return Container(
        width: 150,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Failed to load article.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      );
    }

    // Ekstrak data dari _articleData
    final String base64Image = _articleData!['image'] ?? '';
    final String subtitle =
        _articleData!['title'] ??
        'No Title'; // Menggunakan 'title' sebagai subtitle

    Uint8List imageBytes;
    try {
      if (base64Image.isNotEmpty) {
        // Hanya decode jika string base64 tidak kosong
        imageBytes = base64Decode(base64Image.split(',').last);
      } else {
        imageBytes = Uint8List(0); // Berikan array kosong jika tidak ada gambar
      }
    } catch (e) {
      print('CardNews: Error decoding base64 image for ID ${widget.id}: $e');
      imageBytes = Uint8List(0); // Fallback jika decoding gagal
    }

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            // Navigasi ke NewsDetailPage menggunakan GetX
            Get.to(() => NewsDetailPage(newsId: widget.id));
          },
      child: Container(
        width: 150, // Tetap gunakan lebar yang sudah ada
        height: 250, // Tetap gunakan tinggi yang sudah ada
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Gambar latar belakang
              if (imageBytes.isNotEmpty)
                Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      'CardNews: Error loading image for ID ${widget.id}: $error',
                    );
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              else
                Container(
                  // Placeholder jika tidak ada gambar
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 2, // Batasi jumlah baris untuk subtitle
                      overflow:
                          TextOverflow
                              .ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
