//
//  EducationViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 8/8/23.
//

import UIKit

struct EducationViewModel {
    private(set) var id: String?
    private(set) var school: String?
    private(set) var kind: String?
    private(set) var field: String?
    private(set) var start: TimeInterval?
    private(set) var end: TimeInterval?
    
    private(set) var isCurrentEducation = false
    
    var isValid: Bool {
        let validDate = isCurrentEducation ? start != nil : ( start != nil && end != nil)
        
        return school != nil && kind != nil && field != nil && start != nil && validDate
    }
    
    mutating func set(education: Education?) {
        if let education {
            self.id = education.id
            self.school = education.school
            self.kind = education.kind
            self.field = education.field
            self.start = education.start
            
            if let end = education.end {
                self.end = end
            } else {
                self.isCurrentEducation = true
            }
        }
    }
    
    
    var dateImage: UIImage {
        return (UIImage(systemName: isCurrentEducation ? AppStrings.Icons.checkmarkCircleFill : AppStrings.Icons.circle)?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(isCurrentEducation ? primaryColor : .secondaryLabel))!
    }

    mutating func toggleEducation() {
        self.isCurrentEducation.toggle()
        if isCurrentEducation {
            end = nil
        }
    }
    
    mutating func set(school: String?) {
        self.school = school
    }
    
    mutating func set(kind: String?) {
        self.kind = kind
    }
    
    mutating func set(field: String?) {
        self.field = field
    }
    
    mutating func set(start: TimeInterval?) {
        self.start = start
    }
    
    mutating func set(end: TimeInterval?) {
        self.end = end
    }
    
    var education: Education? {
        guard let id = id, let school = school, let kind = kind, let field = field, let start = start else {
            return nil
        }
        return Education(id: id, school: school, kind: kind, field: field, start: start, end: end)
    }
}
