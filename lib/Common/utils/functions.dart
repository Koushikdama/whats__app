import 'dart:ui';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';

String getDate(dynamic date) {
  String mDY = "";

  if (date.runtimeType == String) {
    DateTime dateTime = DateTime.parse(date);

    // Format the DateTime to "MMM dd yy"
    mDY = DateFormat('MMM dd yy').format(dateTime);
  } else {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);

    // Format the DateTime to a human-readable format
    mDY = DateFormat('MMM dd yy').format(dateTime);
  }
  return mDY;
}

String convertTimestampToDateString(dynamic timestamp,
    {String test = "sample"}) {
  // Check if the timestamp is already a DateTime object
  DateTime dateTime;
  String formattedDate;
  if (timestamp is DateTime) {
    dateTime = timestamp; // If it's already DateTime, use it directly
  } else if (timestamp is int) {
    dateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp); // If it's an int (milliseconds), convert it
  } else {
    throw ArgumentError("The timestamp is not a valid DateTime or integer.");
  }

  // Format the date into YYYY_MM_DD
  formattedDate =
      "${dateTime.year}_${dateTime.month.toString().padLeft(2, '0')}_${dateTime.day.toString().padLeft(2, '0')}";
  if (test == "status") {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 30) {
      // Show time in minutes
      formattedDate = "${difference.inMinutes} minutes ago";
      return formattedDate;
    } else {
      // Show time in HH:mm format (hour:minute)
      String formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      return formattedTime;
    }
  }
  return formattedDate;
}

Future<String> getnamefromphone(String number) async {
  String name = "NOT OCCUR";

  List<Contact> contacts =
      await FlutterContacts.getContacts(withProperties: true);
  for (Contact c in contacts) {
    print(
        "c.phones[0].number.replaceAll(RegExp(r'\D'), '')${c.phones[0].number.replaceAll(RegExp(r'\D'), '')}");
    if (c.phones[0].number.replaceAll(RegExp(r'\D'), '') == number) {
      name = c.displayName;
      print("name ${c.displayName}");
    }
  }

  return name;
}

Color parseColor(String colorString) {
  return Color(int.parse(colorString.replaceAll('#', '0x')));
}

// Helper function to parse a gradient (two colors joined by '-')
List<Color> parseGradientColor(String colorString) {
  List<String> colorStrings = colorString.split('-');
  return colorStrings.map((color) => parseColor(color)).toList();
}
