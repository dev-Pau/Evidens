//
//  SpecialityViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 11/10/23.
//

import UIKit

struct SpecialityViewModel {
    
    var user: User
    
    var isEditingProfileSpeciality: Bool = false
    
    var specialities = [Speciality]()
    var filteredSpecialities = [Speciality]()
    var speciality: Speciality?
    
    var isSearching: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    func setProfessionalDetails(withCredentials credentials: AuthCredentials, completion: @escaping(FirestoreError?) -> Void) {
        AuthService.setProfesionalDetails(withCredentials: credentials) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}
