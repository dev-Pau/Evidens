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
    
    var caseIsAnonymous: Bool {
        return clinicalCase.privacyOptions == .visible ? false : true
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
    
    var caseStage: AttributedString {
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 11, weight: .semibold)
        
        return clinicalCase.stage.rawValue == 0 ? AttributedString("Solved", attributes: container) : AttributedString("Unsolved", attributes: container)
    }
    
    var caseImageStage: UIImage {
        return clinicalCase.stage.rawValue == 0 ? UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))! : UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!
    }
    
    var caseStageTextColor: UIColor {
        return clinicalCase.stage.rawValue == 0 ? .white : grayColor
    }
    
    var caseStageBackgroundColor: UIColor {
        return clinicalCase.stage.rawValue == 0 ? leafGreenColor : lightGrayColor
    }
    
    var caseResolvedWithDiagnosis: Bool {
        return clinicalCase.stage.rawValue == 0 && !diagnosisText.isEmpty ? true : false
    }
    
    var caseHasUpdates: Bool {
        return clinicalCase.caseUpdates.isEmpty ? false : true
    }
    
    var diagnosisText: String {
        return clinicalCase.diagnosis
    }
    
    var userIsProfessional: Bool {
        return ownerCategory == "Professional" ? true : false
    }
    
    var ownerCategory: String {
        return clinicalCase.ownerCategory.userCategoryString
    }
    
    var userInfo: NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(ownerProfession), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        
        if userIsProfessional {
            attributedText.append(NSAttributedString(string: "\(ownerSpeciality)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
        } else {
            attributedText.append(NSAttributedString(string: "\(ownerSpeciality) · ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
            attributedText.append(NSAttributedString(string: ownerCategory, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: primaryColor]))
        }
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
        return caseIsAnonymous ? "Shared anonymously" : clinicalCase.ownerFirstName + " " + clinicalCase.ownerLastName
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
    
    var userProfileImageUrl: String? {
        return caseIsAnonymous ? nil : clinicalCase.ownerImageUrl
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
    
    var commentText: String {
        if caseComments > 1 { return "comments" }
        else { return "comment" }
    }
    
    var likesCommentsText: String {
        if caseLikes == 0 && caseComments == 0 {
            return ""
        } else if caseLikes != 0 && caseComments == 0 {
            return "\(caseLikes)"
        } else if caseLikes == 0 && caseComments != 0 {
            return "\(caseComments) \( commentText)"
        } else {
            return "\(caseLikes) · \(caseComments) \(commentText)"
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
        if clinicalCase.numberOfComments != 0 {
            return "\(caseComments)"
        } else {
            return ""
        }
    }
    
    var likesText: String {
        if clinicalCase.likes != 0 {
            return "\(caseLikes)"
        } else {
            return ""
        }
    }
    
    var likesButtonIsHidden: Bool {
        return caseLikes > 0 ? false : true
    }
    
    var bookMarkImage: UIImage? {
        let imageName = clinicalCase.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
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
