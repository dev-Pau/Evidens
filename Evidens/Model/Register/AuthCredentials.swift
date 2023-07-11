//
//  AuthCredentials.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/7/23.
//

import Foundation

/// The model for AuthCredentials
///
struct AuthCredentials {
    var phase: User.UserRegistrationPhase
    
    var email: String?
    var password: String?
    var uid: String?
    var firstName: String?
    private(set) var lastName: String?
    var profileImageUrl: String?

    var kind: User.UserCategory?
    var discipline: String?
    var speciality: String?
    var interests: [String]?
    
    init(email: String? = nil, password: String? = nil, phase: User.UserRegistrationPhase, firstName: String? = nil, lastName: String? = nil, uid: String? = nil) {
        self.email = email
        self.password = password
        self.phase = phase
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
    }
    
    init(uid: String, phase: User.UserRegistrationPhase, kind: User.UserCategory, discipline: String, speciality: String) {
        self.phase = phase
        self.kind = kind
        self.discipline = discipline
        self.speciality = speciality
    }
    
    mutating func set(firstName: String) {
        self.firstName = lastName
    }
    mutating func set(lastName: String) {
        self.lastName = lastName
    }
    
    mutating func set(email: String) {
        self.email = email
    }
}
