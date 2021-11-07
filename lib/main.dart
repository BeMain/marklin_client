import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/home.dart';
import 'package:marklin_bluetooth/race_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Märklin BLE Car Controller",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: InitFirebase(
            child: (Bluetooth.device == null)
                ? SelectDeviceScreen(
                    onDeviceConnected: (device) => setState(() {}))
                : HomeScreen()));
  }
}
