//
//  Report.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

struct Report {
    
    var contentId: String
    var contentOwnerUid: String
    var target: Target
    var topic: Topics
    var reportOwnerUid: String
    var reportInfo: String
    
    init(dictionary: [String: Any]) {
        self.contentId = dictionary["contentId"] as? String ?? ""
        self.contentOwnerUid = dictionary["contentOwnerUid"] as? String ?? ""
        self.target = Target(rawValue: dictionary["target"] as? String ?? Target.myself.rawValue) ?? .myself
        self.topic = Topics(rawValue: dictionary["topic"] as? String ?? Topics.identity.rawValue ) ?? .identity
        self.reportOwnerUid = dictionary["reportOwnerUid"] as? String ?? ""
        self.reportInfo = dictionary["reportInfo"] as? String ?? ""
    }
}

extension Report {
    
    enum Target: String, CaseIterable {
        case myself = "Myself"
        case group = "Someone else or a specific group of people"
        case everyone = "Everyone"
        
        var details: String {
            switch self {
            case .myself:
                return "The individual is either creating content that is directed towards themselves or consuming content that is personalized or tailored to their preferences."
            case .group:
                return "This content is directed at or mentions someone else or a specific group of people —— like racial or religious groups."
            case .everyone:
                return "This content is isn't targeting a specific person or group, but it affects everyone —— like misleading information or sensitive content."
            }
        }
        
        var summary: String {
            switch self {
            case .myself:
                return "This report is for me."
            case .group:
                return "This report is for someone else or a specific group of people."
            case .everyone:
                return "This report is for everyone."
            }
        }
    }
    
    enum Topics: String, CaseIterable {
        case identity = "Attacked because of the identity"
        case harass = "Harassed or intimidated with violence"
        case spam = "Spammed"
        case sensible = "Shown sensitive or disturbing content"
        case evidence = "Lacking medical evidence or shown misleading information"
        case tips = "Offered tips or currency - or encouraged to send them —— in a way that's deceptive or promotes or causes harm"
        
        var details: String {
            switch self {
            case .identity:
                return "Slurs, misgendering, racist or sexist stereotypes, encouraging others to harass, sending hateful imagery or could risk identifying the patient."
            case .harass:
                return "Sexual narassment, group narassment, insults or name calling, posting private info, threatening to expose private into, violent event denial, violent threats, celebration of violent acts."
            case .spam:
                return "Posting malicious links, fake engagement, repetitive replies, or Direct Messages."
            case .sensible:
                return "Posting graphic or violent content related to self-harm, suicide, or other sensitive topics, that could be triggering or harmful to some users."
            case .evidence:
                return "This content contains a claim that isn't supported by data."
            case .tips:
                return "Behaviors that offer tips and incentives, encourage users to engage in deceptive practices, promote inappropriate content or behavior, or exploit the platform to earn rewards or other currencies."
            }
        }
    }
}
