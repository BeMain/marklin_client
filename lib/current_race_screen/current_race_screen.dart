import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/current_race_screen/new_race_dialog.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/current_race_screen/current_laps_viewer.dart';
import 'package:marklin_bluetooth/widgets.dart';

class CurrentRaceScreen extends StatefulWidget {
  /// Screen for watching and restarting the current race.
  const CurrentRaceScreen({super.key});

  @override
  State<StatefulWidget> createState() => CurrentRaceScreenState();
}

class CurrentRaceScreenState extends State<CurrentRaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Race"),
      ),
      body: const CurrentLapsViewer(),
      floatingActionButton: StreamBuilder<bool>(
        stream: Races.currentRaceRef.runningStream,
        builder: niceAsyncBuilder(
          activeBuilder: (c, snapshot) {
            bool running = snapshot.data!;
            return FloatingActionButton(
              heroTag: "current_race",
              child: Icon(running ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (running) {
                    // Stop race
                    showNewDialog(context);
                  } else {
                    DateTime timeNow = DateTime.now();
                    // Start race
                    Races.currentRaceDoc.update({
                      "date": Timestamp.fromDate(timeNow),
                      "running": true,
                    });
                    for (CarReference car in Races.currentRaceRef.carRefs) {
                      car.currentLap.date = timeNow;
                    }
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showNewDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (c) => NewRaceDialog(
        onSave: (int nCars) async {
          await Races.saveCurrentRace();
          restartRace(nCars);
        },
        onDiscard: (int nCars) async {
          await Races.currentRaceRef.clear();
          restartRace(nCars);
        },
      ),
    );
  }

  void restartRace(int nCars) async {
    await Races.currentRaceDoc.update({
      "running": false,
      "nCars": nCars,
    });
    setState(() {});
  }
}
