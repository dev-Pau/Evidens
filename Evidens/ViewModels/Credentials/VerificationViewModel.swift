//
//  File.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/23.
//

import UIKit

/// The viewModel for a Verification.
class VerificationViewModel {
    
    var user: User
    private(set) var kind: IdentityKind
    
    init(user: User) {
        self.user = user
        self.kind = .doc
    }
    
    private(set) var docImage: UIImage?
    private(set) var idImage: UIImage?
    
    var currentUser: User {
        return self.user
    }
    
    var isValid: Bool {
        return docImage != nil && idImage != nil
    }
    
    var uid: String? {
        return user.uid
    }
    
    var userKind: UserKind {
        return user.kind
    }

    
    func image() -> UIImage? {
        switch kind {
        case .doc:
            return docImage
        case .id:
            return idImage
        }
    }
    
    func setKind() {
        switch kind {
        case .doc:
            self.kind = .id
        case .id:
            self.kind = .doc
        }
    }
    
    func setDocImage(_ image: UIImage) {
        self.docImage = image
    }
    
    func setIdImage(_ image: UIImage) {
        self.idImage = image
    }
}
