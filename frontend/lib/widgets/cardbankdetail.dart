import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';

class CardBankDetail extends StatelessWidget {
  final String image; // menentukan nama bank seperti 'bank_mandiri'
  final String virtualAccountNumber;
  final String doctorName;
  final String time;
  final String session;
  final String price;
  final String status;

  CardBankDetail({
    required this.image,
    required this.virtualAccountNumber,
    required this.doctorName,
    required this.time,
    required this.session,
    required this.price,
    required this.status,
  });

  Widget _getBankImage(String image) {
    switch (image) {
      case 'bank_mandiri':
        return Image.asset(
          'assets/bank/bank_mandiri.png',
          width: 50,
          height: 50,
        );
      case 'bank_bri':
        return Image.asset('assets/bank/bank_bri.png', width: 10, height: 50);
      case 'bank_bni':
        return Image.asset('assets/bank/bank_bni.png', width: 10, height: 50);
      case 'bank_bca':
        return Image.asset('assets/bank/bank_bca.png', width: 10, height: 50);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getBankImage(image), // Menampilkan gambar
              SizedBox(width: 10),
              Text(
                'Bank: ${image.split("_").last.toUpperCase()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Nomor Virtual Account :', style: TextStyle(fontSize: 16)),
          Text(
            virtualAccountNumber,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Consultation session with :', style: TextStyle(fontSize: 16)),
          Text(
            doctorName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(time, style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Text(session, style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 10),
          Text('Total Price :', style: TextStyle(fontSize: 16)),
          Text(
            price,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Status :', style: TextStyle(fontSize: 16)),
          Text(
            status,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  status.toLowerCase() == 'success' ? primaryColor : blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
