import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/containerdetail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DetailDoctorPage extends StatelessWidget {
  const DetailDoctorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(title: Text(''), backgroundColor: lightGreyColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/doctor.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Mulyadi Akbar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: bold,
                          color: blackColor,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: primaryColor, size: 16.0),
                          Text(
                            '4.9 (129 reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: regular,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Dentist',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Transform.scale(
                    scale: 0.8, // Reduce size to 80% of original
                    child: ContainerDetail(
                      icon: PhosphorIconsBold.person,
                      name: '152+',
                      detail: 'Patients',
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: ContainerDetail(
                      icon: PhosphorIconsBold.medal,
                      name: '3 Yr+',
                      detail: 'Experience',
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: ContainerDetail(
                      icon: PhosphorIconsBold.star,
                      name: '4.9',
                      detail: 'Rating',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
