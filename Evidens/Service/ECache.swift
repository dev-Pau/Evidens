//
//  ECache.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/12/23.
//

import Foundation

/// A service used to interface with NSCache.
class ECache: NSObject {
    
    let cache: NSCache<AnyObject, AnyObject>
    static let shared = ECache()
    
    override init() {
        cache = NSCache<AnyObject, AnyObject>()
        super.init()
        cache.delegate = self
    }
    
    /// Saves an object to the cache with the specified key.
    ///
    /// - Parameters:
    ///   - object: The object to be saved.
    ///   - key: The key under which to save the object.
    func saveObject(object: AnyObject, key: AnyObject) {
        cache.setObject(object, forKey: key)
    }
    
    /// Retrieves an object from the cache based on the specified key.
    ///
    /// - Parameter key: The key associated with the desired object.
    /// - Returns: The retrieved object or a default object if not found.
    func getObject(key: AnyObject) -> AnyObject {
        var object: AnyObject = AnyObject.self as AnyObject
        
        if let cachedObject = cache.object(forKey: key) {
            object = cachedObject
        }
        
        return object
    }
    
    /// Removes a single object from the cache based on the specified key.
    ///
    /// - Parameter key: The key associated with the object to be removed.
    func removeSingleObject(key: AnyObject) {
        cache.removeObject(forKey: key)
    }
    
    /// Clears all objects from the cache, effectively destroying it.
    func destroyCache() {
        cache.removeAllObjects()
    }
}

// MARK: - NSDiscardableContent

extension ECache: NSDiscardableContent {
    
    func beginContentAccess() -> Bool { return true }
    
    func endContentAccess() { }
    
    func discardContentIfPossible() { }
    
    func isContentDiscarded() -> Bool { return false }
}

// MARK: - NSCacheDelegate

extension ECache: NSCacheDelegate {
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let _ = obj as? BaseLink { }
    }
}
