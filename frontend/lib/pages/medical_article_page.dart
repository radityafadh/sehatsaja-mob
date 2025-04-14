import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardnewslong.dart';
import 'package:frontend/widgets/dropdown.dart';

class MedicalArticlePage extends StatefulWidget {
  const MedicalArticlePage({Key? key}) : super(key: key);

  @override
  _MedicalArticlePage createState() => _MedicalArticlePage();
}

final List<String> categories = [
  'Clinical Medicine',
  'Research & Innovation',
  'Public Health & Policy',
];

final List<String> sortby = ['relevance', 'newest', 'oldest'];

class _MedicalArticlePage extends State<MedicalArticlePage> {
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
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: secondaryColor),
                hintText: 'Search Doctor',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: regular,
                  color: secondaryColor,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            CustomDropdown(items: categories),
            SizedBox(height: 16.0),
            CustomDropdown(items: sortby),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.separated(
                itemCount: 3,
                separatorBuilder: (context, index) => SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return CardNewsLong(
                    image: 'assets/news1.png',
                    detail: 'lorem ipsum dolor sit amet perci pesidasius',
                    detailPageRoute: '/detail-news',
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
