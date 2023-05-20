//
//  LocationService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/2/23.
//

import UIKit
import CoreLocation
import MapKit

struct LocationService {
    
    static func findLocations(with text: String, completion: @escaping([Location]) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(text) { places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            
            let locations: [Location] = places.compactMap { place in
                var location = ""
                
                if let locationName = place.name {
                    location += locationName
                }
                
                if let adminRegion = place.administrativeArea {
                    location += ", " + adminRegion
                }
                
               
                if let country = place.country {
                    location += ", " + country
                }
                
                let result = Location(name: location)
                return result

            }
            
            completion(locations)
        }
    }
}
