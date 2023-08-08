#include "flutter_vpn_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

//extern "C" {
//#include "leaf.h"
//}

namespace flutter_vpn {

  // static
  void FlutterVpnPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
    auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "flutter_vpn",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<FlutterVpnPlugin>();

    channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

    registrar->AddPlugin(std::move(plugin));
  }

  FlutterVpnPlugin::FlutterVpnPlugin() {}

  FlutterVpnPlugin::~FlutterVpnPlugin() {}

  void FlutterVpnPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (method_call.method_name().compare("connect") == 0) {
      //leaf_run(0, "config.conf");
      result->Success(flutter::EncodableValue(true));
    }
    else {
      result->NotImplemented();
    }
  }

}  // namespace flutter_vpn
