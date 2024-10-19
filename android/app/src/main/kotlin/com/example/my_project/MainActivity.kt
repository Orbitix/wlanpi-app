package com.wlanpi.wlanpiapp

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Build
import android.util.Log
import android.content.SharedPreferences
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
    var PRIVATE_MODE = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToEndpoint" -> {
                    val port = call.argument<String>("port")
                    val endpoint = call.argument<String>("endpoint")
                    val method = call.argument<String>("method")

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        if (port != null && endpoint != null && method != null) {
                            if (!isRequestingNetwork) {
                                connectToEndpoint(port, endpoint, method, result)
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
    private fun detectTransportType(): Int? {
        val connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val networks = connectivityManager.allNetworks // Get all available networks

        for (network in networks) {
            val networkCapabilities = connectivityManager.getNetworkCapabilities(network)
            Log.d("NetworkCheck", "Checking network capabilities for network: $network")
            if (networkCapabilities != null) {
                Log.d("NetworkCheck", "Capabilities: $networkCapabilities")
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    Log.d("NetworkCheck", "Using Ethernet transport")
                    return NetworkCapabilities.TRANSPORT_ETHERNET // Prioritize OTG
                }
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
                    Log.d("NetworkCheck", "Using Bluetooth transport")
                    return NetworkCapabilities.TRANSPORT_BLUETOOTH // Fall back to Bluetooth
                }
            } else {
                Log.d("NetworkCheck", "NetworkCapabilities is null for network: $network")
            }
        }
        Log.d("NetworkCheck", "No suitable transport type found")
        return null // No suitable transport type found
    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun connectToEndpoint(port: String, endpoint: String, method: String, result: MethodChannel.Result) {
        // val transportType = detectTransportType() // will be implemented when automatic detection is functional. for now it is set using a dropdown on the homepage

        var transportType = NetworkCapabilities.TRANSPORT_BLUETOOTH // default transport type

        val mPrefs = getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)
        val transportSetting = mPrefs.getString("flutter.transportType", "")
        var ip = mPrefs.getString("flutter.bluetoothIpAddress", "169.254.43.1")


        when (transportSetting) {
            "Bluetooth" -> {
                Log.d("Network", "Using Bluetooth transport")
                var ip = mPrefs.getString("flutter.bluetoothIpAddress", "169.254.43.1")
                transportType = NetworkCapabilities.TRANSPORT_BLUETOOTH
            }
            "USB OTG" -> {
                Log.d("Network", "Using OTG transport")
                var ip = mPrefs.getString("flutter.otgIpAddress", "169.254.42.1")
                transportType = NetworkCapabilities.TRANSPORT_ETHERNET
            }
        }

        if (transportType == null) {
            result.error("NO_TRANSPORT", "No suitable transport type available", null)
            return
        }

        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkRequest = NetworkRequest.Builder()
            .addTransportType(transportType)
            .build()

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                super.onAvailable(network)
                Log.d("Network", "Network available")
                executor.execute {
                    try {
                        val fullURL = "http://${ip}:${port}${endpoint}"
                        Log.d("Network", "Requesting network: ${fullURL}")
                        val url = URL(fullURL)
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