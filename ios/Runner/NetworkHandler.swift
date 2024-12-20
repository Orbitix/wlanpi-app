//
//  NetworkHandler.swift
//  Runner
//
//  Created by Ben Toner on 20/12/2024.
//

import Foundation
import Network

class NetworkHandler {
    private var session: URLSession = URLSession.shared

    func connectToEndpoint(port: String, endpoint: String, method: String, result: @escaping FlutterResult) {
        let transportType = UserDefaults.standard.string(forKey: "transportType") ?? "USB OTG"
        let ipAddress = getIpAddress(for: transportType)

        guard let ip = ipAddress, let url = URL(string: "http://\(ip):\(port)\(endpoint)") else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid IP address or URL", details: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                result(FlutterError(code: "NETWORK_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                result(FlutterError(code: "NO_RESPONSE", message: "No data received", details: nil))
                return
            }

            if httpResponse.statusCode == 200 {
                let json = String(data: data, encoding: .utf8) ?? "{}"
                result(json)
            } else {
                result(FlutterError(code: "HTTP_ERROR", message: "HTTP \(httpResponse.statusCode)", details: nil))
            }
        }

        task.resume()
    }

    private func getIpAddress(for transportType: String) -> String? {
        switch transportType {
        case "Bluetooth":
//            return UserDefaults.standard.string(forKey: "bluetoothIpAddress")
            return "169.254.43.1"
        case "USB OTG":
//            return UserDefaults.standard.string(forKey: "otgIpAddress")
            return "169.254.42.1"
        default:
            return nil
        }
    }
}
