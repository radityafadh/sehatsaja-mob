import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/widgets/cardnewslong.dart';
import 'package:sehatsaja/widgets/dropdown.dart';

class MedicalArticlePage extends StatefulWidget {
  const MedicalArticlePage({Key? key}) : super(key: key);

  @override
  _MedicalArticlePage createState() => _MedicalArticlePage();
}

final List<String> categories = [
  'Medication',
  'Nursing',
  'Emergency',
  'Training',
  'Education',
  'Patient Care',
  'Hygiene',
  'Technology',
  'Innovation',
  'Mental Health',
  'Support',
  'Rural',
  'Access',
  'Diversity',
  'Ethics',
  'Chronic Illness',
  'Long-term Care',
  'Telehealth',
  'Future',
  'Nutrition',
  'Decision Making',
];

class _MedicalArticlePage extends State<MedicalArticlePage> {
  String selectedCategory = categories.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Article',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: blackColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: lightGreyColor,
      ),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                hintText: 'Search Article',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: regular,
                  color: secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            CustomDropdown(
              items: categories,
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('news')
                        .where('labels', arrayContains: selectedCategory)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No articles found.'));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final docId = docs[index].id;

                      return CardNewsLong(
                        id: docId, // Teruskan ID dokumen ke CardNewsLong
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
