import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/theme.dart';

class RatingDialog extends StatefulWidget {
  final String appointmentId;

  const RatingDialog({super.key, required this.appointmentId});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double? _rating;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How would you rate this appointment? (Optional)'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  _rating != null && index < _rating!.floor()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
              );
            }),
          ),
          if (_rating != null) ...[
            Slider(
              value: _rating!,
              min: 1,
              max: 5,
              divisions: 8,
              label: _rating!.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            Text(
              'Your rating: ${_rating!.toStringAsFixed(1)}/5.0',
              style: const TextStyle(fontSize: 16),
            ),
          ],
          const SizedBox(height: 16),
          if (_rating != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _rating = null;
                });
              },
              child: const Text('Clear rating'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Get.back(),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          child:
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      final updateData = {if (_rating != null) 'rating': _rating};

      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update(updateData);

      Get.back();
      Get.snackbar(
        'Success',
        _rating != null
            ? 'Thank you for your rating!'
            : 'Appointment marked as completed',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update rating: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
