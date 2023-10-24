//
//  BodyCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/10/23.
//

import UIKit

protocol BodyCellDegate: AnyObject {
    func didTapBody(_ body: Body, _ orientation: BodyOrientation)
}

class BodyCell: UICollectionViewCell {
    
    weak var delegate: BodyCellDegate?
    
    var bodyOrientation: BodyOrientation? {
        didSet {
            configureBodyImage()
        }
    }
    
    private var bodyImage: UIImageView!
    
    private var lineWidth: CGFloat = 1.5
    
    private var headView: UIView!
    private var upperLeftChestView: UIView!
    private var upperRightChestView: UIView!
    
    private var lowerLeftChestView: UIView!
    private var lowerRightChestView: UIView!
    
    private var upperStomachView: UIView!
    private var lowerStomachView: UIView!
    
    private var upperLeftKneeView: UIView!
    private var upperRightKneeView: UIView!
    
    private var lowerLeftKneeView: UIView!
    private var lowerRightKneeView: UIView!
    
    private var upperLeftFeetView: UIView!
    private var upperRightFeetView: UIView!
    
    private var lowerLeftFeetView: UIView!
    private var lowerRightFeetView: UIView!
    
    private var leftArmView: UIView!
    private var rightArmView: UIView!
    
    private var leftHandView: UIView!
    private var rightHandView: UIView!
    
    private var bodyViews: [UIView]!
    
    
    private var loaded: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        bodyImage = UIImageView()
        bodyImage.clipsToBounds = true
        bodyImage.translatesAutoresizingMaskIntoConstraints = false
        bodyImage.contentMode = .scaleAspectFill
        bodyImage.isUserInteractionEnabled = false
        
        headView = UIView()
        headView.layer.borderColor = UIColor.label.cgColor
        headView.layer.borderWidth = lineWidth
        headView.translatesAutoresizingMaskIntoConstraints = false
        headView.backgroundColor = .clear
        //headView.isHidden = true
        headView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        headView.isUserInteractionEnabled = true
        
