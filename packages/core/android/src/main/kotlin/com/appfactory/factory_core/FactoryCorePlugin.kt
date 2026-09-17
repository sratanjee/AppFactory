package com.appfactory.factory_core

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FactoryCorePlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var symbolChannel: MethodChannel
  private lateinit var bridgeChannel: MethodChannel
  private lateinit var appContext: Context

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    symbolChannel = MethodChannel(binding.binaryMessenger, "factory_core/sf_symbol")
    symbolChannel.setMethodCallHandler(this)
    bridgeChannel = MethodChannel(binding.binaryMessenger, "factory_core/widget_bridge")
    bridgeChannel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      // SF Symbols are iOS-only; Dart falls back to cupertino_icons on Android.
      "render" -> result.success(null)

      "publish" -> {
        val suiteName = call.argument<String>("suiteName")
        val payload = call.argument<String>("payload")
        if (suiteName == null || payload == null) {
          result.error("bad_args", "Missing suiteName or payload", null)
          return
        }
        prefs(suiteName).edit().putString("payload", payload).apply()
        broadcastUpdate()
        result.success(null)
      }

      "read" -> {
        val suiteName = call.argument<String>("suiteName")
        if (suiteName == null) {
          result.error("bad_args", "Missing suiteName", null)
          return
        }
        result.success(prefs(suiteName).getString("payload", null))
      }

      "clear" -> {
        val suiteName = call.argument<String>("suiteName")
        if (suiteName == null) {
          result.error("bad_args", "Missing suiteName", null)
          return
        }
        prefs(suiteName).edit().remove("payload").apply()
        broadcastUpdate()
        result.success(null)
      }

      "reloadAllWidgets" -> {
        broadcastUpdate()
        result.success(null)
      }

      else -> result.notImplemented()
    }
  }

  private fun prefs(suiteName: String) =
    appContext.getSharedPreferences(suiteName, Context.MODE_PRIVATE)

  private fun broadcastUpdate() {
    // Widget receivers in packages/widgets_android listen for this action
    // and pull fresh data from the same SharedPreferences store on receipt.
    appContext.sendBroadcast(Intent(ACTION_UPDATE).setPackage(appContext.packageName))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    symbolChannel.setMethodCallHandler(null)
    bridgeChannel.setMethodCallHandler(null)
  }

  companion object {
    const val ACTION_UPDATE = "factory.widget.updated"
  }
}
