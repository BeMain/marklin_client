import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/controller.dart';
import 'package:marklin_bluetooth/find_devices.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Märklin BLE Car Controller",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ControllerScreen());
  }
}
