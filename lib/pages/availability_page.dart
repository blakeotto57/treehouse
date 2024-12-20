import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityPage extends StatefulWidget {
  final String sellerId;

  AvailabilityPage({required this.sellerId});

  @override
  _AvailabilityPageState createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  Map<String, List<Map<String, TimeOfDay>>> availability = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  void _selectTime(String day, int index, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          availability[day]![index]['start'] = picked;
        } else {
          availability[day]![index]['end'] = picked;
        }
      });
    }
  }

  void _addEvent(String day) {
    setState(() {
      availability[day]!.add({'start': TimeOfDay.now(), 'end': TimeOfDay.now()});
    });
  }

  void _removeEvent(String day, int index) {
    setState(() {
      availability[day]!.removeAt(index);
    });
  }

  void _submitAvailability() {
    FirebaseFirestore.instance
        .collection('availability')
        .doc(widget.sellerId)
        .set(availability.map((day, times) => MapEntry(day, times.map((time) => {
              'start': time['start']!.format(context),
              'end': time['end']!.format(context),
            }).toList())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Availability'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _submitAvailability,
          ),
        ],
      ),
      body: ListView(
        children: availability.keys.map((day) {
          return ExpansionTile(
            title: Text(day),
            children: [
              ...availability[day]!.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, TimeOfDay> time = entry.value;
                return ListTile(
                  title: Text(
                      '${time['start']!.format(context)} - ${time['end']!.format(context)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () => _selectTime(day, index, true),
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: () => _selectTime(day, index, false),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeEvent(day, index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: () => _addEvent(day),
                child: Text('Add Event'),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}