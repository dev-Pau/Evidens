//
//  AuthCredentials.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/7/23.
//

import Foundation

/// The model for AuthCredentials
struct AuthCredentials {
    var phase: UserPhase
    
    private(set) var email: String?
    var password: String?
    var uid: String?
    private(set) var firstName: String?
    private(set) var lastName: String?
    private(set) var imageUrl: String?

    var kind: UserKind?
    var discipline: Discipline?
    var speciality: Speciality?

    init(email: String? = nil, password: String? = nil, phase: UserPhase, firstName: String? = nil, lastName: String? = nil, uid: String? = nil) {
        self.email = email
        self.password = password
        self.phase = phase
        self.firstName = firstName
        self.lastName = lastName
        self.uid = uid
    }
    
    init(uid: String, phase: UserPhase, kind: UserKind, discipline: Discipline, speciality: Speciality) {
        self.uid = uid
        self.phase = phase
        self.kind = kind
        self.discipline = discipline
        self.speciality = speciality
    }
    
    init(uid: String, firstName: String, lastName: String, phase: UserPhase) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.phase = phase
    }
    
    mutating func set(firstName: String) {
        self.firstName = firstName
    }
    mutating func set(lastName: String) {
        self.lastName = lastName
    }
    
    mutating func set(email: String) {
        self.email = email
    }
    
    mutating func set(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}
