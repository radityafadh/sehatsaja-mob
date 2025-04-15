import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/containerdetail.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/widgets/experiencecard.dart';

class DetailDoctorControllerDoctor extends GetxController {
  final RxString _currentState = 'Schedule'.obs;
  final RxInt _selectedIndex = 0.obs;
  final RxString selectedPeriod = 'Morning'.obs;
  final RxString selectedTime = ''.obs;

  final RxBool isEditingAbout = false.obs;
  final RxBool isEditingExperience = false.obs;

  final RxString aboutText =
      'Dr. Mulyadi Akbar is a dedicated and experienced dentist committed to providing top-quality dental care...'
          .obs;

  final RxList<Map<String, String>> experiences =
      <Map<String, String>>[
        {
          'role': 'Dentist',
          'place': 'Hospital A',
          'time': '2022-2023',
          'detail': 'Specialist in dental surgery',
        },
        {
          'role': 'Dentist',
          'place': 'Hospital B',
          'time': '2020-2022',
          'detail': 'Specialist in dental surgery',
        },
      ].obs;

  String get currentState => _currentState.value;
  int get selectedIndex => _selectedIndex.value;

  void changeState(String state) => _currentState.value = state;
  void onItemTapped(int index) => _selectedIndex.value = index;

  RxString get currentStateRx => _currentState;
  RxInt get selectedIndexRx => _selectedIndex;
}

List<String> dayss = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

Map<String, List<String>> time_slotss = {
  "Morning": ["07:00", "07:30", "08:00", "08:30", "09:00", "09:30"],
  "Afternoon": ["10:00", "10:30", "11:00", "11:30", "12:00", "12:30"],
  "Evening": ["13:00", "13:30", "14:00", "14:30", "15:00", "15:30"],
  "Night": ["16:00", "16:30", "17:00", "17:30", "18:00", "18:30"],
};

