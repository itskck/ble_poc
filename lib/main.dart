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
  BluetoothDevice? device;
  late bool connected;
  String? services;

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
              if (device != null)
                StreamBuilder(
                  stream: device!.connected,
                  initialData: const [],
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == true) {
                      return Column(
                        children: [
                          Text('Device ${device!.name} connected '),
                          StreamBuilder(
                            stream: device!.services,
                            builder: (context, snapshot) =>
                                Text(snapshot.data.toString()),
                          ),
                        ],
                      );
                    } else {
                      return Text('Device ${device!.name} disconected');
                    }
                  },
                ),
              ElevatedButton(
                  onPressed: () => getBTDevices(),
                  child: const Text(
                    'get devices',
                  )),
              if (device != null)
                ElevatedButton(
                    onPressed: () async {
                      if (device != null) {
                        try {
                          await device!.connect();
                          services =
                              (await device!.discoverServices()).toString();
                          setState(() {});
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }
                      }
                    },
                    child: const Text(
                      'Connect',
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
      final whot = await FlutterWebBluetooth.instance
          .requestDevice(RequestOptionsBuilder.acceptAllDevices());
      // final req =
      //     await Bluetooth.requestLEScan(BluetoothLEScanOptions(filters: [
      //   BluetoothScanFilter(
      //     services: null,
      //     serviceData: null,
      //     name: null,
      //     namePrefix: null,
      //     manufacturerData: null,
      //   )
      // ], keepRepeatedDevices: true, acceptAllAdvertisements: true));
      setState(() {
        device = whot;
      });
    } catch (e) {
      print(e);
    }
  }
}
