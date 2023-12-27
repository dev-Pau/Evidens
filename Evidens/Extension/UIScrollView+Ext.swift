//
//  UIScrollView+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit

/// An extension of UIScrollView.
extension UIScrollView {

    /// Resizes the content size of a UIScrollView based on the frames of its subviews, ensuring that it encompasses all subviews.
    func resizeContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        
        self.contentSize = contentRect.size
    }
}
