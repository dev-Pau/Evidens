//
//  AnalyticsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/23.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() { }
    
    func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
    func setUserProperty(value: String?, property: String) {
        Analytics.setUserProperty(value, forName: property)
    }
}
