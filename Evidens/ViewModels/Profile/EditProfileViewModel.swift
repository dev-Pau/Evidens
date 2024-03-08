//
//  ProfileViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/2/23.
//

import UIKit

/// The viewModel for a EditProfile.
struct EditProfileViewModel {
    
    private(set) var user: User

    var firstName: String?
    var lastName: String?
    var profileImage: UIImage?
    var bannerImage: UIImage?
    var speciality: Speciality?
    
    init(user: User) {
        self.user = user
        firstName = user.firstName!
        lastName = user.lastName!
        speciality = user.speciality!
    }
    
    var hasName: Bool {
        return firstName?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    var hasLastName: Bool {
        return lastName?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    var hasSpeciality: Bool {
        return speciality != nil
    }
    
    var hasProfile: Bool {
        return profileImage != nil
    }
    
    var hasBanner: Bool {
        return bannerImage != nil
    }
    
    var hasBothImages: Bool {
        return bannerImage != nil && profileImage != nil
    }
    
    var profileIsValid: Bool {
        return hasName && hasLastName && hasSpeciality
    }
    
    func updateProfile(completion: @escaping (Result<User, FirestoreError>) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.failure(.network))
            return
        }
        
        guard let firstName = firstName, let lastName = lastName, let speciality = speciality else {
            completion(.failure(.unknown))
            return
        }
        
        var newProfile = User(dictionary: [:])
        newProfile.firstName = firstName
        newProfile.lastName = lastName
        newProfile.speciality = speciality
        
        if hasProfile && hasBanner {
            guard let profile = profileImage, let banner = bannerImage else {
                completion(.failure(.unknown))
                return
            }
            
            let images = [banner, profile]
            StorageManager.addUserImages(images: images) { result in

                switch result {
                
                case .success(let urls):
                    newProfile.bannerUrl = urls.first(where: { url in
                        url.contains("banner")
                    })
                    
                    newProfile.profileUrl = urls.first(where: { url in
                        url.contains("profile")
                    })
                    
                    UserService.updateUser(from: user, to: newProfile) { result in

                        switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(_):
                    completion(.failure(.unknown))
                }
            }
        } else if hasBanner {
            guard let image = bannerImage, let uid = user.uid else {
                completion(.failure(.unknown))
                return
                
            }
            StorageManager.addImage(image: image, uid: uid, kind: .banner) { result in

                switch result {
                    
                case .success(let bannerUrl):
                    newProfile.bannerUrl = bannerUrl
                    UserService.updateUser(from: user, to: newProfile) {result in
                      
                        switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(_):
                    completion(.failure(.unknown))
                }
            }
        } else if hasProfile {
            guard let image = profileImage, let uid = user.uid else {
                completion(.failure(.unknown))
                return
            }
            StorageManager.addImage(image: image, uid: uid, kind: .profile) { result in

                switch result {
                    
                case .success(let profileUrl):
                    newProfile.profileUrl = profileUrl
                    UserService.updateUser(from: user, to: newProfile) { result in

                        switch result {
                        case .success(let user):
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(_):
                    completion(.failure(.unknown))
                }
            }
        } else {
            UserService.updateUser(from: user, to: newProfile) { result in
                switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func removeImage(kind: ImageKind, completion: @escaping(FirestoreError?) -> Void) {

        UserService.removeImage(kind: kind) { error in
            if let error {
                completion(error)
            } else {
                StorageManager.deleteImage(kind: kind)
                completion(nil)
            }
        }
    }
    
    mutating func removeImage(kind: ImageKind) {
        switch kind {
            
        case .profile:
            user.profileUrl = String()
        case .banner:
            user.bannerUrl = String()
        }
    }
}
    
