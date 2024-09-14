package com.mycompany.wlanpiapp

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "network_interface_binding"
    private var connectivityManager: ConnectivityManager? = null
    private val executor = Executors.newSingleThreadExecutor()
    private var isRequestingNetwork = false
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToEndpoint" -> {
                    val endpoint = call.argument<String>("endpoint")
                    val method = call.argument<String>("method")

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        if (endpoint != null && method != null) {
                            if (!isRequestingNetwork) {
                                connectToEndpoint(endpoint, method, result)
                            } else {
                                result.error("TOO_MANY_REQUESTS", "A network request is already in progress", null)
                            }
                        } else {
                            result.error("INVALID_ARGUMENT", "Endpoint or method argument is missing", null)
                        }
                    } else {
                        result.error("UNSUPPORTED_VERSION", "Android version not supported", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun connectToEndpoint(endpoint: String, method: String, result: MethodChannel.Result) {
        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkRequest = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_BLUETOOTH) // Ensure this is appropriate
            .build()

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                super.onAvailable(network)
                Log.d("Network", "Network available")
                executor.execute {
                    try {
                        val url = URL(endpoint)
                        val connection = network.openConnection(url) as HttpURLConnection
                        connection.requestMethod = method
                        val responseCode = connection.responseCode
                        val response = BufferedReader(InputStreamReader(connection.inputStream)).use { it.readText() }
                        if (responseCode == 200) {
                            result.success(response)
                        } else {
                            result.error("HTTP_ERROR", "HTTP error code: $responseCode", null)
                        }
                    } catch (e: Exception) {
                        Log.e("Network", "Error accessing API", e)
                        result.error("NETWORK_ERROR", "Error accessing API", e.localizedMessage)
                    } finally {
                        isRequestingNetwork = false
                        // cleanupNetworkRequest()
                    }
                }
            }

            override fun onUnavailable() {
                super.onUnavailable()
                Log.e("Network", "Bluetooth PAN network unavailable")
                result.error("NETWORK_UNAVAILABLE", "Bluetooth PAN network unavailable", null)
                isRequestingNetwork = false
                cleanupNetworkRequest()
            }

            override fun onLost(network: Network) {
                super.onLost(network)
                Log.e("Network", "Network lost")
                result.error("NETWORK_LOST", "Network connection lost", null)
                isRequestingNetwork = false
                cleanupNetworkRequest()
            }
        }

        isRequestingNetwork = true
        try {
            connectivityManager?.requestNetwork(networkRequest, networkCallback!!)
        } catch (e: Exception) {
            Log.e("Network", "Failed to request network", e)
            result.error("NETWORK_REQUEST_FAILED", "Failed to request network", e.localizedMessage)
            isRequestingNetwork = false
            cleanupNetworkRequest()
        }
    }

    private fun cleanupNetworkRequest() {
        networkCallback?.let {
            connectivityManager?.unregisterNetworkCallback(it)
        }
        networkCallback = null
    }
}
