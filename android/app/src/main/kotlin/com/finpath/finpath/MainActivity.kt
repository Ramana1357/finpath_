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

        // We open a continuous stream to Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

                    // Create the native Android SMS listener
                    smsReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context, intent: Intent) {
                            if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                                for (sms in messages) {
                                    // Package the sender and message into a map
                                    val data = mapOf(
                                        "sender" to (sms.displayOriginatingAddress ?: ""),
                                        "message" to (sms.displayMessageBody ?: "")
                                    )
                                    // Throw the data over the bridge to Flutter!
                                    events?.success(data)
                                }
                            }
                        }
                    }
                    // Start listening!
                    registerReceiver(smsReceiver, IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION))
                }

                override fun onCancel(arguments: Any?) {
                    // Stop listening if Flutter closes the connection
                    unregisterReceiver(smsReceiver)
                    smsReceiver = null
                }
            }
        )
    }
}