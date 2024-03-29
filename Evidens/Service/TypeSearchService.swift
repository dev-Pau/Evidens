//
//  TypeSearchService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 29/10/23.
//

import Foundation
import Typesense

/// A service used to interface with Typesense.
class TypeSearchService {
    
    private let node1: Node!
    private let client: Client

    static let shared = TypeSearchService()
    
    private init() {
        
        #if DEBUG
        node1 = Node(host: "d67g1phaixqvj0wrp-1.a1.typesense.net", port: "443", nodeProtocol: "https")
        let myConfig = Configuration(nodes: [node1], apiKey: "TRiD8iTbusp6SVhocEIGThQNRnXMw6oz")
        client = Client(config: myConfig)
        #else
        node1 = Node(host: "4l8enpsyvjdgiqr1p-1.a1.typesense.net", port: "443", nodeProtocol: "https")
        let myConfig = Configuration(nodes: [node1], apiKey: "quEVD08q7c1gmMW9uLgOy5WjUmO36kmo")
        client = Client(config: myConfig)
        #endif
    }
 
    /// Searches for suggestions based on the provided text.
    ///
    /// - Parameters:
    ///   - text: The search text.
    /// - Returns: An array of Suggestion objects matching the search criteria.
    /// - Throws: A FirestoreError if the search fails or no results are found.
    func search(with text: String) async throws -> [Suggestion] {
        
        let searchParameters = SearchParameters(q: text, queryBy: "name", sortBy: "score:desc", numTypos: 0, perPage: 3)

        do {
            
            guard NetworkMonitor.shared.isConnected else {
                throw TypesenseError.network
            }
            
            let (data, response) = try await client.collection(name: "suggestions").documents().search(searchParameters, for: Suggestion.self)
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw TypesenseError.server
            }
            
            guard let data = data, let hits = data.hits else {
                throw TypesenseError.empty
            }
            
            var suggestions: [Suggestion] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    suggestions.append(suggestion)
                }
            }
            
            return suggestions

        } catch let typeSenseError as TypesenseError {
            throw typeSenseError
        } catch {
            throw TypesenseError.unknown
        }
    }
    
    /// Searches for users based on the provided text and optional discipline filter.
    ///
    /// - Parameters:
    ///   - text: The search text.
    ///   - discipline: An optional discipline filter.
    ///   - perPage: The number of results per page.
    ///   - page: The page number for pagination.
    /// - Returns: An array of TypeUser objects matching the search criteria.
    /// - Throws: A FirestoreError if the search fails or no results are found.
    func searchUsers(with text: String, withDiscipline discipline: Discipline? = nil, perPage: Int, page: Int?) async throws -> [TypeUser] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }

        let searchParameters = SearchParameters(q: text, queryBy: "username, name", filterBy: filter, numTypos: 0, page: page, perPage: perPage)
        
        do {
            
            guard NetworkMonitor.shared.isConnected else {
                throw TypesenseError.network
            }
            
            let (data, response) = try await client.collection(name: "users").documents().search(searchParameters, for: TypeUser.self)
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw TypesenseError.server
            }
            
            guard let data = data, let hits = data.hits else {
                throw TypesenseError.empty
            }
            
            var users: [TypeUser] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    users.append(suggestion)
                }
            }
            
            return users

        } catch let typeSenseError as TypesenseError {
            throw typeSenseError
        } catch {
            throw TypesenseError.unknown
        }
    }
    
    /// Searches for posts based on the provided text and optional discipline filter.
    ///
    /// - Parameters:
    ///   - text: The search text.
    ///   - discipline: An optional discipline filter.
    ///   - page: The page number for pagination.
    ///   - perPage: The number of results per page.
    /// - Returns: An array of TypePost objects matching the search criteria.
    /// - Throws: A FirestoreError if the search fails or no results are found.
    func searchPosts(with text: String, withDisciplin discipline: Discipline? = nil, page: Int?, perPage: Int) async throws -> [TypePost] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "post", filterBy: filter, numTypos: 0, page: page, perPage: perPage)
        
        do {
            
            guard NetworkMonitor.shared.isConnected else {
                throw TypesenseError.network
            }
            
            let (data, response) = try await client.collection(name: "posts").documents().search(searchParameters, for: TypePost.self)
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw TypesenseError.server
            }
            
            guard let data = data, let hits = data.hits else {
                throw TypesenseError.empty
            }
            
            var posts: [TypePost] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    posts.append(suggestion)
                }
            }
            
            return posts

        } catch let typeSenseError as TypesenseError {
            throw typeSenseError
        } catch {
            throw TypesenseError.unknown
        }
    }
    
    /// Searches for cases based on the provided text and optional discipline filter.
    ///
    /// - Parameters:
    ///   - text: The search text.
    ///   - discipline: An optional discipline filter.
    ///   - page: The page number for pagination.
    ///   - perPage: The number of results per page.
    /// - Returns: An array of TypeCase objects matching the search criteria.
    /// - Throws: A FirestoreError if the search fails or no results are found.
    func searchCases(with text: String, withDiscipline discipline: Discipline? = nil, page: Int, perPage: Int) async throws -> [TypeCase] {
        
        var filter: String?
        
        if let discipline {
            filter = "discipline:=\(discipline.rawValue)"
        }
        
        let searchParameters = SearchParameters(q: text, queryBy: "title, content", filterBy: filter, numTypos: 0, page: page, perPage: perPage)
        
        do {
            
            guard NetworkMonitor.shared.isConnected else {
                throw TypesenseError.network
            }
            
            let (data, response) = try await client.collection(name: "cases").documents().search(searchParameters, for: TypeCase.self)
            
            guard let response = response as? HTTPURLResponse, response.statusCode >= 200, response.statusCode <= 300 else {
                throw TypesenseError.server
            }
            
            guard let data = data, let hits = data.hits else {
                throw TypesenseError.empty
            }
            
            var cases: [TypeCase] = []
            
            for hit in hits {
                if let suggestion = hit.document {
                    cases.append(suggestion)
                }
            }
            
            return cases

        } catch let typeSenseError as TypesenseError {
            throw typeSenseError
        } catch {
            throw TypesenseError.unknown
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

