import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/btconnect.dart';

import 'package:marklin_bluetooth/controller.dart';
import 'package:marklin_bluetooth/lap_counter.dart';
import 'package:marklin_bluetooth/race_browser.dart';
import 'package:marklin_bluetooth/widgets.dart';

class FindDevicesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FindDevicesScreenState();
}

class FindDevicesScreenState extends State<FindDevicesScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  bool lapCounter = false;

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect Bluetooth"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  lapCounter = !lapCounter;
                });
              },
              icon: Icon(lapCounter ? Icons.dangerous : Icons.check,
                  color: Colors.white))
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: flutterBlue.isAvailable,
          builder: (c, snapshot) => !snapshot.hasData
              ? InfoScreen(
                  icon: CircularProgressIndicator(),
                  text: "Waiting for Bluetooth")
              : (snapshot.data == false)
                  ? InfoScreen(
                      icon: Icon(Icons.bluetooth_disabled),
                      text: "Bluetooth unavailable")
                  : StreamBuilder<List<ScanResult>>(
                      stream: flutterBlue.scanResults,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data
                            .map(
                                (result) => _bluetoothDeviceTile(result.device))
                            .toList(),
                      ),
                    ),
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, snapshot) => FloatingActionButton(
          child: Icon(snapshot.data ? Icons.bluetooth_searching : Icons.search),
          onPressed: () {
            if (!snapshot.data) // Not scanning
              flutterBlue.startScan(timeout: Duration(seconds: 4));
          },
        ),
      ),
    );
  }

  Widget _bluetoothDeviceTile(BluetoothDevice device) {
    return BluetoothDeviceTile(
      device: device,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => (lapCounter)
              ? PageView(children: [
                  LapCounterScreen(device: null),
                  RaceBrowserScreen()
                ])
              : BTConnect(
                  device: device,
                  connectedScreen: ControllerScreen(device: device),
                ),
        ),
      ),
    );
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  const BluetoothDeviceTile({Key key, this.device, this.onTap})
      : super(key: key);

  final BluetoothDevice device;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _buildTitle(context),
      onPressed: onTap,
    );
  }
}
