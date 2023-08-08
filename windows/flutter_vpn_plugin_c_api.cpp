#include "include/flutter_vpn/flutter_vpn_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_vpn_plugin.h"

void FlutterVpnPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_vpn::FlutterVpnPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
