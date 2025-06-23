import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatsaja/shared/theme.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final messages = <Map<String, dynamic>>[].obs;
  final messageController = TextEditingController();
  final isLoading = true.obs;
  final doctorData = <String, dynamic>{}.obs;
  final scrollController = ScrollController();
  final picker = ImagePicker();
  final isUploading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _setupMessageListener();
  }

  Future<void> _loadDoctorData() async {
    try {
      final doctorDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(Get.parameters['doctorId'])
              .get();
      doctorData.value = doctorDoc.data() ?? {};
    } catch (e) {
      print('Error loading doctor data: $e');
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
      'isDoctor': false,
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
      'isDoctor': false,
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
  void dispose() {
    scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Obx(
          () => Text(
            'Dr. ${doctorData['name']}',
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
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Obx(
          () =>
              isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
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
                              _buildDoctorHeader(),
                              const SizedBox(height: 30),
                              Expanded(child: _buildMessagesList()),
                            ],
                          ),
                        ),
                      ),
                      _buildMessageInput(mediaQuery),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
    );
  }

  Widget _buildDoctorHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDoctorAvatar(),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. ${doctorData['name']}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: bold,
                color: blackColor,
              ),
            ),
            Text(
              'Doctor',
              style: GoogleFonts.poppins(fontSize: 16, color: blackColor),
            ),
            if (doctorData['specialization'] != null)
              Text(
                '${doctorData['specialization']}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorAvatar() {
    final photoUrl = doctorData['photoUrl'];

    if (photoUrl == null || photoUrl.isEmpty) {
      return _buildDefaultAvatar();
    }

    // Check if it's a base64 string
    if (photoUrl.startsWith('data:image')) {
      try {
        final base64Str = photoUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Image.memory(bytes, width: 50, height: 50, fit: BoxFit.cover),
        );
      } catch (e) {
        return _buildDefaultAvatar();
      }
    }

    // Otherwise treat it as a network URL
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: Image.network(
        photoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder:
            (context, child, progress) =>
                progress == null ? child : _buildDefaultAvatar(),
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(
      () => ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return message['isImage'] == true
              ? _buildImageBubble(message)
              : _buildMessageBubble(message);
        },
      ),
    );
  }

  Widget _buildImageBubble(Map<String, dynamic> message) {
    final isDoctor = message['isDoctor'] ?? false;
    final time =
        message['timestamp'] != null
            ? DateFormat(
              'HH:mm',
            ).format((message['timestamp'] as Timestamp).toDate())
            : '';
    final base64Image = message['image'] as String;

    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.memory(
                base64Decode(base64Image),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.cover,
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDoctor = message['isDoctor'] ?? false;
    final time =
        message['timestamp'] != null
            ? DateFormat(
              'HH:mm',
            ).format((message['timestamp'] as Timestamp).toDate())
            : '';

    return Align(
      alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: isDoctor ? whiteColor : primaryColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message['text'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDoctor ? blackColor : whiteColor,
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

  Widget _buildMessageInput(MediaQueryData mediaQuery) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: mediaQuery.viewInsets.bottom + 10,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: lightGreyColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(
              () =>
                  isUploading.value
                      ? const CircularProgressIndicator()
                      : Row(
                        children: [
                          GestureDetector(
                            onTap: pickAndSendImage,
                            child: Icon(
                              Icons.image_outlined,
                              color: primaryColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => sendMessage(messageController.text),
                            child: Icon(
                              Icons.send,
                              color: primaryColor,
                              size: 30,
                            ),
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
