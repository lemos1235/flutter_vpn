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
import 'flutter_vpn_platform_interface.dart';
import 'state.dart';

class FlutterVpn {
  /// Receive state change from VPN service.
  ///
  /// Can only be listened once. If have more than one subscription, only the
  /// last subscription can receive events.
  static Stream<FlutterVpnState> get onStateChanged => FlutterVpnPlatform.instance.onStateChanged;

  /// Get current state.
  static Future<FlutterVpnState> get currentState => FlutterVpnPlatform.instance.currentState;

  /// Prepare for vpn connection. (Android only)
  ///
  /// For first connection it will show a dialog to ask for permission.
  /// When your connection was interrupted by another VPN connection,
  /// you should prepare again before reconnect.
  static Future<bool> prepare() => FlutterVpnPlatform.instance.prepare();

  /// Check if vpn connection has been prepared. (Android only)
  static Future<bool> get prepared => FlutterVpnPlatform.instance.prepared;

  /// Disconnect and stop VPN service.
  static Future<void> disconnect() => FlutterVpnPlatform.instance.disconnect();

  /// Connect to VPN.
  ///
  /// This will create a background VPN service.
  /// MTU is only available on android.
  static Future<void> connect({
    required String proxy,
    int? mtu,
    String? allowedApps,
    String? disallowedApps,
  }) =>
      FlutterVpnPlatform.instance.connect(
        proxy: proxy,
        mtu: mtu,
        allowedApps: allowedApps,
        disallowedApps: disallowedApps,
      );

  /// Switch VPN service's proxy.
  static Future<void> switchProxy({
    required String proxy,
  }) =>
      FlutterVpnPlatform.instance.switchProxy(
        proxy: proxy,
      );
}
