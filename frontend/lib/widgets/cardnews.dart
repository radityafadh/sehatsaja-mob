import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/User/news_detail_page.dart';

class CardNews extends StatefulWidget {
  final String id;
  final VoidCallback? onTap;

  const CardNews({Key? key, required this.id, this.onTap}) : super(key: key);

  @override
  _CardNewsState createState() => _CardNewsState();
}

class _CardNewsState extends State<CardNews> {
  Map<String, dynamic>? _articleData;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDisposed = false; // Add disposal flag

  @override
  void initState() {
    super.initState();
    _fetchArticleData();
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed
    super.dispose();
  }

  Future<void> _fetchArticleData() async {
    if (_isDisposed) return; // Early return if disposed

    // Safe setState wrapper
    void safeSetState(VoidCallback fn) {
      if (!_isDisposed && mounted) {
        setState(fn);
      }
    }

    safeSetState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('news')
              .doc(widget.id)
              .get();

      if (_isDisposed) return; // Check again after async operation

      if (docSnapshot.exists) {
        safeSetState(() {
          _articleData = docSnapshot.data();
          _isLoading = false;
        });
      } else {
        safeSetState(() {
          _errorMessage = 'Article with ID ${widget.id} not found.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_isDisposed) return;
      safeSetState(() {
        _errorMessage = 'Error fetching article ${widget.id}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    final String base64Image = _articleData!['image'] ?? '';
    final String subtitle = _articleData!['title'] ?? 'No Title';

    Uint8List imageBytes;
    try {
      imageBytes =
          base64Image.isNotEmpty
              ? base64Decode(base64Image.split(',').last)
              : Uint8List(0);
    } catch (e) {
      imageBytes = Uint8List(0);
    }

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            Get.to(() => NewsDetailPage(newsId: widget.id));
          },
      child: Container(
        width: 150,
        height: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              if (imageBytes.isNotEmpty)
                Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
