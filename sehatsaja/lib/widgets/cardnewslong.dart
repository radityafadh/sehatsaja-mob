import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/User/news_detail_page.dart'; // Sesuaikan path

class CardNewsLong extends StatelessWidget {
  final String id;

  const CardNewsLong({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      // FIX: Change 'articles' to 'news' to match MedicalArticlePage
      future: FirebaseFirestore.instance.collection('news').doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You might want a smaller indicator or shimmer for each card
          return Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2.0,
            ), // Smaller indicator
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // You can add print statements here for debugging
          // print('CardNewsLong: Document with ID $id not found or no data.');
          return const SizedBox(
            height: 0,
          ); // Return an empty SizedBox or a small placeholder
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final String title = data['title'] ?? 'No Title';
        final String detail = data['description'] ?? 'No Description';
        final String base64Image = data['image'] ?? '';

        // Handle case where base64Image might be empty or invalid
        Uint8List imageBytes;
        try {
          // Check if base64Image is not empty and starts with 'data:image' if it's a data URI
          if (base64Image.isNotEmpty) {
            imageBytes = base64Decode(base64Image.split(',').last);
          } else {
            // Provide a transparent or placeholder image if base64Image is empty
            imageBytes = Uint8List(0); // Empty byte array for placeholder
          }
        } catch (e) {
          print('Error decoding base64 image for ID $id: $e');
          imageBytes = Uint8List(0); // Fallback to empty if decoding fails
        }

        return TextButton(
          onPressed: () {
            Get.to(() => NewsDetailPage(newsId: id));
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(color: primaryColor, width: 2.0),
            ),
          ),
          child: Container(
            width: double.infinity,
            height: 120.0,
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      imageBytes.isNotEmpty
                          ? Image.memory(
                            imageBytes,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image for ID $id: $error');
                              return Container(
                                width: 120,
                                height: 100,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                          : Container(
                            // Placeholder if imageBytes is empty
                            width: 120,
                            height: 100,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
                          ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
