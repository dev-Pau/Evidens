//
//  PostService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/11/21.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(post: String, image: UIImage?, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
    }
}
