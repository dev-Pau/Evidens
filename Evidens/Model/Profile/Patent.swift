//
//  Patent.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import Foundation

/// The model for a Patent.
struct Patent {
    var title: String
    var number: String
    var contributorUids: [String]
}
