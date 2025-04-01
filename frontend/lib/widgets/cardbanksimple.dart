import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';

class CardBankSimple extends StatelessWidget {
  final String image;
  final String type;

  CardBankSimple({required this.image, required this.type});

  Widget _getBankImage(String image) {
    switch (image) {
      case 'bank_mandiri':
        return Image.asset(
          'assets/bank/bank_mandiri.png',
          width: 100,
          height: 50,
        );
      case 'bank_bri':
        return Image.asset('assets/bank/bank_bri.png', width: 100, height: 50);
      case 'bank_bni':
        return Image.asset('assets/bank/bank_bni.png', width: 100, height: 50);
      case 'bank_bca':
        return Image.asset('assets/bank/bank_bca.png', width: 100, height: 50);
      default:
        return Icon(Icons.error, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor, width: 3.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _getBankImage(image),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Bank: ${image.split("_").last.toUpperCase()}',
                style: TextStyle(fontSize: 16, fontWeight: bold),
              ),
              Text(type, style: TextStyle(fontSize: 12, fontWeight: regular)),
            ],
          ),
        ],
      ),
    );
  }
}
