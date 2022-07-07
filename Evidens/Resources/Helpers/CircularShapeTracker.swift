//
//  CircularShapeTracker.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/7/22.
//

import UIKit

class CircularShapeTracker: NSObject {
    
    private var steps: CGFloat
    private var lineWidth: CGFloat = 60
    
    private let shapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        
        shape.strokeColor = primaryColor.cgColor
        shape.lineWidth = 3
        shape.lineCap = CAShapeLayerLineCap.round
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0
        return shape
    }()
    
    private let trackLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = primaryColor.withAlphaComponent(0.3).cgColor
        shape.lineWidth = 3
        shape.lineCap = CAShapeLayerLineCap.round
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }()
    
    private let basicAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        return animation
    }()
    
    init(withSteps steps: CGFloat) {
        self.steps = steps
        super.init()

    }
   
    func addShapeIndicator(in view: UIView) {
        let circularPath = UIBezierPath()
        circularPath.move(to: CGPoint(x: 0, y: 0))
        circularPath.addLine(to: CGPoint(x: 60, y: 0))
        
        trackLayer.path = circularPath.cgPath
        shapeLayer.path = circularPath.cgPath
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
    }
    
    func updateShapeIndicator(toValue: Int, previousValue: Int) {
        basicAnimation.fromValue = CGFloat(previousValue) / steps
        basicAnimation.toValue = CGFloat(toValue) / steps
        shapeLayer.add(basicAnimation, forKey: "basic")
    }
}
