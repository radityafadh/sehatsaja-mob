import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';

class Cardobat extends StatelessWidget {
  final String image;
  final String name;
  final String shape;
  final String dose;
  final String
  detailPageRoute; // Menambahkan parameter untuk route halaman detail

  const Cardobat({
    Key? key,
    required this.image,
    required this.name,
    required this.shape,
    required this.dose,
    required this.detailPageRoute, // Menambahkan parameter ini
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = primaryColor;

    return TextButton(
      onPressed: () {
        // Menggunakan Get untuk pindah halaman
        Get.toNamed(detailPageRoute);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 150.0,
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: blackColor,
                  ),
                ),
                Text(
                  shape,
                  style: TextStyle(fontSize: 16.0, color: blackColor),
                ),
                Text(dose, style: TextStyle(fontSize: 16.0, color: blackColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
