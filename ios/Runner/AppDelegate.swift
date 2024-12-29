import UIKit
import Flutter
import Network


@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "network_interface_binding", binaryMessenger: controller.binaryMessenger)
        let networkHandler = NetworkHandler()

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "connectToEndpoint" {
                guard let args = call.arguments as? [String: Any],
                      let port = args["port"] as? String,
                      let endpoint = args["endpoint"] as? String,
                      let method = args["method"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments provided", details: nil))
                    return
                }

                
                networkHandler.connectToEndpoint(port: port, endpoint: endpoint, method: method, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


//@main
//class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
//    private let CHANNEL = "network_handler"
//    private let EVENT_CHANNEL = "network_status"
//    var activeConnection: String?
//    var eventSink: FlutterEventSink?
//    
//    // Use a Network monitor instance for connection status tracking
//    let monitor = NWPathMonitor()
//
//    override func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//        let flutterViewController = window?.rootViewController as! FlutterViewController
//        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
//        let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: flutterViewController.binaryMessenger)
//
//        methodChannel.setMethodCallHandler { [weak self] (call, result) in
//            guard let self = self else { return }
//            if call.method == "checkAndConnect" {
//                if let args = call.arguments as? [String: String],
//                   let otgIp = args["otgIpAddress"],
//                   let bluetoothIp = args["bluetoothIpAddress"] {
//                    result(self.checkAndConnect(otgIp: otgIp, bluetoothIp: bluetoothIp))
//                } else {
//                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
//                }
//            } else {
//                result(FlutterMethodNotImplemented)
//            }
//        }
//
//        eventChannel.setStreamHandler(self)
//
//        monitor.start(queue: DispatchQueue.global(qos: .background))
//        
//        GeneratedPluginRegistrant.register(with: self)
//
//        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//    }
//
//    func checkAndConnect(otgIp: String, bluetoothIp: String) -> String? {
//        monitor.pathUpdateHandler = { [weak self] path in
//            guard let self = self else { return }
//
//            // If the network interface uses .other (which could include USB OTG on iOS)
//            if path.usesInterfaceType(.wiredEthernet) {
//                self.activeConnection = "https://\(otgIp)"
//                self.eventSink?("usb_otg_connected")
//            }
//            // If the network interface uses .bluetooth
//            else if path.usesInterfaceType(.other) {
//                self.activeConnection = "https://\(bluetoothIp)"
//                self.eventSink?("bluetooth_connected")
//            }
//            // No suitable connection found
//            else {
//                self.activeConnection = nil
//                self.eventSink?("no_connection")
//            }
//        }
//
//        // Return the currently active connection URL (if any)
//        return activeConnection
//    }
//
//    // MARK: - FlutterStreamHandler methods
//    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
//        self.eventSink = events
//        return nil
//    }
//
//    func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        eventSink = nil
//        return nil
//    }
//}
