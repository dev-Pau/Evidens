//
//  ExperienceViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/8/23.
//

import UIKit

struct ExperienceViewModel {
    
    private(set) var id: String?
    private(set) var role: String?
    private(set) var company: String?
    private(set) var start: TimeInterval?
    private(set) var end: TimeInterval?
    
    private(set) var isCurrentExperience = false
    
    var isValid: Bool {
        let validDate = isCurrentExperience ? start != nil : ( start != nil && end != nil)

        return role != nil && company != nil && start != nil && validDate
    }
    
    mutating func set(experience: Experience?) {
        if let experience {
            self.id = experience.id
            self.role = experience.role
            self.company = experience.company
            self.start = experience.start
            
            if let end = experience.end {
                self.end = end
            } else {
                self.isCurrentExperience = true
            }

        }
    }
 
    var dateImage: UIImage {
        return (UIImage(systemName: isCurrentExperience ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(isCurrentExperience ? primaryColor : .secondaryLabel))!
    }
    
    mutating func toggleExperience() {
        self.isCurrentExperience.toggle()
        if isCurrentExperience {
            end = nil
        }
    }
    
    mutating func set(role: String?) {
        self.role = role
    }
    
    mutating func set(company: String?) {
        self.company = company
    }
    
    mutating func set(start: TimeInterval) {
        self.start = start
    }
    
    mutating func set(end: TimeInterval) {
        self.end = end
    }
    
    var experience: Experience? {
        guard let id = id, let role = role, let company = company, let start = start else {
            return nil
        }
        return Experience(id: id, role: role, company: company, start: start, end: end)
    }
    
    
}
