//
//  Report.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

/// The model for a Report.
struct Report {
    
    var contentId: String
    var contentOwnerUid: String
    var target: ReportTarget
    var topic: ReportTopics
    var reportOwnerUid: String
    var reportInfo: String?
    var source: ReportSource?
    
    /// Initializes a new instance of a Report using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the Report data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.contentId = dictionary["contentId"] as? String ?? ""
        self.contentOwnerUid = dictionary["contentOwnerUid"] as? String ?? ""
        self.target = ReportTarget(rawValue: dictionary["target"] as? Int ?? ReportTarget.myself.rawValue) ?? .myself
        self.topic = ReportTopics(rawValue: dictionary["topic"] as? Int ?? ReportTopics.identity.rawValue ) ?? .identity
        self.reportOwnerUid = dictionary["reportOwnerUid"] as? String ?? ""
        self.reportInfo = dictionary["reportInfo"] as? String ?? ""
    }
}
