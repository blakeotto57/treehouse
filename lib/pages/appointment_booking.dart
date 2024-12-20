import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBookingPage extends StatelessWidget {
  final String sellerId;

  AppointmentBookingPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('sellerId', isEqualTo: sellerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading appointments"));
          }
          if (snapshot.hasData && snapshot.data != null) {
            final appointments = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Meeting(
                data['title'],
                data['startTime'].toDate(),
                data['endTime'].toDate(),
                data['isBooked'] ? Colors.red : Colors.green,
                false,
              );
            }).toList();
            return SfCalendar(
              view: CalendarView.week,
              dataSource: MeetingDataSource(appointments),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            );
          }
          return const Center(child: Text("No appointments available"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement payment and booking logic here
        },
        backgroundColor: Colors.green[300],
        child: const Icon(Icons.check),
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