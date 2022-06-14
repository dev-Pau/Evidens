//
//  MEImagesGridView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/6/22.
//

import UIKit

class MEImagesGridView: UIView {
    
    private var images: [UIImage] = []
    private var screenWidth : CGFloat = 0
    //private let postImages: [MEPostImage] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(images: [UIImage], screenWidth: CGFloat) {
        super.init(frame: .zero)
        self.images = images
        self.screenWidth = screenWidth
        configure()
    }
    
    private func configure() {
      
        switch images.count {
        case 2:
            addTwoImagesToPost()
        case 3:
            addThreeImagesToPost()
        case 4:
            addForImagesToPost()
        default:
            print("DEfault case \(images.count)")
            break
        }
    }
    
    func addTwoImagesToPost() {
        let firstImage = MEPostImage(image: images[0])
        let secondImage = MEPostImage(image: images[1])
        
        firstImage.layer.cornerRadius = 10
        secondImage.layer.cornerRadius = 10
        firstImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        secondImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        
        addSubview(firstImage)
        addSubview(secondImage)
        
        NSLayoutConstraint.activate([
            firstImage.topAnchor.constraint(equalTo: self.topAnchor),
            firstImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            firstImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            firstImage.widthAnchor.constraint(equalToConstant: screenWidth / 2),
            
            secondImage.topAnchor.constraint(equalTo: self.topAnchor),
            secondImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            secondImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            secondImage.widthAnchor.constraint(equalToConstant: screenWidth / 2)
        ])
    }
    
    func addThreeImagesToPost() {
        let firstImage = MEPostImage(image: images[0])
        let secondImage = MEPostImage(image: images[1])
        let thirdImage = MEPostImage(image: images[2])
        
        firstImage.layer.cornerRadius = 10
        secondImage.layer.cornerRadius = 10
        thirdImage.layer.cornerRadius = 10
        
        firstImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        secondImage.layer.maskedCorners = [.layerMinXMaxYCorner]
        thirdImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        
        addSubview(firstImage)
        addSubview(secondImage)
        addSubview(thirdImage)
        
        NSLayoutConstraint.activate([
            firstImage.topAnchor.constraint(equalTo: self.topAnchor),
            firstImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            firstImage.heightAnchor.constraint(equalToConstant: 150),
            firstImage.widthAnchor.constraint(equalToConstant: screenWidth),
            
            secondImage.topAnchor.constraint(equalTo: firstImage.bottomAnchor),
            secondImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            secondImage.heightAnchor.constraint(equalToConstant: 150),
            secondImage.widthAnchor.constraint(equalToConstant: screenWidth / 2),
            
            thirdImage.topAnchor.constraint(equalTo: firstImage.bottomAnchor),
            thirdImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            thirdImage.heightAnchor.constraint(equalToConstant: 150),
            thirdImage.widthAnchor.constraint(equalToConstant: screenWidth / 2)
        ])
    }
    
    func addForImagesToPost() {
        let firstImage = MEPostImage(image: images[0])
        let secondImage = MEPostImage(image: images[1])
        let thirdImage = MEPostImage(image: images[2])
        let fourthImage = MEPostImage(image: images[3])
        
        firstImage.layer.cornerRadius = 10
        secondImage.layer.cornerRadius = 10
        fourthImage.layer.cornerRadius = 10
        
        firstImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        secondImage.layer.maskedCorners = [.layerMinXMaxYCorner]
        fourthImage.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        
        addSubview(firstImage)
        addSubview(secondImage)
        addSubview(thirdImage)
        addSubview(fourthImage)
        
        NSLayoutConstraint.activate([
            firstImage.topAnchor.constraint(equalTo: self.topAnchor),
            firstImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            firstImage.heightAnchor.constraint(equalToConstant: 150),
            firstImage.widthAnchor.constraint(equalToConstant: screenWidth),
            
            secondImage.topAnchor.constraint(equalTo: firstImage.bottomAnchor),
            secondImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            secondImage.heightAnchor.constraint(equalToConstant: 150),
            secondImage.widthAnchor.constraint(equalToConstant: screenWidth / 3),
            
            thirdImage.topAnchor.constraint(equalTo: firstImage.bottomAnchor),
            thirdImage.leadingAnchor.constraint(equalTo: secondImage.trailingAnchor),
            thirdImage.heightAnchor.constraint(equalToConstant: 150),
            thirdImage.widthAnchor.constraint(equalToConstant: screenWidth / 3),
            
            fourthImage.topAnchor.constraint(equalTo: firstImage.bottomAnchor),
            fourthImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            fourthImage.heightAnchor.constraint(equalToConstant: 150),
            fourthImage.widthAnchor.constraint(equalToConstant: screenWidth / 3)
        ])
    }
}

