import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';

class ChatRoomController extends GetxController {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    messages.add({'text': text.trim(), 'isDoctor': false});
    messageController.clear();

    // Simulate doctor's reply (optional)
    Future.delayed(const Duration(milliseconds: 500), () {
      messages.add({
        'text': 'Got it! Let me schedule that for you.',
        'isDoctor': true,
      });
    });
  }
}

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: whiteColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: lightGreyColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Image.asset(
                            'assets/doctor.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. Mulyadi Akbar',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: bold,
                                color: blackColor,
                              ),
                            ),
                            Text(
                              'Dentist',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: regular,
                                color: blackColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Chat Bubbles (Reactive)
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          final isDoctor = message['isDoctor'] as bool;
                          return Align(
                            alignment:
                                isDoctor
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.only(bottom: 10.0),
                              decoration: BoxDecoration(
                                color: isDoctor ? whiteColor : primaryColor,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                message['text'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: regular,
                                  color: isDoctor ? blackColor : whiteColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Input Field
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                  top: 10,
                ),
                color: whiteColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.messageController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: whiteColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Type a message',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: regular,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: primaryColor),
                      onPressed: () {
                        controller.sendMessage(
                          controller.messageController.text,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
