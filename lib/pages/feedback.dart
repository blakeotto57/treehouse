import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> saveFeedback(String feedback, int rating, {bool isBugReport = false}) async {
    await FirebaseFirestore.instance.collection('feedback').add({
      'feedback': feedback,
      'rating': rating,
      'isBugReport': isBugReport,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _submitFeedback() async {
    final feedback = feedbackController.text;

    if (feedback.isEmpty || feedback.length < minFeedbackLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter at least $minFeedbackLength characters of feedback.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await saveFeedback(feedback, selectedRating);

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

    setState(() {
      isSubmitting = true;
    });

    await saveFeedback(bugReport, 0, isBugReport: true);

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(182, 151, 247, 6), const Color.fromARGB(255, 51, 84, 1)], // Match the gradient colors as desired
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text(
              'Feedback',
              style: TextStyle(color: Colors.black), // Customize text color
            ),
            backgroundColor: Colors.transparent, // Transparent to show the gradient
            elevation: 20, // Remove shadow
            iconTheme: IconThemeData(color: Colors.black), // Customize icon color if needed
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 200, 250, 143), const Color.fromARGB(255, 73, 174, 246)], // Gradient colors for the page
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Feedback Text Box
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  labelText: 'Enter your feedback',
                  border: OutlineInputBorder(),
                  counterText: '${feedbackController.text.length}/$minFeedbackLength characters',
                ),
                maxLength: 1000, // Optional maximum character limit
                onChanged: (value) {
                  setState(() {});
                },
                maxLines: 3,
              ),
              SizedBox(height: 10),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),

              // Submit Button
              isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Updated color for Submit Feedback
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _submitFeedback,
                      child: Text('Submit Feedback'),
                    ),
              SizedBox(height: 20),

              // "Report a Bug" Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showBugReportBox = !showBugReportBox;
                  });
                },
                icon: Icon(Icons.bug_report),
                label: Text('Report a Bug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange, // Updated color for Report a Bug
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (showBugReportBox) ...[
                SizedBox(height: 20),

                // Bug Report Text Box
                TextField(
                  controller: bugReportController,
                  decoration: InputDecoration(
                    labelText: 'Describe the bug',
                    border: OutlineInputBorder(),
                    counterText: '${bugReportController.text.length}/$minFeedbackLength characters',
                  ),
                  maxLength: 1000, // Optional maximum character limit
                  onChanged: (value) {
                    setState(() {});
                  },
                  maxLines: 3,
                ),
                SizedBox(height: 10),

                // Submit Bug Report Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange, // Updated color for Submit Bug Report
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _submitBugReport,
                  child: Text('Submit Bug Report'),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
