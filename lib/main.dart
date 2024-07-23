import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late bool supported;
  late Stream<bool> available;
  late bool hasLEScan;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Bluetooth API supported: $supported'),
              Text('Has LE Scan: $hasLEScan'),
              StreamBuilder(
                stream: available,
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Text('Available ${snapshot.data}');
                },
              ),
              StreamBuilder(
                stream: FlutterWebBluetooth.instance.devices,
                initialData: const {},
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return Text(snapshot.toString());
                },
              ),
              ElevatedButton(
                  onPressed: () => getBTDevices(),
                  child: const Text(
                    'get devices',
                  ))
            ],
          ),
        ),
      ),
    ));
  }

  void init() {
    supported = FlutterWebBluetooth.instance.isBluetoothApiSupported;

    available = FlutterWebBluetooth.instance.isAvailable;

    hasLEScan = FlutterWebBluetooth.instance.hasRequestLEScan;
    if (mounted) {
      setState(() {});
    }
  }

  void getBTDevices() async {
    try {
      Bluetooth.requestLEScan(BluetoothLEScanOptions(filters: [
        BluetoothScanFilter(
          name: 'MAJOR IV',
        )
      ], keepRepeatedDevices: true, acceptAllAdvertisements: false));
    } catch (e) {
      print(e);
    }
  }
}
