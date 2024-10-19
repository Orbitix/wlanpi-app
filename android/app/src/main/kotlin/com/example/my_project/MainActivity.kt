package com.mycompany.wlanpiapp

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.NetworkInfo
import android.util.Log
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException


class MainActivity : FlutterActivity() {
    private val CHANNEL = "network_handler"
    private val EVENT_CHANNEL = "network_status"
    private var activeConnection: String? = null
    private var eventSink: EventChannel.EventSink? = null
    private val client = OkHttpClient() // OkHttp client for network requests

    private val connectivityReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val cm = context?.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val networkInfo: NetworkInfo? = cm.activeNetworkInfo

            if (networkInfo != null && networkInfo.isConnected) {
                eventSink?.success("Connected to ${networkInfo.typeName}")
            } else {
                eventSink?.success("No network connection")
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAndConnect" -> {
                    val otgIp = call.argument<String>("otgIpAddress")
                    val bluetoothIp = call.argument<String>("bluetoothIpAddress")
                    result.success(checkAndConnect(otgIp, bluetoothIp))
                }
                "makeNetworkRequest" -> {
                    val url = call.argument<String>("url")
                    val port = call.argument<String>("port")
                    val endpoint = call.argument<String>("endpoint")
                    val method = call.argument<String>("method")

                    // Call the method to make the network request
                    try {
                        val responseJson = makeNetworkRequest(url, port, endpoint, method)
                        result.success(responseJson)
                    } catch (e: Exception) {
                        result.error("NETWORK_ERROR", "Failed to make network request: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerReceiver(connectivityReceiver, IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION))
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver(connectivityReceiver)
                    eventSink = null
                }
            }
        )
    }

    private fun checkAndConnect(otgIp: String?, bluetoothIp: String?): String? {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork
        val capabilities = cm.getNetworkCapabilities(network)

        capabilities?.let {
            if (it.hasTransport(NetworkCapabilities.TRANSPORT_USB)) {
                activeConnection = "http://$otgIp"
            } else if (it.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
                activeConnection = "http://$bluetoothIp"
            }
        }

        return activeConnection
    }

    private fun makeNetworkRequest(url: String?, port: String?, endpoint: String?, method: String?): String {
        val fullUrl = "$url:$port$endpoint"
        val requestBuilder = Request.Builder()
            .url(fullUrl)
    
        when (method?.toUpperCase()) {
            "GET" -> requestBuilder.get()
            "POST" -> requestBuilder.post("{}".toRequestBody("application/json".toMediaTypeOrNull())) // Use your actual body if needed
            // Handle other HTTP methods as necessary
        }
    
        val request = requestBuilder.build()
        return client.newCall(request).execute().use { response: Response ->
            if (!response.isSuccessful) throw IOException("Unexpected code $response")
            response.body?.string() ?: "{}" // Return an empty JSON object if body is null
        }
    }
    

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(connectivityReceiver)
    }
}
