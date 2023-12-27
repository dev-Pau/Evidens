//
//  AnalyticsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/23.
//

import Foundation
import FirebaseAnalytics

/// A class that manages analytics events and crash reporting using Analytics.
final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() { }
    
    /// Log a custom event with optional parameters for analytics tracking.
    ///
    /// - Parameters:
    ///   - name: The name of the event.
    ///   - params: Optional parameters associated with the event.
    func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
    /// Set the user ID in analytics to associate events and data with a specific user.
    ///
    /// - Parameter userId: The user ID to set.
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
    /// Set a user property value for analytics to track additional information about users.
    ///
    /// - Parameters:
    ///   - value: The value of the user property.
    ///   - property: The name of the user property.
    func setUserProperty(value: String?, property: String) {
        Analytics.setUserProperty(value, forName: property)
    }
}
