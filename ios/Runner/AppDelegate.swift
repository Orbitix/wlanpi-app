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
            } else if call.method == "connectToDevice" {
                networkHandler.connectToDevice(result: result)
            } else if call.method == "disconnectFromDevice" {
                networkHandler.disconnectFromDevice(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
