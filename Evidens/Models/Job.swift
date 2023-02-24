//
//  Job.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit
import Firebase

struct Job {
    
    var ownerUid: String
    var jobId: String
    var title: String
    var description: String
    var workplaceType: String
    var jobType: String
    let timestamp: Timestamp
    var profession: String
    var companyId: String
    var location: String
    
    var didBookmark = false
    
    init(jobId: String, dictionary: [String: Any]) {
        self.jobId = jobId
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.workplaceType = dictionary["workplaceType"] as? String ?? ""
        self.jobType = dictionary["jobType"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.profession = dictionary["profession"] as? String ?? ""
        self.companyId = dictionary["companyId"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
    }
}

extension Job {
    enum WorksplaceType: String, CaseIterable {
        case onSite = "On-site"
        case hybrid = "Hybrid"
        case remote = "Remote"
        
        var JobTypeDescription: String {
            switch self {
            case .onSite:
                return "Employees come to work in person."
            case .hybrid:
                return "Employees work on-site and off-site."
            case .remote:
                return "Employees work off-site."
            }
        }
    }
    
    enum JobType: String, CaseIterable {
        case full = "Full-time"
        case part = "Part-Time"
        case contract = "Contract"
        case temporary = "Temporary"
        case other = "Other"
        case volunteer = "Volunteer"
        case internship = "Internship"
    }
    
    enum JobSections: String, CaseIterable {
        case title = "Title"
        case description = "Description"
        case workplace = "Workplace"
        case location = "Location"
        case type = "Type"
        case professions = "Profession"
    }
    
    enum UserJobType: Int, CaseIterable {
        case manager = 0
        case applicant = 1
    }
    
    /*
    enum JobTitle: String, CaseIterable {

    }
     */
}

struct JobApplicant {
    var jobId: String
    var documentUrl: String
    var timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.jobId = dictionary["jobId"] as? String ?? ""
        self.documentUrl = dictionary["documentUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

struct Company {
    var id: String
    var ownerUid: String
    var location: String
    var name: String
    var description: String
    var companyImageUrl: String?
    var industry: String
    var timestamp: Timestamp
    var specialities: [String]
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.companyImageUrl = dictionary["companyImageUrl"] as? String ?? ""
        self.industry = dictionary["industry"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.specialities = dictionary["specialities"] as? [String] ?? [""]
    }
}
