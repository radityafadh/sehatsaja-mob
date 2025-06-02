import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/carddoctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PickDoctorPage extends StatefulWidget {
  const PickDoctorPage({Key? key}) : super(key: key);

  @override
  _PickDoctorPageState createState() => _PickDoctorPageState();
}

class _PickDoctorPageState extends State<PickDoctorPage> {
  int _selectedIndexpages = 2;
  String searchQuery = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndexpages = index;
    });
  }

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
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
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
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'doctor')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No doctors found.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: medium,
                          color: blackColor,
                        ),
                      ),
                    );
                  }

                  final doctors =
                      snapshot.data!.docs.where((doc) {
                        final name =
                            (doc['name'] ?? '').toString().toLowerCase();
                        final specialization =
                            (doc['specialization'] ?? '')
                                .toString()
                                .toLowerCase();
                        return name.contains(searchQuery) ||
                            specialization.contains(searchQuery);
                      }).toList();

                  return GridView.builder(
                    itemCount: doctors.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final doc = doctors[index];
                      return Carddoctor(uid: doc.id);
                    },
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
        uid: FirebaseAuth.instance.currentUser!.uid,
      ),
    );
  }
}
