//
//  TypesenseError.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/1/24.
//

import Foundation

/// An enum representing different types of errors that can occur during Typsense Error operations.
enum TypesenseError: Error {
    case network, symbols, stopWords, server, empty, unknown
}
