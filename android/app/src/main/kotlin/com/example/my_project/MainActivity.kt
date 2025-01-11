package com.wlanpi.wlanpiapp

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.nsd.NsdManager
import android.net.nsd.NsdServiceInfo
import android.os.Build
import android.os.Handler
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
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "network_interface_binding"
    private var connectivityManager: ConnectivityManager? = null
    private val executor = Executors.newSingleThreadExecutor()
    private var ip: String? = null
    private var isRequestingNetwork = false
    private var activeNetwork: Network? = null
    private var activeNetworkCallback: ConnectivityManager.NetworkCallback? = null
    private var nsdManager: NsdManager? = null
    private var httpServiceInfo: NsdServiceInfo? = null
    private var sshServiceInfo: NsdServiceInfo? = null
    private var resultHandled = false
    private val activeConnections = mutableListOf<HttpURLConnection>()
    val PRIVATE_MODE = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "connectToDevice" -> {
                    connectToDevice(result)
                }
                "disconnectFromDevice" -> {
                    disconnectFromDevice(result)
                }
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
    private fun connectToDevice(result: MethodChannel.Result) {
        findBestConnection { transportType, ipAddress ->
            if (transportType == null || ipAddress == null) {
                if (!resultHandled) {
                    result.error("NETWORK_FAILED", "No suitable transport type found.", null)
                    resultHandled = true
                }
                return@findBestConnection
            }

            ip = ipAddress

            Log.d("Network", "Transport type: $transportType")
            Log.d("Network", "IP Address: $ip")

            connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager

            if (activeNetwork != null) {
                Log.d("Network", "Already Connected")
                connectivityManager?.bindProcessToNetwork(activeNetwork)
                val json = JSONObject()
                json.put("message", "Connected")
                json.put("ip", ip)

                result.success(json.toString())
            } else {
                val networkRequest =
                        NetworkRequest.Builder()
                                .addTransportType(
                                        when (transportType) {
                                            "USB OTG" -> NetworkCapabilities.TRANSPORT_ETHERNET
                                            "Bluetooth" -> NetworkCapabilities.TRANSPORT_BLUETOOTH
                                            else -> NetworkCapabilities.TRANSPORT_WIFI
                                        }
                                )
                                .build()

                val networkCallback =
                        object : ConnectivityManager.NetworkCallback() {
                            override fun onAvailable(network: Network) {
                                super.onAvailable(network)
                                Log.d("Network", "Network available: $network")
                                activeNetwork = network
                                activeNetworkCallback = this
                                val json = JSONObject()
                                json.put("message", "Connected")
                                json.put("ip", ip)

                                result.success(json.toString())
                            }

                            override fun onUnavailable() {
                                super.onUnavailable()
                                Log.e("Network", "network unavailable")
                                if (!resultHandled) {
                                    result.error("NETWORK_UNAVAILABLE", "network unavailable", null)
                                    resultHandled = true
                                }
                            }

                            override fun onLost(network: Network) {
                                super.onLost(network)
                                Log.e("Network", "Network connection lost")

                                doDisconnect()

                                runOnUiThread {
                                    flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                                        MethodChannel(messenger, CHANNEL)
                                                .invokeMethod("onNetworkDisconnected", null)
                                    }
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
                        if (!resultHandled) {
                            result.error(
                                    "NETWORK_REQUEST_FAILED",
                                    "Failed to request network",
                                    e.localizedMessage
                            )
                            resultHandled = true
                        }
                    }
                } else {
                    Log.d("Network", "Network callback already registered")
                }
                Log.d("WebView Binding", "Attempting to bind network for WebView")
                connectivityManager?.bindProcessToNetwork(activeNetwork)
                Log.d("WebView Binding", "Bound network for WebView")
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun disconnectFromDevice(result: MethodChannel.Result) {
        if (activeNetworkCallback != null) {
            doDisconnect()
            result.success("Disconnected")
        } else {
            result.error("DISCONNECT_FAILED", "No active network to disconnect", null)
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun doDisconnect() {
        connectivityManager?.bindProcessToNetwork(null)
        Log.d("WebView Binding", "Unbound network for WebView")

        // Terminate active connections
        synchronized(activeConnections) {
            for (connection in activeConnections) {
                try {
                    connection.disconnect()
                    Log.d("Network", "Disconnected active connection")
                } catch (e: Exception) {
                    Log.e("Network", "Error disconnecting active connection", e)
                }
            }
            activeConnections.clear()
        }

        cleanupNetworkRequest(activeNetworkCallback!!)
        activeNetworkCallback = null
        activeNetwork = null
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun findBestConnection(completion: (String?, String?) -> Unit) {
        val mPrefs = getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)
        val customTransportType = mPrefs.getBoolean("flutter.useCustomTransport", false)
        val transportSetting = mPrefs.getString("flutter.transportType", "")

        if (customTransportType) {
            when (transportSetting) {
                "USB OTG" -> {
                    ip = getWiredEthernetInterfaceIP()
                    completion("USB OTG", ip)
                    return
                }
                "Bluetooth" -> {
                    ip = mPrefs.getString("flutter.bluetoothIpAddress", "169.254.43.1")
                    completion("Bluetooth", ip)
                    return
                }
                "LAN" -> {
                    ip = mPrefs.getString("flutter.LANIpAddress", null)
                    completion("LAN", ip)
                    return
                }
                else -> {
                    Log.d("Network", "Unknown custom transport type")
                    completion(null, null)
                    return
                }
            }
        }

        nsdManager = getSystemService(NSD_SERVICE) as NsdManager

        val serviceListener =
                object : NsdManager.DiscoveryListener {
                    override fun onDiscoveryStarted(regType: String) {
                        Log.d("Network", "Service discovery started")
                    }

                    override fun onServiceFound(service: NsdServiceInfo) {
                        Log.d("Network", "Service discovery success: $service")
                        if (service.serviceType == "_http._tcp.") {
                            nsdManager?.resolveService(
                                    service,
                                    object : NsdManager.ResolveListener {
                                        override fun onResolveFailed(
                                                serviceInfo: NsdServiceInfo,
                                                errorCode: Int
                                        ) {
                                            Log.e("Network", "Resolve failed: $errorCode")
                                        }

                                        override fun onServiceResolved(
                                                serviceInfo: NsdServiceInfo
                                        ) {
                                            val txtRecords = serviceInfo.attributes
                                            val model = txtRecords["model"]?.toString()
                                            if (model?.startsWith("WLAN Pi") == true) {
                                                val ipAddress = serviceInfo.host.hostAddress
                                                val port = serviceInfo.port
                                                Log.d(
                                                        "Network",
                                                        "WLAN Pi found at $ipAddress:$port"
                                                )
                                                completion("WLAN Pi Service", ipAddress)
                                            } else {
                                                Log.d(
                                                        "Network",
                                                        "Non-target service found: ${serviceInfo.serviceName}"
                                                )
                                            }
                                        }
                                    }
                            )
                        }
                    }

                    override fun onServiceLost(service: NsdServiceInfo) {
                        Log.e("Network", "service lost: $service")
                    }

                    override fun onDiscoveryStopped(serviceType: String) {
                        Log.i("Network", "Discovery stopped: $serviceType")
                    }

                    override fun onStartDiscoveryFailed(serviceType: String, errorCode: Int) {
                        Log.e("Network", "Discovery failed: Error code:$errorCode")
                        nsdManager?.stopServiceDiscovery(this)
                    }

                    override fun onStopDiscoveryFailed(serviceType: String, errorCode: Int) {
                        Log.e("Network", "Discovery failed: Error code:$errorCode")
                        nsdManager?.stopServiceDiscovery(this)
                    }
                }

        nsdManager?.discoverServices("_http._tcp.", NsdManager.PROTOCOL_DNS_SD, serviceListener)

        // Timeout for Bonjour browsing
        val handler = Handler()
        handler.postDelayed(
                {
                    Log.d("Network", "NSD timeout reached. Falling back to manual connection.")
                    nsdManager?.stopServiceDiscovery(serviceListener)
                    findTransportConnection(completion)
                },
                5000
        )
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun findTransportConnection(completion: (String?, String?) -> Unit) {
        val connectivityManager = getSystemService(CONNECTIVITY_SERVICE) as ConnectivityManager
        val networks = connectivityManager.allNetworks

        val mPrefs = getSharedPreferences("FlutterSharedPreferences", PRIVATE_MODE)

        for (network in networks) {
            val networkCapabilities = connectivityManager.getNetworkCapabilities(network)

            if (networkCapabilities != null) {
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    Log.d("NetworkCheck", "Using Ethernet transport")
                    ip = getWiredEthernetInterfaceIP()
                    completion("USB OTG", ip)
                    return
                }
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH)) {
                    Log.d("NetworkCheck", "Using Bluetooth transport")
                    ip = mPrefs.getString("flutter.bluetoothIpAddress", "169.254.43.1")
                    completion("Bluetooth", ip)
                    return
                }
                if (networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                    Log.d("NetworkCheck", "Using LAN transport")
                    ip = mPrefs.getString("flutter.LANIpAddress", null)
                    completion("LAN", ip)
                    return
                }
            }
        }
        Log.d("NetworkCheck", "No suitable transport type found")
        completion(null, null)
    }

    private fun getWiredEthernetInterfaceIP(): String? {
        val interfaces = java.net.NetworkInterface.getNetworkInterfaces()
        for (networkInterface in interfaces) {
            if (networkInterface.name.startsWith("en")) {
                val addresses = networkInterface.inetAddresses
                for (address in addresses) {
                    if (!address.isLoopbackAddress) {
                        return address.hostAddress
                    }
                }
            }
        }
        return null
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
                synchronized(activeConnections) { activeConnections.add(connection) }
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
                if (!resultHandled) {
                    result.error("NETWORK_ERROR", "Error performing request", e.localizedMessage)
                    resultHandled = true
                }
            } finally {
                connection?.disconnect()
                synchronized(activeConnections) { activeConnections.remove(connection) }
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
        if (activeNetwork != null) {
            Log.d("Network", "Reusing active network")
            performRequest(activeNetwork!!, port, endpoint, method, result)
        } else {
            Log.e("Network", "Network uninitialized.")
            result.error("NETWORK_ERROR", "Network not initialised", null)
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
