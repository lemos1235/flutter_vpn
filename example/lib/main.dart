/// Copyright (C) 2018-2022 Jason C.H
///
/// This library is free software; you can redistribute it and/or
/// modify it under the terms of the GNU Lesser General Public
/// License as published by the Free Software Foundation; either
/// version 2.1 of the License, or (at your option) any later version.
///
/// This library is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
/// Lesser General Public License for more details.
import 'package:flutter/material.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:flutter_vpn/state.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _proxyController = TextEditingController(text: "socks://lisi:abc123@192.168.1.5:7890");

  var state = FlutterVpnState.disconnected;

  @override
  void initState() {
    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) => setState(() => state = s));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter VPN'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          children: <Widget>[
            TextFormField(
              controller: _proxyController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  isCollapsed: true,
                  filled: true,
                  fillColor: const Color(0xFFEBECF0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFEBECF0)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefixIcon: Icon(
                      state == FlutterVpnState.connected ? Icons.airplanemode_on : Icons.airplanemode_off)),
            ),
            state == FlutterVpnState.disconnected
                ? ElevatedButton(
                    onPressed: () => FlutterVpn.connect(proxy: _proxyController.text),
                    child: const Text('Connect'),
                  )
                : ElevatedButton(
                    onPressed: () => FlutterVpn.disconnect(),
                    child: const Text('Disconnect'),
                  ),
            ElevatedButton(
              onPressed: state != FlutterVpnState.connected
                  ? null
                  : () => FlutterVpn.switchProxy(
                        proxy: _proxyController.text,
                      ),
              child: const Text('SwitchProxy'),
            ),
            Text('State: $state'),
          ],
        ),
      ),
    );
  }
}
