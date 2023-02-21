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
    
    
    
    
}

struct CreateJobViewModel {
    var companyId: String?
    var profession: String?
    
    var title: String?
    var description: String?
    var role: String?
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
    
    var hasRole: Bool {
        return role?.isEmpty == false
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
        return hasTitle && hasDescription && hasRole && hasWorkplaceType && hasLocation && hasJobType && hasProfession && hasCompanyId
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
