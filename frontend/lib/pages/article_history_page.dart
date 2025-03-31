import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/cardnewslong.dart';

class ArticleHistoryPage extends StatefulWidget {
  const ArticleHistoryPage({Key? key}) : super(key: key);

  @override
  _ArticleHistoryPageState createState() => _ArticleHistoryPageState();
}

class _ArticleHistoryPageState extends State<ArticleHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Article History',
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
    );
  }
}
