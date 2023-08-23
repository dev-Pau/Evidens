//
//  CrashlyticsManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/8/23.
//

import Foundation
import FirebaseCrashlytics

final class CrashlyticsManager {
    
    static let shared = CrashlyticsManager()
    
    private init() { }
    
    /// Set the user ID in Crashlytics to associate crash reports and analytics data with a specific user.
    ///
    /// - Parameter userId: The user ID to set.
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    /// Set a custom value in Crashlytics for a specific key to provide additional context to crash reports and analytics.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key for the custom value.
    func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    /// Add a custom log message to Crashlytics for better understanding of events leading up to crashes or issues.
    ///
    /// - Parameter message: The log message to add.
    func addLog(withMessage message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    /// Record a non-fatal error in Crashlytics for analysis and debugging purposes.
    ///
    /// - Parameter error: The non-fatal error to record.
    func sendNonFatal(withError error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