        upperLeftChestView = UIView()
        upperLeftChestView.layer.borderColor = UIColor.label.cgColor
        upperLeftChestView.layer.borderWidth = lineWidth
        upperLeftChestView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftChestView.backgroundColor = .clear
        //upperLeftChestView.isHidden = true
        upperLeftChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightChestView = UIView()
        upperRightChestView.layer.borderColor = UIColor.label.cgColor
        upperRightChestView.layer.borderWidth = lineWidth
        upperRightChestView.translatesAutoresizingMaskIntoConstraints = false
        upperRightChestView.backgroundColor = .clear
        //upperRightChestView.isHidden = true
        upperRightChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftChestView = UIView()
        lowerLeftChestView.layer.borderColor = UIColor.label.cgColor
        lowerLeftChestView.layer.borderWidth = lineWidth
        lowerLeftChestView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftChestView.backgroundColor = .clear
        //lowerLeftChestView.isHidden = true
        lowerLeftChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightChestView = UIView()
        lowerRightChestView.layer.borderColor = UIColor.label.cgColor
        lowerRightChestView.layer.borderWidth = lineWidth
        lowerRightChestView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightChestView.backgroundColor = .clear
        //lowerRightChestView.isHidden = true
        lowerRightChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperStomachView = UIView()
        upperStomachView.layer.borderColor = UIColor.label.cgColor
        upperStomachView.layer.borderWidth = lineWidth
        upperStomachView.translatesAutoresizingMaskIntoConstraints = false
        upperStomachView.backgroundColor = .clear
        //upperStomachView.isHidden = true
        upperStomachView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerStomachView = UIView()
        lowerStomachView.layer.borderColor = UIColor.label.cgColor
        lowerStomachView.layer.borderWidth = lineWidth
        lowerStomachView.translatesAutoresizingMaskIntoConstraints = false
        lowerStomachView.backgroundColor = .clear
        //lowerStomachView.isHidden = true
        lowerStomachView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperLeftKneeView = UIView()
        upperLeftKneeView.layer.borderColor = UIColor.label.cgColor
        upperLeftKneeView.layer.borderWidth = lineWidth
        upperLeftKneeView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftKneeView.backgroundColor = .clear
        //upperLeftKneeView.isHidden = true
        upperLeftKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightKneeView = UIView()
        upperRightKneeView.layer.borderColor = UIColor.label.cgColor
        upperRightKneeView.layer.borderWidth = lineWidth
        upperRightKneeView.translatesAutoresizingMaskIntoConstraints = false
        upperRightKneeView.backgroundColor = .clear
        //upperRightKneeView.isHidden = true
        upperRightKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftKneeView = UIView()
        lowerLeftKneeView.layer.borderColor = UIColor.label.cgColor
        lowerLeftKneeView.layer.borderWidth = lineWidth
        lowerLeftKneeView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftKneeView.backgroundColor = .clear
        //lowerLeftKneeView.isHidden = true
        lowerLeftKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightKneeView = UIView()
        lowerRightKneeView.layer.borderColor = UIColor.label.cgColor
        lowerRightKneeView.layer.borderWidth = lineWidth
        lowerRightKneeView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightKneeView.backgroundColor = .clear
        //lowerRightKneeView.isHidden = true
        lowerRightKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperLeftFeetView = UIView()
        upperLeftFeetView.layer.borderColor = UIColor.label.cgColor
        upperLeftFeetView.layer.borderWidth = lineWidth
        upperLeftFeetView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftFeetView.backgroundColor = .clear
        //upperLeftFeetView.isHidden = true
        upperLeftFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightFeetView = UIView()
        upperRightFeetView.layer.borderColor = UIColor.label.cgColor
        upperRightFeetView.layer.borderWidth = lineWidth
        upperRightFeetView.translatesAutoresizingMaskIntoConstraints = false
        upperRightFeetView.backgroundColor = .clear
        //upperRightFeetView.isHidden = true
        upperRightFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftFeetView = UIView()
        lowerLeftFeetView.layer.borderColor = UIColor.label.cgColor
        lowerLeftFeetView.layer.borderWidth = lineWidth
        lowerLeftFeetView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftFeetView.backgroundColor = .clear
        //lowerLeftFeetView.isHidden = true
        lowerLeftFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightFeetView = UIView()
        lowerRightFeetView.layer.borderColor = UIColor.label.cgColor
        lowerRightFeetView.layer.borderWidth = lineWidth
        lowerRightFeetView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightFeetView.backgroundColor = .clear
        //lowerRightFeetView.isHidden = true
        lowerRightFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        leftArmView = UIView()
        leftArmView.layer.borderColor = UIColor.label.cgColor
        leftArmView.layer.borderWidth = lineWidth
        leftArmView.translatesAutoresizingMaskIntoConstraints = false
        leftArmView.backgroundColor = .clear
        //leftArmView.isHidden = true
        leftArmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        rightArmView = UIView()
        rightArmView.layer.borderColor = UIColor.label.cgColor
        rightArmView.layer.borderWidth = lineWidth
        rightArmView.translatesAutoresizingMaskIntoConstraints = false
        rightArmView.backgroundColor = .clear
        //rightArmView.isHidden = true
        rightArmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        leftHandView = UIView()
        leftHandView.layer.borderColor = UIColor.label.cgColor
        leftHandView.layer.borderWidth = lineWidth
        leftHandView.translatesAutoresizingMaskIntoConstraints = false
        leftHandView.backgroundColor = .clear
        //leftHandView.isHidden = true
        leftHandView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        rightHandView = UIView()
        rightHandView.layer.borderColor = UIColor.label.cgColor
        rightHandView.layer.borderWidth = lineWidth
        rightHandView.translatesAutoresizingMaskIntoConstraints = false
        rightHandView.backgroundColor = .clear
        //rightHandView.isHidden = true
        rightHandView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
       
        addSubview(bodyImage)
        addSubview(headView)
        addSubview(upperLeftChestView)
        addSubview(upperRightChestView)
        addSubview(lowerRightChestView)
        addSubview(lowerLeftChestView)
        addSubview(upperStomachView)
        addSubview(lowerStomachView)
        addSubview(upperLeftKneeView)
        addSubview(upperRightKneeView)
        addSubview(lowerLeftKneeView)
        addSubview(lowerRightKneeView)
        addSubview(upperLeftFeetView)
        addSubview(upperRightFeetView)
        addSubview(lowerLeftFeetView)
        addSubview(lowerRightFeetView)
        addSubview(leftArmView)
        addSubview(rightArmView)
        addSubview(leftHandView)
        addSubview(rightHandView)
     
