import 'package:flutter_blue/flutter_blue.dart';

class Bluetooth {
  /// The current Bluetooth Device.
  /// Should always be connected if not null.
  static BluetoothDevice? device;

  /// UUID for most recently used [service].
  static String serviceID = "0000181c-0000-1000-8000-00805f9b34fb";

  /// Current Bluetooth Service used by ControllerScreen.
  static BluetoothService? service;

  /// UUID for most recently used [speedChar]
  static String speedCharID = "0000180c-0000-1000-8000-00805f9b34fb";

  /// Current Bluetooth Characteristic used for sending speed to server.
  static BluetoothCharacteristic? speedChar;

  /// UUID for most recently used [lapChar]
  static String lapCharID = "0000181c-0000-1000-8000-00805f9b34fb";

  /// Current Bluetooth Characteristic used for receiving lap times from server.
  static BluetoothCharacteristic? lapChar;
}