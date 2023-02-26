//
//  JobViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit

struct JobViewModel {
    var job: Job
    
    init(job: Job) {
        self.job = job
    }
    
    var jobName: String {
        return job.title
    }
    
    var jobDescription: String {
        return job.description
    }
    
    var jobLocation: String {
        return job.location
    }
    
    var jobTimestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: job.timestamp.dateValue(), to: Date())
    }
    
    var jobType: String {
        return job.jobType
    }
    
    var jobId: String {
        return job.jobId
    }
    
    var jobProfession: String {
        return job.profession
    }
    
    var jobWorkplaceType: String {
        return job.workplaceType
    }
    
    var jobStageText: String {
        switch job.stage {
            
        case .review:
            return "Under review"
        case .open:
            return "Open"
        case .closed:
            return "Closed"
        }
    }
    
    var jobStageBackgroundColor: UIColor {
        switch job.stage {
            
        case .review:
            return .systemYellow
        case .open:
            return .systemGreen
        case .closed:
            return .systemRed
        }
    }
    
    var bookMarkImage: UIImage? {
        let imageName = job.didBookmark ? "bookmark.fill" : "bookmark"
        return UIImage(named: imageName)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.label)
    }
}

struct ApplyJobViewModel {
    var documentUrl: URL?
    var phoneNumber: String?
    
    var hasDocument: Bool {
        return documentUrl == nil ? false : true
    }
    
    var hasPhone: Bool {
        return phoneNumber?.isEmpty == false
    }
    
    var jobIsValid: Bool {
        return hasDocument && hasPhone
    }
}

struct CreateJobViewModel {
    var companyId: String?
    var profession: String?
    
    var title: String?
    var description: String?

    var workplaceType: String?
    var location: String?
    var jobType: String?

    var hasCompanyId: Bool {
        return companyId?.isEmpty == false
    }
    
    var hasProfession: Bool {
        return profession?.isEmpty == false
    }

    var hasTitle: Bool {
        return title?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var hasWorkplaceType: Bool {
        return workplaceType?.isEmpty == false
    }
    
    var hasLocation: Bool {
        return location?.isEmpty == false
    }
    
    var hasJobType: Bool {
        return jobType?.isEmpty == false
    }
    
    var jobIsValid: Bool {
        return hasTitle && hasDescription && hasWorkplaceType && hasLocation && hasJobType && hasProfession && hasCompanyId
    }
}

struct CreateCompanyViewModel {
    var location: String?
    var name: String?
    var description: String?
    var profileImage: Bool?
    var industry: String?
    var specialities: [String]?
    
    var hasLocation: Bool {
        return location?.isEmpty == false
    }
    
    var hasProfile: Bool {
        return profileImage ?? false
    }
    
    var hasName: Bool {
        return name?.isEmpty == false
    }
    
    var hasDescription: Bool {
        return description?.isEmpty == false
    }
    
    var hasIndustry: Bool {
        return industry?.isEmpty == false
    }
    
    var hasSpecialities: Bool {
        return specialities?.isEmpty == false
    }
    
    var companyIsValid: Bool {
        return hasLocation && hasName && hasDescription && hasIndustry && hasSpecialities
    }
}
