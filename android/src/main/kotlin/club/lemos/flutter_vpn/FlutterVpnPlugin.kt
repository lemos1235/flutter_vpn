package club.lemos.flutter_vpn

import android.app.Activity.RESULT_OK
import android.app.Service
import android.content.ComponentName
import android.content.Intent
import android.content.ServiceConnection
import android.net.VpnService
import android.os.Bundle
import android.os.IBinder

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import club.lemos.vpn.logic.VpnStateService

class FlutterVpnPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var activityBinding: ActivityPluginBinding

    private lateinit var channel: MethodChannel

    private lateinit var eventChannel: EventChannel

    private var vpnStateService: VpnStateService? = null

    private val vpnStateServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            val vpnState = (service as VpnStateService.LocalBinder).service
            vpnState.setStateListener(VpnStateHandler);
            vpnStateService = vpnState
        }

        override fun onServiceDisconnected(name: ComponentName) {
            vpnStateService = null
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Register method channel.
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_vpn")
        channel.setMethodCallHandler(this)

        // Register event channel to handle state change.
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_vpn_states")
        eventChannel.setStreamHandler(VpnStateHandler)

        flutterPluginBinding.applicationContext.bindService(
            Intent(flutterPluginBinding.applicationContext, VpnStateService::class.java),
            vpnStateServiceConnection,
            Service.BIND_AUTO_CREATE
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "prepare" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent == null) {
                    // vpn is permitted
                    result.success(true)
                } else {
                    // grant permission
                    var listener: PluginRegistry.ActivityResultListener? = null
                    listener = PluginRegistry.ActivityResultListener { req, res, _ ->
                        result.success(req == 0 && res == RESULT_OK)
                        listener?.let { activityBinding.removeActivityResultListener(it) }
                        true
                    }
                    activityBinding.addActivityResultListener(listener)
                    activityBinding.activity.startActivityForResult(intent, 0)
                }
            }
            "prepared" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                result.success(intent == null)
            }
            "connect" -> {
                val intent = VpnService.prepare(activityBinding.activity.applicationContext)
                if (intent != null) {
                    // Not prepared yet.
                    result.success(false)
                    return
                }

                val args = call.arguments as Map<*, *>

                val profileInfo = Bundle()
                profileInfo.putString("PROXY", args["proxy"] as String)
                if (args.containsKey("mtu")) {
                    profileInfo.putInt("MTU", args["mtu"] as Int)
                }
                if (args.containsKey("allowedApps")) {
                    profileInfo.putString("allowedApps", args["allowedApps"] as String)
                }
                if (args.containsKey("disallowedApps")) {
                    profileInfo.putString("disallowedApps", args["disallowedApps"] as String)
                }

                vpnStateService?.connect(profileInfo)
                result.success(true)
            }
            "getCurrentState" -> {
                result.success(VpnStateHandler.vpnState.ordinal)
            }
            "disconnect" -> vpnStateService?.disconnect()
            "switchProxy" -> {
                val args = call.arguments as Map<*, *>
                vpnStateService?.switchProxy(args["proxy"] as String)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}
