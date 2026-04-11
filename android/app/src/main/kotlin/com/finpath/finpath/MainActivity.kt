package com.finpath.finpath

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    // This is the name of our bridge to Flutter
    private val SMS_CHANNEL = "com.finpath.messages"
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

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
