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
  final TextEditingController _searchController = TextEditingController();
  List<String> searchSuggestions = [];
  List<String> allDoctorNames = [];
  List<String> allSpecializations = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .get();

    setState(() {
      allDoctorNames =
          querySnapshot.docs
              .map((doc) => doc['name'].toString().toLowerCase())
              .toList();
      allSpecializations =
          querySnapshot.docs
              .map((doc) => doc['specialization'].toString().toLowerCase())
              .toList();
    });
  }

  void _updateSearchSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        searchSuggestions = [];
        showSuggestions = false;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final nameSuggestions =
        allDoctorNames.where((name) => name.contains(lowerQuery)).toSet();
    final specializationSuggestions =
        allSpecializations.where((spec) => spec.contains(lowerQuery)).toSet();

    setState(() {
      searchSuggestions =
          [...nameSuggestions, ...specializationSuggestions]
              .take(5) // Limit to 5 suggestions
              .toList();
      showSuggestions = true;
    });
  }

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
            child: Column(
              children: [
                TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                    _updateSearchSuggestions(value);
                  },
                  onTap: () {
                    setState(() {
                      showSuggestions = true;
                    });
                  },
                  onFieldSubmitted: (value) {
                    setState(() {
                      showSuggestions = false;
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
                if (showSuggestions && searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: searchSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            searchSuggestions[index],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _searchController.text = searchSuggestions[index];
                              searchQuery = searchSuggestions[index];
                              showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
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
                        if (searchQuery.isEmpty) return true;

                        final name =
                            (doc['name'] ?? '').toString().toLowerCase();
                        final specialization =
                            (doc['specialization'] ?? '')
                                .toString()
                                .toLowerCase();

                        // Flexible search - matches any part of name or specialization
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
