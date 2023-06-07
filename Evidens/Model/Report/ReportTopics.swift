//
//  ReportTopics.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// An enum mapping the topics of a Report.
enum ReportTopics: Int, CaseIterable {
    case identity, harass, spam, sensible, evidence, tips
    
    var title: String {
        switch self {
        case .identity: return AppStrings.Report.Topics.identityTitle
        case .harass: return AppStrings.Report.Topics.harassTitle
        case .spam: return AppStrings.Report.Topics.spamTitle
        case .sensible: return AppStrings.Report.Topics.sensibleTitle
        case .evidence: return AppStrings.Report.Topics.evidenceTitle
        case .tips: return AppStrings.Report.Topics.tipsTitle
        }
    }
    
    var content: String {
        switch self {
        case .identity: return AppStrings.Report.Topics.identityContent
        case .harass: return AppStrings.Report.Topics.harrassContent
        case .spam: return AppStrings.Report.Topics.spamContent
        case .sensible: return AppStrings.Report.Topics.sensibleContent
        case .evidence: return AppStrings.Report.Topics.evidenceContent
        case .tips: return AppStrings.Report.Topics.tipsContent
        }
    }
}

