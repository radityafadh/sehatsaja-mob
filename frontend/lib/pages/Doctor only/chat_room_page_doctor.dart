import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/shared/theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomControllerDoctor extends GetxController {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();
  final isTyping = false.obs;
  final isLoading = true.obs;
  final patientData = <String, dynamic>{}.obs;
  final ScrollController scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();
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
      isLoading.value = false;
    } catch (e) {
      print('Error loading patient data: $e');
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
          duration: Duration(milliseconds: 300),
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
      print('Error picking/sending image: $e');
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
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
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
    setTyping(false);
  }

  void setTyping(bool typing) {
    isTyping.value = typing;
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}

class ChatRoomPageDoctor extends StatelessWidget {
  const ChatRoomPageDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomControllerDoctor());
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: _buildAppBar(controller),
      resizeToAvoidBottomInset: true,
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Obx(
          () =>
              controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildChatContent(controller, mediaQuery),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ChatRoomControllerDoctor controller) {
    return AppBar(
      title: Obx(
        () => Text(
          '${controller.patientData['name']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold,
            color: whiteColor,
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
    );
  }

  Widget _buildChatContent(
    ChatRoomControllerDoctor controller,
    MediaQueryData mediaQuery,
  ) {
    return Column(
      children: [
        // Chat messages area with flexible space
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: lightGreyColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Column(
              children: [
                _buildPatientHeader(controller),
                const SizedBox(height: 30),
                Expanded(child: _buildMessagesList(controller)),
                Obx(
                  () =>
                      controller.isTyping.value
                          ? _buildTypingIndicator()
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        // Message input area (fixed at bottom)
        _buildMessageInput(controller, mediaQuery),
      ],
    );
  }

  Widget _buildPatientHeader(ChatRoomControllerDoctor controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPatientAvatar(controller),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.patientData['name']}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: bold,
                color: blackColor,
              ),
            ),
            Text(
              'Patient',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: regular,
                color: blackColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientAvatar(ChatRoomControllerDoctor controller) {
    final photoUrl = controller.patientData['photoUrl'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child:
          photoUrl != null
              ? Image.network(
                photoUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultAvatar();
                },
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              )
              : _buildDefaultAvatar(),
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
              : _buildMessageBubble(message, context);
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
    final base64Image = message['image'] as String;

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDoctor ? primaryColor : whiteColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(
                  base64Decode(base64Image),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
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

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    BuildContext context,
  ) {
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: isDoctor ? primaryColor : whiteColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: regular,
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

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        'Patient is typing...',
        style: GoogleFonts.poppins(fontSize: 12, color: blackColor),
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
                fillColor: whiteColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              onChanged: (text) {
                controller.setTyping(text.isNotEmpty);
              },
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
                      onPressed: () {
                        controller.sendMessage(
                          controller.messageController.text,
                        );
                      },
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
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.grey[400], size: 30),
    );
  }
}
