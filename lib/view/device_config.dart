import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DeviceConfig extends StatefulWidget {
  const DeviceConfig(
      {super.key, required this.title, required this.deviceAdress});

  final String title;
  final String deviceAdress;
  @override
  State<DeviceConfig> createState() => _DeviceConfigState();
}

class _DeviceConfigState extends State<DeviceConfig> {
  late BluetoothConnection conn;
  String _waitStatus = "Loading...";
  Color _waitColor = Colors.black;
  String _txtButtonReload = "Reload";
  _DeviceConfigState();
  bool get isConnected => (conn.isConnected);

  bool _hide = true;
  final _formKey = GlobalKey<FormState>();
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _connect() async {
    try {
      conn = await BluetoothConnection.toAddress(widget.deviceAdress);
      const SnackBar(content: Text('Connected'));
      setState(() {
        _waitStatus = "Connected";
        _waitColor = Colors.green;
        _txtButtonReload = "Reload";
      });
    } catch (exception) {
      try {
        if (isConnected) {
          const SnackBar(content: Text('Already Connected'));
          setState(() {
            _waitStatus = "Connected";
            _waitColor = Colors.green;
            _txtButtonReload = "Reload";
          });
        } else {
          const SnackBar(content: Text('Can\'t connect'));
          setState(() {
            _waitStatus = "No connection";
            _waitColor = Colors.green;
            _txtButtonReload = "Retry";
          });
        }
      } catch (e) {
        print('Initializing');
      }
    }
  }

  void waitLoading() {
    setState(() {
      _waitStatus = "Loading...";
      _waitColor = Colors.black;
      _txtButtonReload = "Reload";
    });
  }

  void _reloadOrCheck() {
    waitLoading();
    _connect();
  }

  void _toogleHide() {
    setState(() {
      _hide = !_hide;
    });
  }

  Future<void> _sendData(String ssid, String password) async {
    Map<String, String> data = {'ssid': ssid, 'password': password};
    String jsonData = jsonEncode(data);
    conn.output.add(Uint8List.fromList(utf8.encode(jsonData)));
    await conn.output.allSent;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Connect to WiFi Network',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w600)),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please, fill the field';
                }
                return null;
              },
              decoration: const InputDecoration(
                  labelText: 'WiFi name / SSID',
                  border: OutlineInputBorder()),
              controller: ssidController,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please, fill the field';
                }
                return null;
              },
              obscureText: _hide,
              decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffix: InkWell(
                    onTap: _toogleHide,
                    child: const Icon(Icons.visibility),
                  )),
              controller: passwordController,
            ),
            ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendData(ssidController.text, passwordController.text);
                  }
                },
                child: const Text('Connect to WiFi')),
                SizedBox(
                      width: 100.0,
                      child: ElevatedButton(
                        onPressed: _reloadOrCheck,
                        child: Text(
                          _txtButtonReload,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
