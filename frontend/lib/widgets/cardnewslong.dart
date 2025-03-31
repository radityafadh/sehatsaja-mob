import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';

class CardNewsLong extends StatelessWidget {
  final String image;
  final String detail;
  final String detailPageRoute;

  const CardNewsLong({
    Key? key,
    required this.image,
    required this.detail,
    required this.detailPageRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = primaryColor;

    return TextButton(
      onPressed: () {
        Get.toNamed(detailPageRoute);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
          side: BorderSide(color: borderColor, width: 2.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 120.0,
        padding: EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                image,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                detail,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: bold,
                  color: blackColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
