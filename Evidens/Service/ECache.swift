//
//  ECache.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 17/12/23.
//

import Foundation

class ECache: NSObject {
   
    let cache: NSCache<AnyObject, AnyObject>
    static let shared = ECache()
    
    override init() {
        cache = NSCache<AnyObject, AnyObject>()
        super.init()
        cache.delegate = self
    }
    
    func saveObject(object: AnyObject, key: AnyObject) {
        cache.setObject(object, forKey: key)
        print("saved")
    }
    
    func getObject(key: AnyObject) -> AnyObject {
        var object: AnyObject = AnyObject.self as AnyObject
        
        if let cachedObject = cache.object(forKey: key) {
            object = cachedObject
        }
       
        print(object)
        
        return object
    }
    
    func removeSingleObject(key:AnyObject) {
        cache.removeObject(forKey: key)
      }
      
      func destroyCache() {
        cache.removeAllObjects()
      }
}

extension ECache: NSDiscardableContent {
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
    }
    
    func discardContentIfPossible() {
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}

extension ECache: NSCacheDelegate {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let link = obj as? BaseLink {
            print("Cache with \(link.url) will get removed")
        }
    }
}
