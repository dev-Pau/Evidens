//
//  CasesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/7/22.
//

import UIKit

class CasesViewController: UIViewController {
    
    private let testValues = [1, 2, 3, 4, 5, 4, 3, 2 ,3, 4, 5 ,6, 7, 8, 9, 10]
    private var index: Int = 0
    
    private var circularView = UIView()
    
    private var circularShapeTracker = CircularShapeTracker(withSteps: CGFloat(10))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(circularView)
        circularView.setDimensions(height: 50, width: 50)
        circularView.backgroundColor = .systemGray
        circularView.centerY(inView: view)
        circularView.centerX(inView: view)
        
        
        circularShapeTracker.addShapeIndicator(in: circularView)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        /*
        
        let center = view.center
        
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 2, clockwise: true)
        
        
        
        shapeLayer.path = circularPath.cgPath
        trackLayer.path = circularPath.cgPath
         
        
        trackLayer.strokeColor = primaryColor.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(trackLayer)
        
        
        
       
        
        shapeLayer.strokeColor = primaryColor.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.strokeEnd = 0
        
        
        view.layer.addSublayer(shapeLayer)
        
        
         
    }
    
    
    
    */
    }
    
    @objc func handleTap() {
        if index == 0 {
            circularShapeTracker.updateShapeIndicator(toValue: testValues[index], previousValue: 0)
        } else {
            circularShapeTracker.updateShapeIndicator(toValue: testValues[index], previousValue: testValues[index - 1])
        }
        
        index += 1
        /*
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = fromValue
        fromValue += 1/10
        basicAnimation.toValue = fromValue
        
        
        
        basicAnimation.duration = 0.1
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "basic")
         */
    }
}
