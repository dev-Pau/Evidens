//
//  NetworkMonitor.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/23.
//

import Foundation
import Network

protocol NetworkMonitorDelegate: AnyObject {
    func connectionStatusChanged(connected: Bool)
}

/// A singleton class responsible for monitoring the network connectivity in the app.
class NetworkMonitor {
    weak var delegate: NetworkMonitorDelegate?
    
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private var isFirstMonitor: Bool = true
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            
            guard !strongSelf.isFirstMonitor else {
                strongSelf.isFirstMonitor.toggle()
                return
            }
            
            if path.status == .satisfied {
                strongSelf.delegate?.connectionStatusChanged(connected: true)
            } else {
                strongSelf.delegate?.connectionStatusChanged(connected: false)
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
