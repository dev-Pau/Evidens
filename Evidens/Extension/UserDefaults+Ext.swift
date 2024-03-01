//
//  UserDefaults+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// An extension of UserDefaults.
extension UserDefaults {
    
    /// Resets the user defaults to their default values.
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            let report = getReports()
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
            UserDefaults.standard.setValue(report, forKey: "reports")
        }
    }
    
    /// Logs the user in by setting authentication status and theme state in UserDefaults.
    static func logUserIn() {
        UserDefaults.standard.set(true, forKey: "auth")
    }
    
    /// Checks if the user is logged in based on the presence of a user ID and authentication status.
    /// - Returns: A boolean indicating whether the user is logged in.
    static func checkIfUserIsLoggedIn() -> Bool {
        guard let _ = getUid() else {
            return false
        }
        
        return getAuth()
    }
}

extension UserDefaults {
    
    /// Retrieves the user ID from UserDefaults.
    /// - Returns: The user ID if available, otherwise nil.
    static func getUid() -> String? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            return nil
        }
        
        return uid
    }
    
    /// Retrieves the authentication status from UserDefaults.
    /// - Returns: The authentication status. Returns false if the status is not available in UserDefaults.
    static func getAuth() -> Bool {
        guard let auth = UserDefaults.standard.value(forKey: "auth") as? Bool else {
            return false
        }
        
        return auth
    }
    
    static func getUsername() -> String? {
        return UserDefaults.standard.value(forKey: "username") as? String
    }
    
    static func getImage() -> String? {
        return UserDefaults.standard.value(forKey: "profileUrl") as? String
    }
    
    /// Retrieves the user phase from UserDefaults.
    /// - Returns: The user phase. Returns nil if the phase is not available in UserDefaults.
    static func getPhase() -> UserPhase? {
        if let data = UserDefaults.standard.data(forKey: "phase"),
           let decodedPhase = try? JSONDecoder().decode(UserPhase.self, from: data) {
            return decodedPhase
        }
        
        return nil
    }
    
    static func deactivate() {
        let encodedData = try? JSONEncoder().encode(UserPhase.deactivate)
        UserDefaults.standard.set(encodedData, forKey: "phase")
        print("deactivate")
    }
    
    /// Retrieves the user phase from UserDefaults.
    /// - Returns: The user phase. Returns nil if the phase is not available in UserDefaults.
    static func getReports() -> Bool {
        guard let reports = UserDefaults.standard.value(forKey: "reports") as? Bool else {
            return true
        }
        
        return reports
    }
}