class DetailDoctorPageDoctor extends StatelessWidget {
  const DetailDoctorPageDoctor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DetailDoctorControllerDoctor controller = Get.put(
      DetailDoctorControllerDoctor(),
    );

    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        title: Text('', style: GoogleFonts.poppins(color: blackColor)),
        backgroundColor: lightGreyColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                        scale: 0.8,
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
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  ['Schedule', 'About', 'Experience'].map((state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                controller.currentStateRx.value == state
                                    ? primaryColor
                                    : lightGreyColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () => controller.changeState(state),
                          child: Text(
                            state,
                            style: GoogleFonts.poppins(
                              color:
                                  controller.currentStateRx.value == state
                                      ? whiteColor
                                      : blackColor,
                              fontWeight: bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Obx(() {
                switch (controller.currentStateRx.value) {
                  case 'Schedule':
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: bold,
                              color: blackColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              border: Border.all(color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 7,
                                itemBuilder: (context, index) {
                                  return Obx(
                                    () => GestureDetector(
                                      onTap:
                                          () => controller.onItemTapped(index),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dayss[index],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: bold,
                                                color:
                                                    controller
                                                                .selectedIndexRx
                                                                .value ==
                                                            index
                                                        ? primaryColor
                                                        : blackColor,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${index + 1}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: bold,
                                                color:
                                                    controller
                                                                .selectedIndexRx
                                                                .value ==
                                                            index
                                                        ? primaryColor
                                                        : blackColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Select Time Period',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: bold,
                              color: blackColor,
                            ),
                          ),
                          Obx(
                            () => GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 3,
                              children:
                                  time_slotss.keys.map((period) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            controller.selectedPeriod.value ==
                                                    period
                                                ? primaryColor
                                                : whiteColor,
                                        foregroundColor:
                                            controller.selectedPeriod.value ==
                                                    period
                                                ? whiteColor
                                                : blackColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          () =>
                                              controller.selectedPeriod.value =
                                                  period,
                                      child: Text(period),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Available Times',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: bold,
                              color: blackColor,
                            ),
                          ),
                          Obx(
                            () => GridView.count(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 2.5,
                              children:
                                  time_slotss[controller.selectedPeriod.value]!
                                      .map((time) {
                                        return ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                controller.selectedTime.value ==
                                                        time
                                                    ? primaryColor
                                                    : whiteColor,
                                            foregroundColor:
                                                controller.selectedTime.value ==
                                                        time
                                                    ? whiteColor
                                                    : blackColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed:
                                              () =>
                                                  controller
                                                      .selectedTime
                                                      .value = time,
                                          child: Text(time),
                                        );
                                      })
                                      .toList(),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  case 'About':
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: bold,
                                ),
                              ),
                              Obx(
                                () => IconButton(
                                  icon: Icon(
                                    controller.isEditingAbout.value
                                        ? Icons.check
                                        : Icons.edit,
                                  ),
                                  onPressed:
                                      () => controller.isEditingAbout.toggle(),
                                ),
                              ),
                            ],
                          ),
                          Obx(
                            () =>
                                controller.isEditingAbout.value
                                    ? TextFormField(
                                      initialValue: controller.aboutText.value,
                                      maxLines: null,
                                      onChanged:
                                          (val) =>
                                              controller.aboutText.value = val,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Edit About",
                                      ),
                                    )
                                    : Text(
                                      controller.aboutText.value,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                      textAlign: TextAlign.justify,
                                    ),
                          ),
                        ],
                      ),
                    );
                  case 'Experience':
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Experience",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: bold,
                                ),
                              ),
                              Obx(
                                () => IconButton(
                                  icon: Icon(
                                    controller.isEditingExperience.value
                                        ? Icons.check
                                        : Icons.edit,
                                  ),
                                  onPressed:
                                      () =>
                                          controller.isEditingExperience
                                              .toggle(),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Obx(
                              () => ListView.builder(
                                itemCount: controller.experiences.length,
                                itemBuilder: (context, index) {
                                  final exp = controller.experiences[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child:
                                        controller.isEditingExperience.value
                                            ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  initialValue: exp['role'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Role',
                                                  ),
                                                  onChanged:
                                                      (val) =>
                                                          controller
                                                                  .experiences[index]['role'] =
                                                              val,
                                                ),
                                                TextFormField(
                                                  initialValue: exp['place'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Place',
                                                  ),
                                                  onChanged:
                                                      (val) =>
                                                          controller
                                                                  .experiences[index]['place'] =
                                                              val,
                                                ),
                                                TextFormField(
                                                  initialValue: exp['time'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Time',
                                                  ),
                                                  onChanged:
                                                      (val) =>
                                                          controller
                                                                  .experiences[index]['time'] =
                                                              val,
                                                ),
                                                TextFormField(
                                                  initialValue: exp['detail'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Detail',
                                                  ),
                                                  onChanged:
                                                      (val) =>
                                                          controller
                                                                  .experiences[index]['detail'] =
                                                              val,
                                                ),
                                                TextButton.icon(
                                                  onPressed:
                                                      () => controller
                                                          .experiences
                                                          .removeAt(index),
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  label: Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                Divider(),
                                              ],
                                            )
                                            : ExperienceCard(
                                              role: exp['role']!,
                                              place: exp['place']!,
                                              time: exp['time']!,
                                              detail: exp['detail']!,
                                            ),
                                  );
                                },
                              ),
                            ),
                          ),

                          Obx(
                            () =>
                                controller.isEditingExperience.value
                                    ? ElevatedButton.icon(
                                      onPressed: () {
                                        controller.experiences.add({
                                          'role': '',
                                          'place': '',
                                          'time': '',
                                          'detail': '',
                                        });
                                      },
                                      icon: Icon(Icons.add),
                                      label: Text("Add Experience"),
                                    )
                                    : SizedBox(),
                          ),
                        ],
                      ),
                    );
                  default:
                    return Center(
                      child: Text(
                        'Select an option.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: regular,
                          color: blackColor,
                        ),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
