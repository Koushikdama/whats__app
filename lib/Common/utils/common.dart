import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider with ChangeNotifier {
  Color _appBarColor = Colors.blue; // Default app bar color
  Color _backgroundColor = Colors.white; // Default background color

  Color get appBarColor => _appBarColor;
  Color get backgroundColor => _backgroundColor;

  /// Fetch theme data from Firebase
  Future<void> fetchThemeData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> themeDoc =
          await FirebaseFirestore.instance
              .collection('theme')
              .doc('themeId')
              .get();

      if (themeDoc.exists && themeDoc.data() != null) {
        final data = themeDoc.data()!;
        _appBarColor = _parseColor(data['bg']["Appbar"]);
        _backgroundColor = _parseColor(data['bg']["body"]);
        notifyListeners(); // Notify all listeners of the change
      }
    } catch (e) {
      debugPrint("Error fetching theme data: $e");
    }
  }

  /// Parse color from hex string
  Color _parseColor(String colorString) {
    return Color(int.parse(colorString.replaceAll('#', '0xFF')));
  }

  /// Update theme data in Firebase
  Future<void> updateThemeData(Color appBarColor, Color backgroundColor) async {
    try {
      await FirebaseFirestore.instance.collection('theme').doc('themeId').set({
        'appBarColor': '#${appBarColor.value.toRadixString(16).substring(2)}',
        'backgroundColor':
            '#${backgroundColor.value.toRadixString(16).substring(2)}',
      });
      _appBarColor = appBarColor;
      _backgroundColor = backgroundColor;
      notifyListeners(); // Notify listeners after updating
    } catch (e) {
      debugPrint("Error updating theme data: $e");
    }
  }
}
