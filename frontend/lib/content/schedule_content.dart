import 'package:flutter/material.dart';

class ScheduleContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        10,
        (index) => ListTile(
          title: Text('Schedule Item ${index + 1}'),
          subtitle: Text('Details about schedule item ${index + 1}'),
        ),
      ),
    );
  }
}
