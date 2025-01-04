//
//  NetworkHandler.swift
//  Runner
//
//  Created by Ben Toner on 20/12/2024.
//

import Foundation
import Network
import SystemConfiguration

class NetworkHandler: NSObject {
    struct ConnectionDetails{
        var transportType: String = "None"
        var ipAddress: String = "None"
    }
    
    static let shared = NetworkHandler()
    private var activeServices: [NetService] = []

    private var session: URLSession? = URLSession.shared
    private let monitor = NWPathMonitor()
    private var httpBrowser: NetServiceBrowser?
    private var sshBrowser: NetServiceBrowser?
    private var bestTransportType: String?
    private var bonjourTimeoutWorkItem: DispatchWorkItem?
    private var connectionDetails = ConnectionDetails()
    private var completionHandler: ((String?, String?) -> Void)?
    
    private var isConnected: Bool = false
    
    // Lazy initialization for URLSession
    private func getSession() -> URLSession {
        if session == nil {
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration)
        }
        return session!
    }
    
    func disconnectFromDevice(result: @escaping FlutterResult) {
        if self.connectionDetails.transportType != "None" {
            // Remove the existing connection
            self.connectionDetails = ConnectionDetails()
            result("Disconnected")
        }
    }
    
    func connectToDevice(result: @escaping FlutterResult) {
        if self.connectionDetails.transportType != "None" {
            // Use existing session and connection details
        } else {
            // No session or connection details, find the best connection first
            findBestConnection { transportType, ipAddress in
                if let transportType, let ipAddress {
                    self.connectionDetails.transportType = transportType
                    self.connectionDetails.ipAddress = ipAddress
                    
                    result("Connected to \(ipAddress)")
                    self.isConnected = true
                } else {
                    result(FlutterError(code: "INVALID_URL", message: "Invalid IP address or URL", details: nil))
                }
            }
        }
    }

    func connectToEndpoint(port: String, endpoint: String, method: String, result: @escaping FlutterResult) {
        if self.connectionDetails.transportType != "None" {
            // Use existing session and connection details
            performRequest(port: port, endpoint: endpoint, method: method, transportType: connectionDetails.transportType, ipAddress: connectionDetails.ipAddress, result: result)
        }
//        else {
//            // No session or connection details, find the best connection first
//            connectToDevice(result: result)
//            if let connectionDetails = self.connectionDetails {
//                performRequest(port: port, endpoint: endpoint, method: method, transportType: connectionDetails.transportType, ipAddress: connectionDetails.ipAddress, result: result)
//                result(result)
//            }
//        }
    }

    private func performRequest(port: String, endpoint: String, method: String, transportType: String?, ipAddress: String?, result: @escaping FlutterResult) {
        guard let ip = ipAddress, let url = URL(string: "http://\(ip):\(port)\(endpoint)") else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid IP address or URL", details: nil))
            return
        }

        print("Performing request using transport type: \(transportType ?? "Unknown"), IP: \(ip) to URL: \(url.absoluteString) with method: \(method)")

        var request = URLRequest(url: url)
        request.httpMethod = method


        let task = getSession().dataTask(with: request) { data, response, error in
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

    private func findBestConnection(completion: @escaping (String?, String?) -> Void) {
        self.completionHandler = completion

        // Start Bonjour browsing for both service types
        startBonjourBrowsing()

        // Timeout for Bonjour browsing
        let queue = DispatchQueue(label: "networkhandler.browsing.queue")
        bonjourTimeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            print("Bonjour browsing timeout reached. Falling back to NWPathMonitor.")
            self.stopBonjourBrowsing()
            // Fall back to NWPathMonitor if no Bonjour service was found
            self.findTransportConnection(completion: completion)
            
        }
        queue.asyncAfter(deadline: .now() + 10, execute: bonjourTimeoutWorkItem!)
    }

    private func startBonjourBrowsing() {
        httpBrowser = NetServiceBrowser()
        sshBrowser = NetServiceBrowser()
        
        httpBrowser?.delegate = self
        sshBrowser?.delegate = self
        
        print("Starting Bonjour browsing")
        // Browse for _http._tcp.
        httpBrowser?.searchForServices(ofType: "_http._tcp.", inDomain: "local.")
        // Browse for _ssh._tcp.
        sshBrowser?.searchForServices(ofType: "_ssh._tcp.", inDomain: "local.")
    }

    private func stopBonjourBrowsing() {
        print("Stop Bonjour browsing")
        httpBrowser?.stop()
        sshBrowser?.stop()
        httpBrowser = nil
        sshBrowser = nil
        bonjourTimeoutWorkItem?.cancel()
        bonjourTimeoutWorkItem = nil
    }

    private func findTransportConnection(completion: @escaping (String?, String?) -> Void) {
        monitor.pathUpdateHandler = { path in
            print("Network path update")
            var transportType: String? = nil
            var ipAddress: String? = nil

            if path.usesInterfaceType(.wiredEthernet) {
                transportType = "USB OTG"
                ipAddress = self.getWiredEthernetInterfaceIP()
                print("Got Wired Ethernet IP \(ipAddress!)")
            } else if path.usesInterfaceType(.other) {
                transportType = "Bluetooth"
                ipAddress = UserDefaults.standard.string(forKey: "flutter.bluetoothIpAddress")
                print("Got Other Ethernet IP \(ipAddress!)")
            }

            if transportType != nil {
                print("Nil Transport found")
                self.monitor.cancel()
                completion(transportType, ipAddress)
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    private func getWiredEthernetInterfaceIP() -> String? {
        var addresses = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return nil }
        defer { freeifaddrs(ifaddr) }
        
        print("able to get interfaces IPs")

        var ptr = ifaddr
        while ptr != nil {
            guard let interface = ptr?.pointee else { break }
            let name = String(cString: interface.ifa_name)

            if name.starts(with: "en"), let addr = interface.ifa_addr {
                let addrFamily = addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if getnameinfo(
                        addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    ) == 0 {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
            ptr = ptr?.pointee.ifa_next
        }

        return addresses.first
    }
}

// MARK: - NetServiceBrowserDelegate and NetServiceDelegate

extension NetworkHandler: NetServiceBrowserDelegate, NetServiceDelegate {

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Discovered Bonjour service: \(service.name) for type: \(service.type)")
        activeServices.append(service) // Retain the service
        service.delegate = self
        service.resolve(withTimeout: 15)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved Bonjour service: \(sender.name)")
        activeServices.removeAll { $0 == sender } // Release the service
        if let hostName = sender.hostName {
            // Check criteria for matching services
            if sender.type == "_http._tcp." {
                let txtRecords = sender.decodeTXTRecord()
                if txtRecords["model"] == "WLAN Pi Go" {
                    print("Matched _http._tcp. with WLAN Pi Go model.")
                    completeBonjourResolution(hostName: hostName)
                }
            } else if sender.type == "_ssh._tcp." && sender.name.starts(with: "wlanpi") {
                print("Matched _ssh._tcp. with wlanpi instance.")
                completeBonjourResolution(hostName: hostName)
            }
        }
    }

    private func completeBonjourResolution(hostName: String) {
        print("Completed Bonjour Resolution")
        stopBonjourBrowsing()
        bonjourTimeoutWorkItem?.cancel()
        completionHandler?("Bonjour Service", hostName)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        print("Failed to search for Bonjour services: \(errorDict)")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("Failed to resolve service: \(sender.name) - Error: \(errorDict)")
    }
    
    private func extractIPAddress(from addressData: Data) -> String? {
        print("About to extract IP address")
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        
        addressData.withUnsafeBytes { ptr in
            let sockaddrPtr = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
            getnameinfo(
                sockaddrPtr,
                socklen_t(addressData.count),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )
        }
        
        let ipAddress = String(cString: hostname)
        return ipAddress.isEmpty ? nil : ipAddress
    }
}

extension NetService {
    func decodeTXTRecord() -> [String: String] {
        guard let txtData = self.txtRecordData() else { return [:] }
        let txtDict = NetService.dictionary(fromTXTRecord: txtData)
        var decodedDict: [String: String] = [:]

        for (key, value) in txtDict {
            if let stringValue = String(data: value, encoding: .utf8) {
                decodedDict[key] = stringValue
            }
        }

        return decodedDict
    }
}
