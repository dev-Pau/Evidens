//
//  CaseViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/7/22.
//

import UIKit

/// The viewModel for a Case.
struct CaseViewModel {
    
    var clinicalCase: Case
    
    var title: String {
        return clinicalCase.title
    }
    
    var anonymous: Bool {
        return clinicalCase.privacy == .anonymous
    }
    
    var content: String {
        return clinicalCase.content
    }
    
    var specialities: [Speciality] {
        return clinicalCase.specialities
    }
    
    var items: [CaseItem] {
        return clinicalCase.items
    }
    
    var likes: Int {
        return clinicalCase.likes
    }
    
    var comments: Int {
        return clinicalCase.numberOfComments
    }
    
    var phaseTitle: String {
        return clinicalCase.phase.title
    }
    
    var detailedCase: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = .current
        
        let timeString = formatter.string(from: clinicalCase.timestamp.dateValue())
        
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let dateString = formatter.string(from: clinicalCase.timestamp.dateValue())

        return timeString + AppStrings.Characters.dot + dateString
    }


    var details: [String] {
        var details = [String]()
        
        details.append(phaseTitle)
        
        if hasDiagnosis {
            details.append(AppStrings.Content.Case.Share.diagnosis)
        } else if hasRevisions {
            details.append(AppStrings.Content.Case.Share.revision)
        }
        
        if clinicalCase.kind == .image {
            details.append(AppStrings.Content.Case.Share.images)
        }
        
        details.append(plainTime)
        
        return details
    }
    
    var summary: [String] {
        var summary = [String]()
        summary.append(phaseTitle)
        
        if hasDiagnosis {
            summary.append(AppStrings.Content.Case.Share.diagnosis)
        } else if hasRevisions {
            summary.append(AppStrings.Content.Case.Share.revision)
        }
        
        summary.append(contentsOf: disciplines.map { $0.name })
        
        return summary
    }
    
    var privacyImage: UIImage {
        switch clinicalCase.privacy {
        case .regular: return UIImage(systemName: AppStrings.Icons.fillEuropeGlobe)!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        case .anonymous:
            return UIImage(systemName: AppStrings.Icons.eyeGlasses)!.scalePreservingAspectRatio(targetSize: CGSize(width: 11.6, height: 11.6))
        }
    }
    
    var disciplines: [Discipline] {
        return clinicalCase.disciplines
    }
    
    var baseColor: UIColor {
        return primaryColor
    }
    
    var phaseColor: UIColor {
        switch clinicalCase.phase {
        case .solved:
            return .white
        case .unsolved:
            return .systemBackground
        }
    }
    
    var backgroundColor: UIColor {
        switch clinicalCase.phase {
        case .solved:
            return .systemGreen
        case .unsolved:
            return .label
        }
    }
    
    var hasDiagnosis: Bool {
        return clinicalCase.phase == .solved && clinicalCase.revision == .diagnosis ? true : false
    }
    
    var revision: CaseRevisionKind {
        return clinicalCase.revision
    }
    
    var hasRevisions: Bool {
        return clinicalCase.revision == .update
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return AppStrings.Characters.dot + (formatter.string(from: clinicalCase.timestamp.dateValue(), to: Date()) ?? "")
    }
    
    var plainTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: clinicalCase.timestamp.dateValue(), to: Date()) ?? ""
    }
    
    var time: String {
        return timestamp + AppStrings.Characters.dot
    }
    
    var kind: CaseKind {
        return clinicalCase.kind
    }
        
    var numberOfImages: Int {
        return clinicalCase.imageUrl.count
    }
    
    var images: [String] {
        if numberOfImages > 0 {
            guard let first = clinicalCase.imageUrl.first, first != "" else {
                return [String]()
            }
            return clinicalCase.imageUrl
        }
        return [String]()
        
    }

    var likeColor: UIColor {
        return clinicalCase.didLike ? primaryRed : .secondaryLabel
    }

    var likeImage: UIImage? {
        let imageName = clinicalCase.didLike ? AppStrings.Icons.fillHeart : AppStrings.Icons.heart
        if clinicalCase.didLike {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        } else {
            return UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 22)).withRenderingMode(.alwaysOriginal).withTintColor(.secondaryLabel)
        }
    }
    
    var bookMarkImage: UIImage? {
        let imageName = clinicalCase.didBookmark ? AppStrings.Assets.fillBookmark : AppStrings.Assets.bookmark
        let imageColor = clinicalCase.didBookmark ? primaryColor : .secondaryLabel
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(imageColor)
    }
    
    var commentsText: String {
        return clinicalCase.numberOfComments != 0 ? String(comments) : ""
    }
    
    var likesText: String {
        return clinicalCase.likes != 0 ? String(likes) : ""
    }
}
