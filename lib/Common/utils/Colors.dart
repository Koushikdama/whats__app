import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserTheme {
  final Color appBarColor;
  final Color bodyColor;
  final Color endBodyColor;

  // Constructor for UserTheme
  UserTheme({
    required this.appBarColor,
    required this.bodyColor,
    required this.endBodyColor,
  });

  // Factory constructor to create UserTheme from Firestore data
  factory UserTheme.fromFirestore(DocumentSnapshot userSnapshot) {
    // Safely extract the data and cast it to the correct type
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    // Extract the color data from Firestore
    String appBarColorString =
        userData['bg']['Appbar'] ?? '#ff4caf40'; // Default value if null
    String bodyColorString = userData['bg']['body'] ??
        '#ffff9800-#ff03a9f4'; // Default value if null
    print("appBarColorString${appBarColorString} and ${bodyColorString}");
    // Parse the colors
    Color appBarColor = _parseColor(appBarColorString);
    List<Color> bodyColors = _parseGradientColor(bodyColorString);

    // Return the UserTheme object with the parsed colors
    return UserTheme(
      appBarColor: appBarColor,
      bodyColor: bodyColors.isNotEmpty ? bodyColors[0] : Colors.transparent,
      endBodyColor: bodyColors.length > 1 ? bodyColors[1] : Colors.transparent,
    );
  }

  // Helper function to parse a single color (e.g., "#ff4caf50")
  static Color _parseColor(String colorString) {
    return Color(int.parse(colorString.replaceAll('#', '0x')));
  }

  // Helper function to parse a gradient (two colors joined by '-')
  static List<Color> _parseGradientColor(String colorString) {
    List<String> colorStrings = colorString.split('-');
    return colorStrings.map((color) => _parseColor(color)).toList();
  }
}

// Function to fetch user theme (colors) from Firestore
Future<UserTheme?> fetchUserTheme() async {
  try {
    // Fetch the user document from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users') // Assuming the collection is named 'users'
        .doc(FirebaseAuth.instance.currentUser!.uid) // Current user ID
        .get();

    if (userSnapshot.exists) {
      // Create UserTheme object from Firestore data
      return UserTheme.fromFirestore(userSnapshot);
    } else {
      print('User not found');
      return null;
    }
  } catch (e) {
    print('Error fetching user theme: $e');
    return null;
  }
}
