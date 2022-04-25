import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/bluetooth/setup_bluetooth_screen.dart';
import 'package:marklin_bluetooth/controller_screen/speed_slider.dart';
import 'package:marklin_bluetooth/firebase/races.dart';

/// Screen for controlling and receiving lap times from the cars.
class ControllerScreen extends StatefulWidget {
  const ControllerScreen({Key? key}) : super(key: key);

  @override
  ControllerScreenState createState() => ControllerScreenState();
}

class ControllerScreenState extends State<ControllerScreen> {
  bool debugMode = false;
  bool enableSlowDown = true;
  int carID = 0;

  @override
  Widget build(BuildContext context) {
    if (debugMode) return buildDebug(context); // Debug mode

    if (Bluetooth.device == null) {
      // Setup Bluetooth
      return SetupBTScreen(
        onSetupComplete: (bool useDebug) => setState(() {
          debugMode = useDebug;
        }),
      );
    }

    return Theme(
      data: ThemeData(
        primarySwatch: [
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.grey,
        ][carID],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("BLE Controller"),
        ),
        body: buildSlider(),
      ),
    );
  }

  Widget buildSlider() {
    return SpeedSlider(
      debugMode: debugMode,
      enableSlowDown: enableSlowDown,
      onCarIDChange: (id) {
        setState(() {
          carID = id;
        });
      },
    );
  }

  Widget buildDebug(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: [
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.grey,
        ][carID],
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("BLE Controller (Debug)"),
          actions: [
            IconButton(
                icon: const Icon(Icons.plus_one),
                onPressed: () async =>
                    Races.currentRaceRef.addLap(carID) // Add lap to database
                ),
            IconButton(
                icon: Icon(enableSlowDown
                    ? Icons.toggle_on
                    : Icons.toggle_off_outlined),
                onPressed: () {
                  setState(() {
                    enableSlowDown = !enableSlowDown; // Toggle slowdown
                  });
                })
          ],
        ),
        body: buildSlider(),
      ),
    );
  }
}
