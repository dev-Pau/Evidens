//
//  UIView+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/6/23.
//

import UIKit

extension UIView {
    
    /// Adds multiple subviews to the current view.
    ///
    /// - Parameter views: The views to add as subviews.
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
    
