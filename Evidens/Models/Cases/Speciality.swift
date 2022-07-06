//
//  Speciality.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 5/7/22.
//

import UIKit

struct Speciality: Codable, Hashable {
    var name: String
}

extension Speciality {
    static func allSpecialities() -> [Speciality] {
        var speciality: [Speciality] = []
        
        let s1 = Speciality(name: "Phisiotherapist")
        let s2 = Speciality(name: "Nurse in the house wedding")
        speciality.append(s1)
        speciality.append(s2)
        
        let s3 = Speciality(name: "Nurse in the house fdswedding")
        speciality.append(s3)
        
        let s4 = Speciality(name: "Nurse in fdsthe house wedding")
        speciality.append(s4)
        
        let s5 = Speciality(name: "Nurse fdsdin the house wedding")
        speciality.append(s5)
        
        let s6 = Speciality(name: "Nurse in tdfdhe house wedding")
        speciality.append(s6)
        
        let s7 = Speciality(name: "Nursdfse in the house wedding")
        speciality.append(s7)
        
        let s8 = Speciality(name: "Nurse in the house weddifsdfng")
        speciality.append(s8)
        
        let s9 = Speciality(name: "Nusddsfrse in the house weddsdfing")
        speciality.append(s9)
        
        let s10 = Speciality(name: "Nurse infdsfds the house wedding")
        speciality.append(s10)
        
        let s11 = Speciality(name: "Nursssdse fdsdin the house wedding")
        speciality.append(s11)
        
        let s12 = Speciality(name: "Nurse insdfds tdfdhe house wedding")
        speciality.append(s12)
        
        let s13 = Speciality(name: "Nursdfse fdsfdsin the house wedding")
        speciality.append(s13)
        
        let s14 = Speciality(name: "Nurse in d house weddifsdfng")
        speciality.append(s14)
        
        let s15 = Speciality(name: "Nusddsfrse xd xD the house weddsdfing")
        speciality.append(s15)
        
        let s16 = Speciality(name: "XD infdsfds the house weddsdddfing")
        speciality.append(s16)
        
        let s17 = Speciality(name: "Nurdfdfse infdssdsdfds the house weddsdddfing")
        speciality.append(s17)
        
        let s18 = Speciality(name: "ndinfdsfds the house weddsdddfing")
        speciality.append(s18)
        
        let s19 = Speciality(name: "Nurdfdfse infdsfds the house weding planet")
        speciality.append(s19)
        
        let s20 = Speciality(name: "urivulno infdsfds the house weddsdddfing")
        speciality.append(s20)
        
        let s21 = Speciality(name: "Nurdfdfse buba kokes the house weddsdddfing")
        speciality.append(s21)
        
        let s22 = Speciality(name: "Nurdfdfse infdsfds the house weddsdddfing")
        speciality.append(s22)
        
        let s23 = Speciality(name: "Nurdfdfse infdsfds the house navulno")
        speciality.append(s23)
        
        return speciality
    }
    
    static func isHighlighted(speciality: [Speciality]) -> [Bool] {
        var highlight: [Bool] = []
        speciality.forEach { _ in highlight.append(false) }
        return highlight
    }
}
