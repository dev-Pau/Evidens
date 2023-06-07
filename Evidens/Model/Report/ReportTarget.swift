//
//  ReportTarget.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// An enum mapping the target type of a Report.
enum ReportTarget: Int, CaseIterable {
    case myself, group, everyone
    
    var title: String {
        switch self {
        case .myself: return AppStrings.Report.Target.myselfTitle
        case .group: return AppStrings.Report.Target.groupTitle
        case .everyone: return AppStrings.Report.Target.everyoneTitle
        }
    }
    
    var content: String {
        switch self {
        case .myself: return AppStrings.Report.Target.myselfContent
        case .group: return AppStrings.Report.Target.groupContent
        case .everyone: return AppStrings.Report.Target.everyoneContent
        }
    }
    
    var summary: String {
        switch self {
        case .myself: return AppStrings.Report.Target.myselfSummary
        case .group: return AppStrings.Report.Target.groupSummary
        case .everyone: return AppStrings.Report.Target.everyoneSummary
        }
    }
}
