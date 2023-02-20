//
//  JobViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit

struct JobViewModel {
    
}

struct CreateJobViewModel {
    var companyId: String?
    var professions: [Profession]?
    
    var title: String?
    var description: String?
    var role: String?
    var workplaceType: String?
    var location: String?
    var jobType: String?

    var hasCompanyId: Bool {
        return companyId?.isEmpty == false
    }
    
    var hasProfessions: Bool {
        return professions?.isEmpty == false
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
        return hasTitle && hasDescription && hasRole && hasWorkplaceType && hasLocation && hasJobType && hasProfessions && hasCompanyId
    }
}
