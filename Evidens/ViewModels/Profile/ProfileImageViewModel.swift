//
//  ProfileImageViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/10/23.
//

import Foundation

/// The viewModel for a ProfileImage.
struct ProfileImageViewModel {
    
    let kind: ImageKind

    init(kind: ImageKind) {
        self.kind = kind
    }
}
