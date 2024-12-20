import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AvailabilityPage extends StatefulWidget {
  final String sellerId;

  AvailabilityPage({required this.sellerId});

  @override
  _AvailabilityPageState createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  List<Meeting> meetings = [];

  void _addEvent(DateTime day) {
    setState(() {
      meetings.add(Meeting(
        'Available',
        DateTime(day.year, day.month, day.day, 9, 0),
        DateTime(day.year, day.month, day.day, 10, 0),
        Colors.green,
        false,
      ));
    });
  }

  void _removeEvent(Meeting meeting) {
    setState(() {
      meetings.remove(meeting);
    });
  }

  void _submitAvailability() async {
    try {
      await FirebaseFirestore.instance
          .collection('availability')
          .doc(widget.sellerId)
          .set({
        'meetings': meetings.map((meeting) => {
              'title': meeting.eventName,
              'start': meeting.from,
              'end': meeting.to,
              'color': meeting.background.value,
            }).toList(),
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle any errors here
      print('Error saving availability: $e');
    }
  }

  Future<void> _showAddEventDialog() async {
    DateTime selectedDay = DateTime.now();
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Availability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDay,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDay = picked;
                    });
                  }
                },
                child: Text('Select Date: ${selectedDay.toLocal()}'.split(' ')[0]),
              ),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) {
                    setState(() {
                      startTime = picked;
                    });
                  }
                },
                child: Text('Select Start Time: ${startTime.format(context)}'),
              ),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setState(() {
                      endTime = picked;
                    });
                  }
                },
                child: Text('Select End Time: ${endTime.format(context)}'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  meetings.add(Meeting(
                    'Available',
                    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, startTime.hour, startTime.minute),
                    DateTime(selectedDay.year, selectedDay.month, selectedDay.day, endTime.hour, endTime.minute),
                    Colors.green,
                    false,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Availability'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _submitAvailability();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.week,
        dataSource: MeetingDataSource(meetings),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          timeInterval: Duration(minutes: 30),
          timeFormat: 'h:mm a',
        ),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            final meeting = details.appointments!.first as Meeting;
            _removeEvent(meeting);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}