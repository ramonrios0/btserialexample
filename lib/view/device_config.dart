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
  String _waitStatus = "Cargando papu...";
  Color _waitColor = Colors.black;
  String _txtButtonReload = "Checkeame esta";
  _DeviceConfigState();
  bool get isConnected => (conn.isConnected);

  bool _hide = true;
  final _formKey = GlobalKey<FormState>();
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _connect() async {
    try {
      conn = await BluetoothConnection.toAddress(widget.deviceAdress);
      const SnackBar(content: Text('Conectao\''));
      setState(() {
        _waitStatus = "Conectao.";
        _waitColor = Colors.green;
        _txtButtonReload = "Checkeame esta";
      });
    } catch (exception) {
      try {
        if (isConnected) {
          const SnackBar(content: Text('Ya estai\' Conectao\''));
          setState(() {
            _waitStatus = "Conectao.";
            _waitColor = Colors.green;
            _txtButtonReload = "Checkeame esta";
          });
        } else {
          const SnackBar(content: Text('No se pudo conectar papu :('));
          setState(() {
            _waitStatus = "Sin conexión";
            _waitColor = Colors.green;
            _txtButtonReload = "Relodearme esta";
          });
        }
      } catch (e) {
        print('Iniciando...');
      }
    }
  }

  void waitLoading() {
    setState(() {
      _waitStatus = "Cargando papu...";
      _waitColor = Colors.black;
      _txtButtonReload = "Checkeame esta";
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
            const Text('Escribe el nombre de tu red WiFi',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w600)),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, rellene el campo';
                }
                return null;
              },
              decoration: const InputDecoration(
                  labelText: 'Nombre de la red / SSID',
                  border: OutlineInputBorder()),
              controller: ssidController,
            ),
            const Text('Escribe la contraseña de tu red WiFi',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    height: 1,
                    fontWeight: FontWeight.w600)),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, rellene el campo';
                }
                return null;
              },
              obscureText: _hide,
              decoration: InputDecoration(
                  labelText: 'Contraseña',
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
                child: Text('Conectar'))
          ],
        ),
      ),
    );
  }
}
