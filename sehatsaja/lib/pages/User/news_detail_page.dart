import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class NewsDetailPage extends StatelessWidget {
  final String newsId;

  const NewsDetailPage({Key? key, required this.newsId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(title: const Text('News Detail')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('news').doc(newsId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Article not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String title = data['title'] ?? '';
          final String author = data['author'] ?? '';

          // FIX: Handle Timestamp conversion for date
          String formattedDate = 'Unknown Date';
          if (data['date'] is Timestamp) {
            final Timestamp timestamp = data['date'];
            final DateTime dateTime = timestamp.toDate();
            // Format the date as desired, e.g., "MMM dd, yyyy" or "dd MMMM yyyy"
            formattedDate = DateFormat('dd MMMM yyyy').format(dateTime);
          } else if (data['date'] is String) {
            // If it's already a string (e.g., manually entered), use it directly
            formattedDate = data['date'];
          }

          final String base64Image = data['image'] ?? '';
          final List<String> content = List<String>.from(data['content'] ?? []);
          final List<String> labels = List<String>.from(data['labels'] ?? []);

          // Handle case where base64Image might be empty or invalid
          Uint8List imageBytes;
          try {
            if (base64Image.isNotEmpty) {
              imageBytes = base64Decode(base64Image.split(',').last);
            } else {
              imageBytes = Uint8List(0); // Empty byte array for placeholder
            }
          } catch (e) {
            print('Error decoding base64 image: $e');
            imageBytes = Uint8List(0); // Fallback to empty if decoding fails
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display image or a placeholder if imageBytes is empty
                imageBytes.isNotEmpty
                    ? Image.memory(imageBytes, fit: BoxFit.cover)
                    : Container(
                      height: 200, // Adjust height as needed
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('By $author • $formattedDate'), // Use the formatted date
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Tambahkan ini
                  children: [
                    Wrap(
                      spacing: 8,
                      children:
                          labels
                              .map((label) => Chip(label: Text(label)))
                              .toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...content.map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(paragraph),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
