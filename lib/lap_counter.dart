import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/race_handler.dart';

import 'package:marklin_bluetooth/widgets.dart';

/// Widget for handling laps and lap times.
///
/// Connects to and receives lap times from [device].
/// Also features buttons for adding laps manually (temporary debug).
///
/// Stores the laps on a Cloud Firestore database,
/// using [RaceHandler] to read and write data.
class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  RaceHandler raceHandler = RaceHandler();

  List<Stopwatch> lapTimers = List.generate(4, (index) => Stopwatch()..start());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lap Counter"),
          leading: IconButton(
              onPressed: () => _showQuitDialog(context),
              icon: Icon(Icons.bluetooth_disabled, color: Colors.white)),
          actions: [
            IconButton(
                onPressed: () => _showStartDialog(context),
                icon: Icon(Icons.add, color: Colors.white)),
            IconButton(
                onPressed: () => _showRestartDialog(context),
                icon: Icon(Icons.clear, color: Colors.white)),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: raceHandler.stream,
            builder: (c, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return InfoScreen(
                  icon: CircularProgressIndicator(),
                  text: "Getting lap times...",
                );

              if (snapshot.hasError)
                return InfoScreen(
                  icon: Icon(Icons.error),
                  text: "Error: ${snapshot.error}",
                );

              var doc = snapshot.data.data();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _lapViewer(0, doc["0"].length),
                  VerticalDivider(
                    thickness: 1.0,
                  ),
                  _lapViewer(1, doc["1"].length),
                ],
              );
            }));
  }

  Widget _lapViewer(int carID, int laps) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Center(
            child: Text(
              "$laps",
              textScaleFactor: 5.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Add lap to database
              var lapTime = lapTimers[carID].elapsedMilliseconds / 1000;
              raceHandler.addLap(carID, lapTime);

              // Restart timer
              lapTimers[carID].reset();
            });
          },
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor)),
          child: Icon(Icons.plus_one),
        )
      ],
    );
  }

  /// Popup Dialog for exiting this widget
  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => QuitDialog(
        onQuit: () => widget.device.disconnect(),
      ),
    );
  }

  /// Popup Dialog for starting a new race
  void _showStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Start new race"),
        content: Text(
            "You are about to start a new race.\nThe current race will be saved to the database, and can be viewed through the RaceViewer screen."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
              onPressed: () {
                // Save current race to database database
                raceHandler.saveRace().then((_) => setState(() {}));

                Navigator.of(context).pop();
              },
              child: Text("Continue")),
        ],
      ),
    );
  }

  /// Popup Dialog for restarting the current race
  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Restart race?"),
        content: Text(
            "You are about to restart the race and clear all laps. This action can't be undone."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  // Clear laps on database
                  raceHandler.clearLaps();

                  // Restart timers
                  for (final timer in lapTimers) {
                    timer.reset();
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("Continue")),
        ],
      ),
    );
  }
}
