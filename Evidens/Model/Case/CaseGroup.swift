//
//  CaseGroup.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/23.
//

import Foundation

enum CaseGroup {
    case discipline(_ discipline: Discipline)
    case body(_ body: Body, _ orientation: BodyOrientation)
    case speciality(_ speciality: Speciality)
}
