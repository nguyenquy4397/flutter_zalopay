package com.example.flutter_zalopay

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import vn.zalopay.sdk.Environment
import vn.zalopay.sdk.ZaloPayError
import vn.zalopay.sdk.ZaloPaySDK
import vn.zalopay.sdk.listeners.PayOrderListener


/** FlutterZalopayPlugin */
class FlutterZalopayPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var activity: Activity? = null
  private var context: Context? = null

  private var appId: Int? = null
  private var uriScheme: String? = null
  private var environment: Environment = Environment.SANDBOX

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter.native/channelPayOrder")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addOnNewIntentListener(this)
    Log.d(
      "FlutterZalopayPlugin",
      "App Id Zalo: $appId"
    )
    Log.d(
      "FlutterZalopayPlugin",
      "Environment: $environment"
    )
    Log.d(
      "FlutterZalopayPlugin",
      "Uri Scheme: $uriScheme"
    )
    ZaloPaySDK.init(appId!!, environment)
  }

  override fun onNewIntent(intent: Intent?): Boolean {
    ZaloPaySDK.getInstance().onResult(intent)
    return true
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (result.method) {
      "payOrder" -> {
        val tagSuccess = "[OnPaymentSucceeded]"
        val tagError = "[onPaymentError]"
        val tagCanel = "[onPaymentCancel]"
        val token = call.argument<String>("zptoken")
        ZaloPaySDK.getInstance().payOrder(activity!!, token!!, uriScheme!!,object: PayOrderListener {
          override fun onPaymentCanceled(zpTransToken: String?, appTransID: String?) {
            Log.d(tagCanel, String.format("[TransactionId]: %s, [appTransID]: %s", zpTransToken, appTransID))
            result.success(2)
          }

          override fun onPaymentError(zaloPayErrorCode: ZaloPayError?, zpTransToken: String?, appTransID: String?) {
            Log.d(tagError, String.format("[zaloPayErrorCode]: %s, [zpTransToken]: %s, [appTransID]: %s", zaloPayErrorCode.toString(), zpTransToken, appTransID))
            if (zaloPayErrorCode == ZaloPayError.PAYMENT_APP_NOT_FOUND) {
              ZaloPaySDK.getInstance().navigateToZaloPayOnStore(activity!!.applicationContext)
            } else {
              result.success(-1)
            }
          }

          override fun onPaymentSucceeded(transactionId: String, transToken: String, appTransID: String?) {
            Log.d(tagSuccess, String.format("[TransactionId]: %s, [TransToken]: %s, [appTransID]: %s", transactionId, transToken, appTransID))
            result.success(1)
          }
        })
      }

      "init" -> {
        appId = call.argument<Int>("appId")
        uriScheme = call.argument<String>("uriScheme")
        val environmentArgument = call.argument<String>("environment")
        if (environmentArgument == "PRODUCTION") {
          environment = Environment.PRODUCTION
        }
        result.success("Init success")
      }

      else -> {
        Log.d("[METHOD CALLER] ", "Method Not Implemented")
        result.success("Payment failed")
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivity() {}
}
