//
//  CaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

struct CaseViewModel {
    
    var clinicalCase: Case
    
    var caseTitle: String {
        return clinicalCase.caseTitle
    }
    
    var caseDescription: String {
        return clinicalCase.caseDescription
    }
    
    var caseSpecialities: [String] {
        return clinicalCase.caseSpecialities
    }
    
    var caseTypeDetails: [String] {
        return clinicalCase.caseTypeDetails
    }
    
    var caseTags: [String] {
        return caseTypeDetails + caseSpecialities
    }
    
    var caseLikes: Int {
        return clinicalCase.likes
    }
    
    var caseComments: Int {
        return clinicalCase.numberOfComments
    }
    
    var caseViews: Int {
        return clinicalCase.numberOfViews
    }
    
    var caseStage: String {
        return clinicalCase.stage.rawValue == 0 ? "Resolved" : "Unresolved"
    }
    
    var caseResolvedWithDiagnosis: Bool {
        return clinicalCase.stage.rawValue == 0 && !diagnosisText.isEmpty ? true : false
    }
    
    var diagnosisText: String {
        return clinicalCase.diagnosis
    }
    
    var ownerCategory: String {
        return clinicalCase.ownerCategory.userCategoryString
    }
    
    var userInfo: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(ownerProfession), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        attributedText.append(NSAttributedString(string: "\(ownerSpeciality) · ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
        attributedText.append(NSAttributedString(string: ownerCategory, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: primaryColor]))
        
        return attributedText
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: clinicalCase.timestamp.dateValue(), to: Date())
    }
    
    var caseType: Int {
        return clinicalCase.type.rawValue
    }
        
    var fullName: String {
        return clinicalCase.ownerFirstName + " " + clinicalCase.ownerLastName
    }
    
    var ownerProfession: String {
        return clinicalCase.ownerProfession
    }
    
    var ownerSpeciality: String {
        return clinicalCase.ownerSpeciality
    }
    
    var ownerFullProfession: String {
        return clinicalCase.ownerProfession + " · " + clinicalCase.ownerSpeciality
    }
    
    var userProfileImageUrl: URL? {
        return URL(string: clinicalCase.ownerImageUrl)
    }
    
    var caseImageUrl: [URL]? {
        clinicalCase.caseImageUrl.map { image in
            URL(string: image)!
        }
    }
    
    var isLikesHidden: Bool {
        if clinicalCase.likes == 0 {
            return true
        } else {
            return false
        }
    }
    
    var likesLabelText: String {
        if clinicalCase.likes > 0 {
            return "\(clinicalCase.likes)"
        } else {
            return ""
        }
    }
    
    var likeButtonTintColor: UIColor {
        return clinicalCase.didLike ? pinkColor : blackColor
    }
    
    var likeButtonImage: UIImage? {
        let imageName = clinicalCase.didLike ? "heart.fill" : "heart"
        return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
    }
    
    var commentsText: String {
        if clinicalCase.numberOfComments > 1 {
            return "\(clinicalCase.numberOfComments) comments"
        }
        else if clinicalCase.numberOfComments == 1 {
            return "\(clinicalCase.numberOfComments) comment"
        }
        else {
            return ""
        }
    }
    
    var viewsText: String {
        if clinicalCase.numberOfViews > 1 {
            return "\(clinicalCase.numberOfViews) views"
        }
        else if clinicalCase.numberOfViews == 1 {
            return "\(clinicalCase.numberOfViews) view"
        }
        else {
            return ""
        }
    }
}
