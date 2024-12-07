package com.wlanpi.wlanpiapp

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
    private var transportType: Int? = null
    private var ip: String? = null
    private var isRequestingNetwork = false
    private var activeNetwork: Network? = null
    private var activeNetworkCallback: ConnectivityManager.NetworkCallback? = null
    var PRIVATE_MODE = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "connectToEndpoint" -> {
                    val port = call.argument<String>("port")
                    val endpoint = call.argument<String>("endpoint")
                    val method = call.argument<String>("method")

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        if (port != null && endpoint != null && method != null) {
                            connectToEndpoint(port, endpoint, method, result)
                        } else {
                            result.error(
                                    "INVALID_ARGUMENT",
                                    "Endpoint or method argument is missing",
                                    null
                            )
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

        // Get the currently active network
        val activeNetwork = connectivityManager.activeNetwork
        if (activeNetwork != null) {
            val networkCapabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
            if (networkCapabilities != null) {
                when {
                    networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> {
                        Log.d("NetworkCheck", "Using Ethernet transport")
                        return NetworkCapabilities.TRANSPORT_ETHERNET
                    }
                    networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_USB) -> {
                        Log.d("NetworkCheck", "Using USB transport")
                        return NetworkCapabilities.TRANSPORT_USB
                    }
                    networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) -> {
                        Log.d("NetworkCheck", "Using Bluetooth transport")
                        return NetworkCapabilities.TRANSPORT_BLUETOOTH
                    }
                }
            } else {
                Log.d("NetworkCheck", "NetworkCapabilities is null for the active network")
            }
        } else {
            Log.d("NetworkCheck", "No active network")
        }
        return null // No suitable transport type found
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun setIPAddress() {
        val mPrefs = getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)

        if (transportType == NetworkCapabilities.TRANSPORT_ETHERNET) {
            ip = mPrefs.getString("flutter.otgIpAddress", "169.254.42.1")
        } else if (transportType == NetworkCapabilities.TRANSPORT_USB) {
            ip = mPrefs.getString("flutter.otgIpAddress", "169.254.42.1")
        } else if (transportType == NetworkCapabilities.TRANSPORT_BLUETOOTH) {
            ip = mPrefs.getString("flutter.bluetoothIpAddress", "169.254.43.1")
        } else {
            Log.d("NetworkCheck", "No IP address found for transport type: $transportType")
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun performRequest(
            network: Network,
            port: String,
            endpoint: String,
            method: String,
            result: MethodChannel.Result
    ) {
        executor.execute {
            var connection: HttpURLConnection? = null
            try {
                val fullURL = "http://${ip}:${port}${endpoint}"
                Log.d("Network", "Performing request: $fullURL")
                val url = URL(fullURL)
                connection = network.openConnection(url) as HttpURLConnection
                connection.requestMethod = method
                val responseCode = connection.responseCode
                val response =
                        BufferedReader(InputStreamReader(connection.inputStream)).use {
                            it.readText()
                        }

                if (responseCode == 200) {
                    result.success(response)
                } else {
                    result.error("HTTP_ERROR", "HTTP error code: $responseCode", null)
                }
            } catch (e: Exception) {
                Log.e("Network", "Error performing request", e)
                // result.error("NETWORK_ERROR", "Error performing request", e.localizedMessage)
            } finally {
                connection?.disconnect()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun connectToEndpoint(
            port: String,
            endpoint: String,
            method: String,
            result: MethodChannel.Result
    ) {
        val mPrefs = getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)
        val customTransportType = mPrefs.getBoolean("flutter.useCustomTransport", false)
        val transportSetting = mPrefs.getString("flutter.transportType", "")

        if (customTransportType) {
            transportType =
                    when (transportSetting) {
                        "Bluetooth" -> NetworkCapabilities.TRANSPORT_BLUETOOTH
                        "USB OTG" -> NetworkCapabilities.TRANSPORT_ETHERNET
                        else -> {
                            result.error(
                                    "NO_TRANSPORT",
                                    "No suitable transport type available",
                                    null
                            )
                            return
                        }
                    }
        } else {
            transportType = detectTransportType()
        }

        val currentTransportType = transportType

        setIPAddress()

        Log.d("Network", "Transport type: $currentTransportType")
        Log.d("Network", "IP Address: $ip")

        if (currentTransportType == null) {
            result.error("NETWORK_FAILED", "No suitable transport type found.", null)
            return
        }

        connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager

        if (activeNetwork != null) {
            Log.d("Network", "Reusing active network")
            performRequest(activeNetwork!!, port, endpoint, method, result)
        } else {
            val networkRequest =
                    NetworkRequest.Builder().addTransportType(currentTransportType).build()

            val networkCallback =
                    object : ConnectivityManager.NetworkCallback() {
                        override fun onAvailable(network: Network) {
                            super.onAvailable(network)
                            Log.d("Network", "Network available: $network")
                            activeNetwork = network
                            activeNetworkCallback = this
                            performRequest(network, port, endpoint, method, result)
                        }

                        override fun onUnavailable() {
                            super.onUnavailable()
                            Log.e("Network", "network unavailable")
                            result.error("NETWORK_UNAVAILABLE", "network unavailable", null)
                        }

                        override fun onLost(network: Network) {
                            super.onLost(network)
                            Log.e("Network", "Network connection lost")
                            if (network == activeNetwork) {
                                activeNetwork = null
                                activeNetworkCallback = null
                            }
                        }
                    }

            Log.d("Network", "active network callback: $activeNetworkCallback")
            if (activeNetworkCallback == null) {
                Log.d("Network", "No active callback. Requesting network")
                try {
                    connectivityManager?.requestNetwork(networkRequest, networkCallback)
                } catch (e: Exception) {
                    Log.e("Network", "Failed to request network", e)
                    result.error(
                            "NETWORK_REQUEST_FAILED",
                            "Failed to request network",
                            e.localizedMessage
                    )
                }
            } else {
                Log.d("Network", "Network callback already registered")
            }
        }
    }

    private fun cleanupNetworkRequest(callback: ConnectivityManager.NetworkCallback) {
        Log.d("Network", "Cleaning up network request")
        try {
            connectivityManager?.unregisterNetworkCallback(callback)
        } catch (e: Exception) {
            Log.e("Network", "Error cleaning up network request", e)
        }
    }
}