        bodyViews = [headView, upperLeftChestView, upperRightChestView, lowerLeftChestView, lowerRightChestView, upperStomachView, lowerStomachView, upperLeftKneeView, upperRightKneeView, lowerLeftKneeView, lowerRightKneeView, upperLeftFeetView, upperRightFeetView, lowerLeftFeetView, lowerRightFeetView, leftArmView, rightArmView, leftHandView, rightHandView]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
            configureBodyTintImage()
            bodyViews.forEach { $0.layer.borderColor = UIColor.label.cgColor }
        }
    }
    
    private func configureBodyTintImage() {
        guard let bodyOrientation = bodyOrientation else { return }
        
        if traitCollection.userInterfaceStyle == .light {
            switch bodyOrientation {
                
            case .front:
                bodyImage.image = UIImage(named: AppStrings.Assets.blackFrontBody)?.scalePreservingAspectRatio(targetSize: CGSize(width: frame.width - 40, height: frame.height - 40))
            case .back:
                bodyImage.image = UIImage(named: AppStrings.Assets.blackBackBody)?.scalePreservingAspectRatio(targetSize: CGSize(width: frame.width - 40, height: frame.height - 40))
            }
        } else {
            switch bodyOrientation {
            case .front:
                bodyImage.image = UIImage(named: AppStrings.Assets.whiteFrontBody)?.scalePreservingAspectRatio(targetSize: CGSize(width: frame.width - 40, height: frame.height - 40))
            case .back:
                bodyImage.image = UIImage(named: AppStrings.Assets.whiteBackBody)?.scalePreservingAspectRatio(targetSize: CGSize(width: frame.width - 40, height: frame.height - 40))
            }
        }
    }
    
    
    private func configureBodyImage() {
        guard !loaded else { return }
        configureBodyTintImage()
    
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureViews()
        }
        
        loaded = true
    }
    
    private func configureViews() {
        NSLayoutConstraint.activate([
            bodyImage.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            bodyImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            bodyImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bodyImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            headView.topAnchor.constraint(equalTo: bodyImage.topAnchor, constant: -10),
            headView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.head.height + 10),
            headView.centerXAnchor.constraint(equalTo: bodyImage.centerXAnchor),
            headView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.head.width),
            
            upperLeftChestView.topAnchor.constraint(equalTo: headView.bottomAnchor, constant: -lineWidth),
            upperLeftChestView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.rightShoulder.height),
            upperLeftChestView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            upperLeftChestView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightShoulder.width / 2),
            
            upperRightChestView.topAnchor.constraint(equalTo: headView.bottomAnchor, constant: -lineWidth),
            upperRightChestView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.leftShoulder.height),
            upperRightChestView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            upperRightChestView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftShoulder.width / 2),
            
            lowerLeftChestView.topAnchor.constraint(equalTo: upperLeftChestView.bottomAnchor, constant: -lineWidth),
            lowerLeftChestView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.rightChest.height),
            lowerLeftChestView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            lowerLeftChestView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightChest.width / 2),
            
            lowerRightChestView.topAnchor.constraint(equalTo: upperLeftChestView.bottomAnchor, constant: -lineWidth),
            lowerRightChestView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.leftChest.height),
            lowerRightChestView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            lowerRightChestView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftChest.width / 2),
            
            upperStomachView.topAnchor.constraint(equalTo: lowerRightChestView.bottomAnchor, constant: -lineWidth),
            upperStomachView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.stomach.height),
            upperStomachView.centerXAnchor.constraint(equalTo: bodyImage.centerXAnchor),
            upperStomachView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.stomach.width - lineWidth),
            
            lowerStomachView.topAnchor.constraint(equalTo: upperStomachView.bottomAnchor, constant: -lineWidth),
            lowerStomachView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.hips.height),
            lowerStomachView.centerXAnchor.constraint(equalTo: bodyImage.centerXAnchor),
            lowerStomachView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.hips.width - lineWidth),
            
            upperLeftKneeView.topAnchor.constraint(equalTo: lowerStomachView.bottomAnchor, constant: -lineWidth),
            upperLeftKneeView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.rightThigh.height),
            upperLeftKneeView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            upperLeftKneeView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightThigh.width / 2),
            
            upperRightKneeView.topAnchor.constraint(equalTo: lowerStomachView.bottomAnchor, constant: -lineWidth),
            upperRightKneeView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.leftThigh.height),
            upperRightKneeView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            upperRightKneeView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftThigh.width / 2),
            
            lowerLeftKneeView.topAnchor.constraint(equalTo: upperRightKneeView.bottomAnchor, constant: -lineWidth),
            lowerLeftKneeView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.rightKnee.height),
            lowerLeftKneeView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            lowerLeftKneeView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightKnee.width / 2),
            
            lowerRightKneeView.topAnchor.constraint(equalTo: upperRightKneeView.bottomAnchor, constant: -lineWidth),
            lowerRightKneeView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.leftKnee.height),
            lowerRightKneeView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            lowerRightKneeView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftKnee.width / 2),
            
            upperLeftFeetView.topAnchor.constraint(equalTo: lowerLeftKneeView.bottomAnchor, constant: -lineWidth),
            upperLeftFeetView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.rightShin.height),
            upperLeftFeetView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            upperLeftFeetView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightShin.width / 2),
            
            upperRightFeetView.topAnchor.constraint(equalTo: lowerLeftKneeView.bottomAnchor, constant: -lineWidth),
            upperRightFeetView.heightAnchor.constraint(equalToConstant: bodyImage.frame.height * Body.leftShin.height),
            upperRightFeetView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            upperRightFeetView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftShin.width / 2),
            
            lowerLeftFeetView.topAnchor.constraint(equalTo: upperRightFeetView.bottomAnchor, constant: -lineWidth),
            lowerLeftFeetView.bottomAnchor.constraint(equalTo: bodyImage.bottomAnchor, constant: 10),
            lowerLeftFeetView.trailingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: lineWidth / 2),
            lowerLeftFeetView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.rightFoot.width / 2),
            
            lowerRightFeetView.topAnchor.constraint(equalTo: upperRightFeetView.bottomAnchor, constant: -lineWidth),
            lowerRightFeetView.bottomAnchor.constraint(equalTo: bodyImage.bottomAnchor, constant: 10),
            lowerRightFeetView.leadingAnchor.constraint(equalTo: bodyImage.centerXAnchor, constant: -lineWidth / 2),
            lowerRightFeetView.widthAnchor.constraint(equalToConstant: bodyImage.frame.width * Body.leftFoot.width / 2),
            
            leftArmView.topAnchor.constraint(equalTo: upperLeftChestView.bottomAnchor, constant: -lineWidth),
            leftArmView.leadingAnchor.constraint(equalTo: upperLeftChestView.leadingAnchor),
            leftArmView.trailingAnchor.constraint(equalTo: lowerLeftChestView.leadingAnchor, constant: lineWidth),
            leftArmView.bottomAnchor.constraint(equalTo: upperStomachView.bottomAnchor),
            
            rightArmView.topAnchor.constraint(equalTo: upperRightChestView.bottomAnchor, constant: -lineWidth),
            rightArmView.leadingAnchor.constraint(equalTo: lowerRightChestView.trailingAnchor, constant: -lineWidth),
            rightArmView.trailingAnchor.constraint(equalTo: upperRightChestView.trailingAnchor),
            rightArmView.bottomAnchor.constraint(equalTo: upperStomachView.bottomAnchor),
            
            leftHandView.topAnchor.constraint(equalTo: leftArmView.bottomAnchor, constant: -lineWidth),
            leftHandView.leadingAnchor.constraint(equalTo: bodyImage.leadingAnchor, constant: -20),
            leftHandView.trailingAnchor.constraint(equalTo: lowerStomachView.leadingAnchor, constant: lineWidth),
            leftHandView.bottomAnchor.constraint(equalTo: lowerStomachView.bottomAnchor, constant: 10),
            
            rightHandView.topAnchor.constraint(equalTo: rightArmView.bottomAnchor, constant: -lineWidth),
            rightHandView.trailingAnchor.constraint(equalTo: bodyImage.trailingAnchor, constant: 20),
            rightHandView.leadingAnchor.constraint(equalTo: lowerStomachView.trailingAnchor, constant: -lineWidth),
            rightHandView.bottomAnchor.constraint(equalTo: lowerStomachView.bottomAnchor, constant: 10)
        ])
    }
    
    @objc func bodyTap(_ sender: UITapGestureRecognizer) {
        
        guard let tappedView = sender.view, let index = bodyViews.firstIndex(of: tappedView), let body = Body(rawValue: index), let bodyOrientation = bodyOrientation else {
            return
        }
        
        delegate?.didTapBody(body, bodyOrientation)
    }
}
