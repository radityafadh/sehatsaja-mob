import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/carddoctor.dart';

class PickDoctorPage extends StatefulWidget {
  const PickDoctorPage({Key? key}) : super(key: key);

  @override
  _PickDoctorPageState createState() => _PickDoctorPageState();
}

class _PickDoctorPageState extends State<PickDoctorPage> {
  int _selectedIndexpages = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexpages = index;
    });
  }

  final List<Map<String, String>> doctors = [
    {'name': 'Dr. A', 'role': 'Cardiologist', 'image': 'assets/doctor.png'},
    {'name': 'Dr. B', 'role': 'Dermatologist', 'image': 'assets/doctor.png'},
    {'name': 'Dr. C', 'role': 'Pediatrician', 'image': 'assets/doctor.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor List',
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: 20.0,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return Carddoctor(
                    name: doctors[index]['name']!,
                    role: doctors[index]['role']!,
                    image: doctors[index]['image']!,
                    detailPageRoute: '/detail-transaction',
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: _onItemTapped,
        currentIndex: _selectedIndexpages,
      ),
    );
  }
}
