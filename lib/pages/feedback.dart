import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? globalUserName;

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController bugReportController = TextEditingController();
  bool isSubmitting = false;
  bool showBugReportBox = false; // Controls visibility of the bug report box
  int selectedRating = 0;
  final int minFeedbackLength = 10;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    if (globalUserName == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        globalUserName = prefs.getString('userName');
      });
    }
  }

  Future<void> saveFeedback(String username, String feedback, int rating, {bool isBugReport = false}) async {
    try {
      await FirebaseFirestore.instance.collection('feedback').doc(username).set({
        'username': username,
        'feedback': feedback,
        'rating': rating,
        'isBugReport': isBugReport,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Feedback successfully saved for username: $username');
    } catch (e) {
      print('Error saving feedback: $e');
    }
  }

  void _submitFeedback() async {
    final feedback = feedbackController.text;

    if (feedback.isEmpty || feedback.length < minFeedbackLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least $minFeedbackLength characters of feedback.')),
      );
      return;
    }

    if (globalUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username is not set. Please try again later.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await saveFeedback(globalUserName!, feedback, selectedRating);

    setState(() {
      isSubmitting = false;
      selectedRating = 0;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback Submitted'),
          content: Text('Thank you for your feedback!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    feedbackController.clear();
  }

  void _submitBugReport() async {
    final bugReport = bugReportController.text;

    if (bugReport.isEmpty || bugReport.length < minFeedbackLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least $minFeedbackLength characters for the bug report.')),
      );
      return;
    }

    if (globalUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username is not set. Please try again later.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await saveFeedback(globalUserName!, bugReport, 0, isBugReport: true);

    setState(() {
      isSubmitting = false;
      showBugReportBox = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bug Report Submitted'),
          content: Text('Thank you for reporting the bug!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    bugReportController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Feedback",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[300],
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to prevent overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Feedback Text Box
            TextField(
              controller: feedbackController,
                decoration: const InputDecoration(hintText: 'Your Feedback'),
                maxLines: null, // Allows multi-line input
                maxLength: 100, // Limits to 100 characters
                maxLengthEnforcement: MaxLengthEnforcement.enforced,

                
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 10),


            // Submit Feedback Button
            isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _submitFeedback,
                    child: Text('Submit Feedback'),
                  ),
            SizedBox(height: 20),
        
          ],
        ),
      ),
    );
  }
}
