//
//  UserDefaults+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

extension UserDefaults {
    
    /// Resets the user defaults to their default values.
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func logUserIn() {
        UserDefaults.standard.set(true, forKey: "auth")
        UserDefaults.standard.set(Appearance.system.rawValue, forKey: "themeStateEnum")
    }
    
    static func checkIfUserIsLoggedIn() -> Bool {
        guard let _ = getUid() else {
            return false
        }
        
        return getAuth()
    }
}

extension UserDefaults {
    
    static func getUid() -> String? {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            return nil
        }
        
        return uid
    }
    
    static func getAuth() -> Bool {
        guard let auth = UserDefaults.standard.value(forKey: "auth") as? Bool else {
            return false
        }
        
        return auth
    }
}
