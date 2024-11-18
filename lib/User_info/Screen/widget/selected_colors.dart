// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatting_app/Common/utils/functions.dart';
import 'package:chatting_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatting_app/User_info/Controller/userController.dart';

class ColorPickerScreen extends ConsumerStatefulWidget {
  static const routeName = "/select-bg-screen";
  final String appbar;
  final String background;

  const ColorPickerScreen({
    super.key,
    required this.appbar,
    required this.background,
  });

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends ConsumerState<ColorPickerScreen> {
  // Default colors for normal and gradient
  late Color selectedNormalColor;
  late Color startGradientColor;
  late Color endGradientColor; // Default gradient end color

  bool useBlockPicker = false; // Switch between ColorPicker and BlockPicker

  // Method to show normal color picker with style option
  void _pickNormalColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick a Normal Color"),
          content: SingleChildScrollView(
            child: useBlockPicker
                ? BlockPicker(
                    pickerColor: selectedNormalColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        selectedNormalColor = color;
                      });
                    },
                  )
                : ColorPicker(
                    pickerColor: selectedNormalColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        selectedNormalColor = color;
                      });
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print("Selected Normal Color: ${selectedNormalColor}");
                _applyNormalColor();
              },
              child: const Text("Select"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  useBlockPicker = !useBlockPicker;
                });
                Navigator.of(context).pop();
                _pickNormalColor(context);
              },
              child: Text(
                  "Switch to ${useBlockPicker ? 'Default Picker' : 'Block Picker'}"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize the colors in the initState
    selectedNormalColor = parseColor(widget.appbar); // Default normal color
    List<Color> gradientColors = parseGradientColor(widget.background);
    startGradientColor = gradientColors[0]; // Default gradient start color
    endGradientColor = gradientColors[1]; // Default gradient end color
  }

  // Method to apply the selected normal color to the AppBar
  void _applyNormalColor() {
    setState(() {
      // Update AppBar color when normal color is selected
    });
  }

  // Method to show gradient color picker with default start and end colors
  void _pickGradientColors(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pick Gradient Colors"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Pick Start Color"),
                useBlockPicker
                    ? BlockPicker(
                        pickerColor: startGradientColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            startGradientColor = color;
                          });
                        },
                      )
                    : ColorPicker(
                        pickerColor: startGradientColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            startGradientColor = color;
                          });
                        },
                      ),
                const SizedBox(height: 20),
                const Text("Pick End Color"),
                useBlockPicker
                    ? BlockPicker(
                        pickerColor: endGradientColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            endGradientColor = color;
                          });
                        },
                      )
                    : ColorPicker(
                        pickerColor: endGradientColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            endGradientColor = color;
                          });
                        },
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print(
                    "Selected Gradient Colors: Start - $startGradientColor, End - $endGradientColor");
                _applyGradientColors();
              },
              child: const Text("Select"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  useBlockPicker = !useBlockPicker;
                });
                Navigator.of(context).pop();
                _pickGradientColors(context);
              },
              child: Text(
                  "Switch to ${useBlockPicker ? 'Default Picker' : 'Block Picker'}"),
            ),
          ],
        );
      },
    );
  }

  // Method to apply the selected gradient colors to the background
  void _applyGradientColors() {
    setState(() {
      // Update the background gradient color when gradient colors are selected
    });
  }

  // Method to show color preview dialog
  void _showColorPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Color Preview"),
          content: Container(
            width: double.infinity,
            height:
                MediaQuery.of(context).size.height * 0.2, // Responsive height
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startGradientColor, endGradientColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: selectedNormalColor, // Used if no gradient is applied
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void setwallpaper() {
    String normalColorHex =
        '#${selectedNormalColor.value.toRadixString(16).padLeft(8, '0')}';
    String startGradientHex =
        '#${startGradientColor.value.toRadixString(16).padLeft(8, '0')}';
    String endGradientHex =
        '#${endGradientColor.value.toRadixString(16).padLeft(8, '0')}';
    print(
        "latest${normalColorHex}  and ${startGradientHex}  and ${endGradientHex}");
    ref.read(authControllerProvider).updatebg(
          normalColorHex,
          "$startGradientHex-$endGradientHex",
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SET THEME"),
        backgroundColor: selectedNormalColor,
        // AppBar color is updated here
        actions: [
          IconButton(
              onPressed: setwallpaper,
              icon: const Icon(
                Icons.done_outline,
                weight: 20,
              ))
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              startGradientColor,
              endGradientColor
            ], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _pickNormalColor(context),
                child: const Text("Pick APPBAR Color"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.5, 50), // Responsive width
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickGradientColors(context),
                child: const Text("Pick BACKGROUND Colors"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(screenWidth * 0.5, 50), // Responsive width
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
