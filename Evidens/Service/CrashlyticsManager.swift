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
    
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func addLog(withMessage message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func sendNonFatal(withError error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
