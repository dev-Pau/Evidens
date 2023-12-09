//
//  QuarterCircleView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/12/23.
//

import UIKit

class QuarterCircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if layer.sublayers == nil {
            let lay = CAShapeLayer()
            lay.fillColor = primaryColor.cgColor
            layer.addSublayer(lay)
        }
        if let lay = layer.sublayers?.first as? CAShapeLayer {
            let bez  = UIBezierPath()
            bez.move(to: CGPoint(x: 0, y: 0))
            
            bez.addLine(to: CGPoint(x: bounds.maxX + 20, y: 0))
            
            bez.addQuadCurve(to: CGPoint(x: bounds.midX / 2 + 30, y: bounds.maxY), controlPoint: CGPoint(x: bounds.maxX - 50, y: bounds.maxY))

            bez.addQuadCurve(to: CGPoint(x: -25, y: bounds.maxY - 50), controlPoint: CGPoint(x: bounds.minX, y: bounds.maxY))
            bez.addLine(to: CGPoint(x: 0, y: 0))
            
            lay.path = bez.cgPath
        }
    }
}
