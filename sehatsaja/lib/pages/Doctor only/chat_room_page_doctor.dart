import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =======================
// Controller
// =======================

class ChatRoomControllerDoctor extends GetxController {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();
  final isLoading = true.obs;
  final patientData = <String, dynamic>{}.obs;
  final scrollController = ScrollController();
  final picker = ImagePicker();
  final isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPatientData();
    _setupMessageListener();
  }

  Future<void> _loadPatientData() async {
    try {
      final patientDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Get.parameters['patientId'])
              .get();
      patientData.value = patientDoc.data() ?? {};
    } catch (e) {
      print('Error loading patient data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _setupMessageListener() {
    FirebaseFirestore.instance
        .collection('appointments')
        .doc(Get.parameters['appointmentId'])
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.assignAll(snapshot.docs.map((doc) => doc.data()));
          _scrollToBottom();
        });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      isUploading.value = true;
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = _getMimeType(image.path);

      await _sendImageMessage(base64Image, mimeType);
    } catch (e) {
      print('Error sending image: $e');
      Get.snackbar(
        'Error',
        'Failed to send image',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
    }
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _sendImageMessage(String base64Image, String mimeType) async {
    final newMessage = {
      'image': base64Image,
      'mimeType': mimeType,
      'isDoctor': true,
      'timestamp': FieldValue.serverTimestamp(),
      'isImage': true,
    };

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(Get.parameters['appointmentId'])
        .collection('messages')
        .add(newMessage);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = {
      'text': text.trim(),
      'isDoctor': true,
      'timestamp': FieldValue.serverTimestamp(),
      'isImage': false,
    };

    FirebaseFirestore.instance
        .collection('appointments')
        .doc(Get.parameters['appointmentId'])
        .collection('messages')
        .add(newMessage);

    messageController.clear();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}

// =======================
// UI
// =======================

class ChatRoomPageDoctor extends StatelessWidget {
  const ChatRoomPageDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomControllerDoctor());
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ Prevent layout shift
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.patientData['name'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: bold,
              color: whiteColor,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: lightGreyColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildPatientHeader(controller),
                              const SizedBox(height: 30),
                              Expanded(child: _buildMessagesList(controller)),
                            ],
                          ),
                        ),
                      ),
                      _buildMessageInput(controller, mediaQuery),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader(ChatRoomControllerDoctor controller) {
    final photoUrl = controller.patientData['photoUrl'];

    Widget avatarWidget;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        // Handle base64 image
        try {
          final base64Str = photoUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          avatarWidget = Image.memory(
            bytes,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        } catch (e) {
          avatarWidget = _buildDefaultAvatar();
        }
      } else {
        // Handle network URL
        avatarWidget = Image.network(
          photoUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
          loadingBuilder:
              (_, child, progress) =>
                  progress == null ? child : _buildDefaultAvatar(),
        );
      }
    } else {
      avatarWidget = _buildDefaultAvatar();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(25), child: avatarWidget),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.patientData['name'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: bold,
                color: blackColor,
              ),
            ),
            Text(
              'Patient',
              style: GoogleFonts.poppins(fontSize: 16, color: blackColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatRoomControllerDoctor controller) {
    return Obx(
      () => ListView.builder(
        controller: controller.scrollController,
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return message['isImage'] == true
              ? _buildImageBubble(message, context)
              : _buildTextBubble(message, context);
        },
      ),
    );
  }

  Widget _buildImageBubble(Map<String, dynamic> message, BuildContext context) {
    final isDoctor = message['isDoctor'] ?? false;
    final time =
        message['timestamp'] != null
            ? DateFormat(
              'HH:mm',
            ).format((message['timestamp'] as Timestamp).toDate())
            : '';
    final base64Image = message['image'] ?? '';

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(base64Image),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.cover,
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isDoctor ? Colors.white70 : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(Map<String, dynamic> message, BuildContext context) {
    final isDoctor = message['isDoctor'] ?? false;
    final time =
        message['timestamp'] != null
            ? DateFormat(
              'HH:mm',
            ).format((message['timestamp'] as Timestamp).toDate())
            : '';

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDoctor ? primaryColor : whiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDoctor ? whiteColor : blackColor,
              ),
            ),
            if (time.isNotEmpty)
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDoctor ? Colors.white70 : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    ChatRoomControllerDoctor controller,
    MediaQueryData mediaQuery,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 10,
        bottom: mediaQuery.viewInsets.bottom + 10,
        top: 10,
      ),
      color: whiteColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: primaryColor),
            onPressed: controller.pickAndSendImage,
          ),
          Expanded(
            child: TextFormField(
              controller: controller.messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: lightGreyColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ),
          Obx(
            () =>
                controller.isUploading.value
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                    : IconButton(
                      icon: Icon(Icons.send, color: primaryColor),
                      onPressed:
                          () => controller.sendMessage(
                            controller.messageController.text,
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
  }
}
