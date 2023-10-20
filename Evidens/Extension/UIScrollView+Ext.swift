//
//  UIScrollView+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit

extension UIScrollView {

    func resizeContentSize() {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        
        self.contentSize = contentRect.size
        
    }
}
