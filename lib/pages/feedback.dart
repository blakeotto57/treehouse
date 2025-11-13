import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:treehouse/theme/theme.dart';
import 'package:treehouse/components/professional_navbar.dart';
import 'package:treehouse/components/slidingdrawer.dart';
import 'package:treehouse/components/drawer.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final accent = isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;
    final GlobalKey<SlidingDrawerState> _drawerKey = GlobalKey<SlidingDrawerState>();

    return SlidingDrawer(
      key: _drawerKey,
      drawer: customDrawer(context),
      child: Scaffold(
        backgroundColor: background,
        drawer: customDrawer(context),
        appBar: ProfessionalNavbar(drawerKey: _drawerKey),
        body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.feedback, color: accent, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      "We value your feedback!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Let us know what you think about the website or report a bug.",
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Feedback Text Box
                    TextField(
                      controller: feedbackController,
                      decoration: InputDecoration(
                        hintText: 'Your feedback (min $minFeedbackLength characters)',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                        counterText: '',
                      ),
                      maxLines: 4,
                      maxLength: 100,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    // Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < selectedRating ? Colors.amber : Colors.grey[400],
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          tooltip: "Rate ${index + 1} star${index == 0 ? '' : 's'}",
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    // Toggle bug report
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: showBugReportBox,
                          onChanged: (val) {
                            setState(() {
                              showBugReportBox = val ?? false;
                            });
                          },
                          activeColor: accent,
                        ),
                        Text(
                          "Report a bug",
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Bug report box
                    if (showBugReportBox)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: bugReportController,
                          decoration: InputDecoration(
                            hintText: 'Describe the bug...',
                            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                            filled: true,
                            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accent, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accent, width: 2),
                            ),
                          ),
                          maxLines: 3,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    // Submit Feedback Button
                    isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _submitFeedback,
                              icon: const Icon(Icons.send, color: Colors.white),
                              label: const Text(
                                'Submit Feedback',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
