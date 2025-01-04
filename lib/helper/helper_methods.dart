// return a formmatted data as a string
import "package:cloud_firestore/cloud_firestore.dart";

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // get year
  String year = dateTime.year.toString();

  // get month
  String month = dateTime.month.toString();

  // get day
  String day = dateTime.day.toString();

  // get hour
  String hour = dateTime.hour.toString();

  // get minute
  String minute = dateTime.minute.toString();

  // final formatted data
  String formattedData = "$month/$day/$year $hour:$minute";

  return formattedData;


}