package com.finpath.finpath

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity: FlutterActivity() {
    private val SMS_CHANNEL = "com.finpath.messages"
    private val PYTHON_CHANNEL = "com.finpath.python"
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- PYTHON CHANNEL ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PYTHON_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "runInsights") {
                try {
                    if (!Python.isStarted()) {
                        Python.start(AndroidPlatform(this))
                    }
                    val py = Python.getInstance()
                    val module = py.getModule("insights_engine")
                    
                    val txJson = call.argument<String>("transactions")
                    val cash = call.argument<Number>("physicalCash")?.toDouble() ?: 0.0
                    
                    val pyResult = module.callAttr("calculate_on_device", txJson, cash).toString()
                    result.success(pyResult)
                } catch (e: Exception) {
                    result.error("PY_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        // --- SMS CHANNEL ---
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    if (smsReceiver != null) {
                        try {
                            unregisterReceiver(smsReceiver)
                        } catch (e: Exception) {
                            // Already unregistered
                        }
                    }

                    smsReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                                for (sms in messages) {
                                    val data = mapOf(
                                        "sender" to (sms.displayOriginatingAddress ?: ""),
                                        "message" to (sms.displayMessageBody ?: "")
                                    )
                                    events?.success(data)
                                }
                            }
                        }
                    }
                    registerReceiver(smsReceiver, IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterSmsReceiver()
                }
            }
        )
    }

    private fun unregisterSmsReceiver() {
        if (smsReceiver != null) {
            try {
                unregisterReceiver(smsReceiver)
            } catch (e: Exception) {
                // Ignore
            }
            smsReceiver = null
        }
    }

    override fun detachFromFlutterEngine() {
        unregisterSmsReceiver()
        super.detachFromFlutterEngine()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        unregisterSmsReceiver()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
