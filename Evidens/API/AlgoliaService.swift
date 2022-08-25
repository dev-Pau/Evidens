//
//  AlgoliaService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 25/8/22.
//

import UIKit
import AlgoliaSearchClient

struct SearchUser: Codable {
    let firstName: String
    var lastName: String
    let objectID: String
    var profileImageUrl: String?
    var category: Int
    var profession: String
    var speciality: String
}

struct SearchPost: Codable {
    let post: String
    let objectID: String
}

struct SearchCase: Codable {
    let title: String
    let description: String
    let objectID: String
}


struct AlgoliaService {
    
    static var client = SearchClient(appID: "1CZMK6HJ7G", apiKey: "53784cb25e34ebcd9a93ea1efdb48061")
    
    static func fetchTopUsers(withText text: String, completion: @escaping([SearchUser]) -> Void) {
        let index = client.index(withName: "users_search")
        var query = Query(text)
        query.hitsPerPage = 3
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchUser] = try response.extractHits()
                    print(hits)
                    /*
                    hits.forEach { user in
                        print(user.firstName)
                        
                    }
                     */
                    completion(hits)
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func fetchTopPosts(withText text: String, completion: @escaping([String]) -> Void) {
        let index = client.index(withName: "posts_search")
        var query = Query(text)
        var postIDs: [String] = []
        
        query.hitsPerPage = 3
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchPost] = try response.extractHits()
                    hits.forEach { hit in
                        postIDs.append(hit.objectID)
                    }

                    completion(postIDs)
                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func fetchTopCases(withText text: String, completion: @escaping([String]) -> Void) {
        let index = client.index(withName: "cases_search")
        var query = Query(text)
        var caseIDs: [String] = []
        
        query.hitsPerPage = 3
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchCase] = try response.extractHits()
                    hits.forEach { hit in
                        caseIDs.append(hit.objectID)
                    }

                    completion(caseIDs)
                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func fetchUsers(withText text: String, completion: @escaping([SearchUser]) -> Void) {
        let index = client.index(withName: "users_search")

        var query = Query(text)
        query.hitsPerPage = 15
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchUser] = try response.extractHits()
                    print(hits)
                    /*
                    hits.forEach { user in
                        print(user.firstName)
                        
                    }
                     */
                    completion(hits)
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func fetchPosts(withText text: String, completion: @escaping([String]) -> Void) {
        let index = client.index(withName: "posts_search")
        var query = Query(text)
        var postIDs: [String] = []
        
        query.hitsPerPage = 8
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchPost] = try response.extractHits()
                    hits.forEach { hit in
                        postIDs.append(hit.objectID)
                    }

                    completion(postIDs)
                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func fetchCases(withText text: String, completion: @escaping([String]) -> Void) {
        let index = client.index(withName: "cases_search")
        var query = Query(text)
        var caseIDs: [String] = []
        
        query.hitsPerPage = 8
        //query.attributesToRetrieve = ["firstName", "lastName"]
        
        index.search(query: query) { result in
            switch result {
                
            case .success(let response):
                do {
                    print(response)
                    let hits: [SearchCase] = try response.extractHits()
                    hits.forEach { hit in
                        caseIDs.append(hit.objectID)
                    }

                    completion(caseIDs)
                    
                } catch let error {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
