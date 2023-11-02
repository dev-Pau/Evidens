//
//  TypeSearchService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/10/23.
//

import Foundation
import Typesense

class TypeSearchService {
    
    private let node1 = Node(host: "eu7yr24qz3mapd8bp-1.a1.typesense.net", port: "443", nodeProtocol: "https")
    private let client: Client

    static let shared = TypeSearchService()
    
    private init() {
        let myConfig = Configuration(nodes: [node1], apiKey: "iWYiCaAd2ymp7QtUREylt0oAdh0eYNFV")
        client = Client(config: myConfig)
    }
 
    func search(with text: String) async throws -> [Suggestion] {
        
        guard NetworkMonitor.shared.isConnected else {
            throw FirestoreError.network
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "name", sortBy: "score:desc", numTypos: 0, perPage: 3)

        do {
            let (data, response) = try await client.collection(name: "suggestions").documents().search(searchParameters, for: Suggestion.self)
            guard let data = data, let hits = data.hits else {
                throw FirestoreError.notFound
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw FirestoreError.notFound
            }
            
            var suggestions: [Suggestion] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    suggestions.append(suggestion)
                }
            }
            
            return suggestions

        } catch {
            throw FirestoreError.notFound
        }
    }
    
    func searchUsers(with text: String, withDiscipline discipline: Discipline? = nil, perPage: Int) async throws -> [TypeUser] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "name", filterBy: filter, numTypos: 0, perPage: perPage)

        do {
            let (data, response) = try await client.collection(name: "users").documents().search(searchParameters, for: TypeUser.self)
            guard let data = data, let hits = data.hits else {
                throw FirestoreError.notFound
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw FirestoreError.notFound
            }
            
            var users: [TypeUser] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    users.append(suggestion)
                }
            }
            
            return users

        } catch {
            throw FirestoreError.notFound
        }
    }
    
    func searchPosts(with text: String, withDisciplin discipline: Discipline? = nil, perPage: Int) async throws -> [TypePost] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "post", filterBy: filter, numTypos: 0, perPage: perPage)
        
        do {
            let (data, response) = try await client.collection(name: "posts").documents().search(searchParameters, for: TypePost.self)
            guard let data = data, let hits = data.hits else {
                throw FirestoreError.notFound
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw FirestoreError.notFound
            }
            
            var posts: [TypePost] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    posts.append(suggestion)
                }
            }
            
            return posts

        } catch {
            throw FirestoreError.notFound
        }
    }
    
    func searchCases(with text: String, withDiscipline discipline: Discipline? = nil, perPage: Int) async throws -> [TypeCase] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "title, content", filterBy: filter, numTypos: 0, perPage: perPage)
        
        do {
            let (data, response) = try await client.collection(name: "cases").documents().search(searchParameters, for: TypeCase.self)
            guard let data = data, let hits = data.hits else {
                throw FirestoreError.notFound
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw FirestoreError.notFound
            }
            
            var cases: [TypeCase] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    cases.append(suggestion)
                }
            }
            
            return cases

        } catch {
            throw FirestoreError.notFound
        }
    }
}

struct Suggestion: Codable {
    let name: String
    let score: Int32
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.score = dictionary["score"] as? Int32 ?? 0
    }
}

struct TypeUser: Codable {
    let id: String

    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
    }
}

struct TypePost: Codable {
    let id: String

    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
    }
}


struct TypeCase: Codable {
    let id: String

    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
    }
}

