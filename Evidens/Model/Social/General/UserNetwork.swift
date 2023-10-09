//
//  UserNetwork.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/8/23.
//

import Foundation


enum UserNetwork: Int, CaseIterable {
    case connections, followers, following

    var title: String {
        switch self {
        case .connections: return AppStrings.Network.Connection.connections.capitalized
        case .followers: return AppStrings.Network.Follow.followers.capitalized
        case .following: return AppStrings.Network.Follow.following.capitalized
        }
    }
}

