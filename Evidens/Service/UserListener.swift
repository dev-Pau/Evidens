//
//  UserListener.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/24.
//

import Foundation
import Firebase

class UserListener {
    
    private(set) var listener: ListenerRegistration?
    static let shared = UserListener()
    
    func listenUser(completion: @escaping(Bool) -> Void) {
        
        guard let uid = UserDefaults.getUid() else { return }
        
        guard listener == nil else { 
            return
        }

        listener = COLLECTION_USERS.document(uid).addSnapshotListener { snapshot, error in
            guard let document = snapshot else { return }
            
            guard let data = document.data() else { return }
            
            let user = User(dictionary: data)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let strongSelf = self else { return }
                
                guard let phase = UserDefaults.getPhase() else {
                    strongSelf.removeListener()
                    completion(true)
                    return
                }
                
                if phase != user.phase {
                    strongSelf.removeListener()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
}
