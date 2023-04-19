//
//  MenuLauncher.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/4/23.
//

import UIKit

struct MenuLauncher {
    
    enum MenuType: Int, CaseIterable {
        case groupPrivacy
        case applyJobPrivacy
        case joiningGroups
        
        var title: String {
            switch self {
            case .groupPrivacy:
                return "Privacy Rules"
            case .applyJobPrivacy:
                return "Privacy Rules"
            case .joiningGroups:
                return "Eligibility Requirements"
            }
        }
        
        var description: String {
            switch self {
            case .groupPrivacy:
                return "When content is shared only with group members, it means that the information is restricted to a specific group of individuals who have been granted access to it. This practice helps to maintain the privacy and security of the information being shared. Only those who have been given permission to join the group can view and interact with the content, which creates a trusted and controlled environment. This approach ensures that the information remains within the intended audience and is not accessible to the general public or anyone who is not a member of the group."
            case .applyJobPrivacy:
                return "To ensure the security and privacy of our users, we want to remind you that you are about to provide your personal contact information, including your full name, email address, phone number, and resume. Please note that this information will be shared with the hiring personnel of the company or organization you are applying to. They will use your contact information to communicate with you regarding your application and potential employment opportunities."
            case .joiningGroups:
                return "Our healthcare professional and student application is designed to connect individuals who are interested in healthcare-related topics. To ensure that the application is used by the intended audience, we have identified three categories of users who are eligible to join\n\n• Healthcare Professionals (e.g. physicians, nurses, dentists, pharmacists, allied health professionals)\n• Healthcare Students (e.g. medical students, nursing students, dental students, allied health students)\n• Retired Healthcare Professionals."
            }
        }
    }
}
