import 'package:flutter/material.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:sehatsaja/pages/User/medicine_detail_page.dart'; // ✅ make sure path is correct

class Cardobat extends StatelessWidget {
  final Map<String, dynamic> medicineData;

  const Cardobat({Key? key, required this.medicineData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = primaryColor;

    final String name = medicineData['name'] ?? 'Unknown';
    final String shapePath = medicineData['shape'] ?? '';
    final String description = medicineData['description'] ?? 'No description';
    final int colorValue = medicineData['color'] ?? Colors.grey.value;
    final Color shapeColor = Color(colorValue);

    // Ambil jadwal (dose) dan ubah jadi string seperti "08:00, 14:00"
    final List<dynamic> scheduleList = medicineData['schedule'] ?? [];
    final String doseTimes = scheduleList
        .map((time) {
          final hour = time['hour']?.toString().padLeft(2, '0') ?? '00';
          final minute = time['minute']?.toString().padLeft(2, '0') ?? '00';
          return '$hour:$minute';
        })
        .join(', ');

    return TextButton(
      onPressed: () {
        final String? uid = medicineData['uid'];
        final String? id = medicineData['id'];
        print('👉 Klik card');
        print('UID: $uid');
        print('ID: $id');

        if (uid != null && id != null) {
          print('✅ Navigating to detail page');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailPage(uid: uid, docId: id),
            ),
          );
        } else {
          print('❌ Invalid medicine data: $medicineData');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid medicine data: Missing UID or ID')),
          );
        }
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
        height: 180.0,
        padding: EdgeInsets.all(5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20.0),
            Container(
              width: 100,
              height: 100,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: shapeColor.withOpacity(0.0),
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(shapeColor, BlendMode.modulate),
                child: Image.asset(
                  shapePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
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
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14.0, color: blackColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dose: $doseTimes',
                    style: TextStyle(fontSize: 14.0, color: blackColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
