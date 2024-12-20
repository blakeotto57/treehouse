import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/pages/seller_calendar.dart'; // Import the seller calendar page

class SellerCalendarPage extends StatelessWidget {
  final String sellerId;

  SellerCalendarPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Availability',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[300],
        centerTitle: true,
        elevation: 2,
      ),
      body: SfCalendar(
        view: CalendarView.week,
        dataSource: MeetingDataSource(_getDataSource()),
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final DateTime selectedDate = details.date!;
            _showAddAppointmentDialog(context, selectedDate);
          }
        },
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    // Fetch existing availability from Firestore and add to meetings list
    return meetings;
  }

  void _showAddAppointmentDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Availability'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selected Date: ${selectedDate.toLocal()}'),
              // Add more fields if needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save availability to Firestore
                FirebaseFirestore.instance.collection('appointments').add({
                  'sellerId': sellerId,
                  'title': 'Available',
                  'startTime': selectedDate,
                  'endTime': selectedDate.add(Duration(hours: 1)),
                  'isBooked': false,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
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

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 2,
        actions: [
          if (userId != null)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Container();
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final isSeller = userData['isSeller'] ?? false;
                if (isSeller) {
                  return IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: 'Set Availability',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerCalendarPage(sellerId: userId),
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
        ],
      ),
      body: Center(
        child: Text("User Profile Content"),
      ),
    );
  }
}