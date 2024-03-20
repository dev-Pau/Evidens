//
//  UIModalPresentationStyle+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 19/3/24.
//

import UIKit

extension UIModalPresentationStyle {
    
    static func getBasePresentationStyle() -> UIModalPresentationStyle {
        return UIDevice.isPad ? .automatic : .fullScreen
    }
}
