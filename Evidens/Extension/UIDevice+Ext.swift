//
//  UIDevice+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 30/1/24.
//

import UIKit

extension UIDevice {
    
    static var isPad: Bool {
        return current.userInterfaceIdiom == .pad
    }
}
