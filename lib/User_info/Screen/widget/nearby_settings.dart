import 'package:chatting_app/User_info/Controller/userController.dart';
import 'package:chatting_app/User_info/Model/getlocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class NearbySettings extends ConsumerStatefulWidget {
  final bool ison;
  final String
      limint; // Assuming this is a string that can be converted to a double
  static const routeName = "/near-by-screen";

  const NearbySettings({
    super.key,
    required this.ison,
    required this.limint,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<NearbySettings> {
  late bool _isSwitchOn;
  late double _sliderValue;
  late double latitude = 0.0;
  late double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    // Set initial state from the arguments
    _isSwitchOn = widget.ison;
    // Parse the limit to double, defaulting to 0 if parsing fails
    _sliderValue = double.tryParse(widget.limint) ?? 0;
  }

  void nearbyme(bool _nearbyMe, BuildContext context) async {
    if (_nearbyMe == true) {
      try {
        Position position = await determinePosition();
        setState(() {
          latitude = position.altitude;
          longitude = position.latitude;
        });

        //print(
        // "latitude: ${position.latitude} & longitude: ${position.longitude} && location${position.timestamp}");

        // If the position is successfully retrieved, set nearbyMe to true
        setState(() {
          _isSwitchOn = _nearbyMe;
        });
      } catch (e) {
        // If there is an error, such as permission denied, set nearbyMe to false
        setState(() {
          _isSwitchOn = _nearbyMe;
        });
      }
    } else {
      setState(() {
        _isSwitchOn = false;
      });
    }
  }

  void savelocation() {
    print("${latitude} ${longitude}");
    ref.read(authControllerProvider).saveuserlocation(
        context, latitude, longitude, _sliderValue.toInt(), _isSwitchOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch and Slider UI'),
        actions: [
          IconButton(
              onPressed: savelocation, icon: const Icon(Icons.done_outline))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Switch widget
            const Divider(),
            SwitchListTile(
              title: const Text('NEAR BY ME'),
              value: _isSwitchOn,
              onChanged: (bool value) {
                setState(() {
                  nearbyme(value, context);
                });
              },
            ),
            const Divider(),
            const SizedBox(height: 90),
            // Slider widget
            Text(
              'Slider Value: ${_sliderValue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18),
            ),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 4, // 5 steps (0, 25, 50, 75, 100)
              label: _sliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
