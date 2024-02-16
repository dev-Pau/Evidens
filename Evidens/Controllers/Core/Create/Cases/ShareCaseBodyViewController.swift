//
//  ShareCaseBodyViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/10/23.
//

import UIKit

class ShareCaseBodyViewController: UIViewController {
    
    private var user: User
    private var viewModel: ShareCaseViewModel
    
    private var loaded = false
    
    private var titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: String())
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 18, scaleStyle: .title2, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()

    private var scrollView: UIScrollView!
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

    private var activityIndicator: UIActivityIndicatorView!
    
    private var switchButton: UIButton!
    private var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureNavigationBar()
    }
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !loaded else { return }
        NSLayoutConstraint.activate([
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
            rightHandView.bottomAnchor.constraint(equalTo: lowerStomachView.bottomAnchor, constant: 10),
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.isHidden = true
            strongSelf.activityIndicator.removeFromSuperview()
            strongSelf.bodyImage.isHidden = false
            strongSelf.bodyViews.forEach { $0.isHidden = false }
            strongSelf.switchButton.isHidden = false
            strongSelf.skipButton.isHidden = false
            strongSelf.loaded = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
            configureBodyImage()
            bodyViews.forEach { $0.layer.borderColor = UIColor.label.cgColor }
        }
    }
    
    private func configureBodyImage() {
        if view.traitCollection.userInterfaceStyle == .light {
            switch viewModel.bodyOrientation {
                
            case .front:
                bodyImage.image = UIImage(named: AppStrings.Assets.blackFrontBody)
            case .back:
                bodyImage.image = UIImage(named: AppStrings.Assets.blackBackBody)
            }
        } else {
            switch viewModel.bodyOrientation {
            case .front:
                bodyImage.image = UIImage(named: AppStrings.Assets.whiteFrontBody)
            case .back:
                bodyImage.image = UIImage(named: AppStrings.Assets.whiteBackBody)
            }
        }
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self
        
        bodyImage = UIImageView()
        bodyImage.clipsToBounds = true
        bodyImage.translatesAutoresizingMaskIntoConstraints = false
        bodyImage.contentMode = .scaleAspectFill
        bodyImage.isUserInteractionEnabled = false
        
        configureBodyImage()
        bodyImage.isHidden = true
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        view.addSubviews(scrollView, nextButton)
        scrollView.addSubviews(titleLabel, activityIndicator)
        
        headView = UIView()
        headView.layer.borderColor = UIColor.label.cgColor
        headView.layer.borderWidth = lineWidth
        headView.translatesAutoresizingMaskIntoConstraints = false
        headView.backgroundColor = .clear
        headView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        headView.isHidden = true

        upperLeftChestView = UIView()
        upperLeftChestView.layer.borderColor = UIColor.label.cgColor
        upperLeftChestView.layer.borderWidth = lineWidth
        upperLeftChestView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftChestView.backgroundColor = .clear
        upperLeftChestView.isHidden = true
        upperLeftChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightChestView = UIView()
        upperRightChestView.layer.borderColor = UIColor.label.cgColor
        upperRightChestView.layer.borderWidth = lineWidth
        upperRightChestView.translatesAutoresizingMaskIntoConstraints = false
        upperRightChestView.backgroundColor = .clear
        upperRightChestView.isHidden = true
        upperRightChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftChestView = UIView()
        lowerLeftChestView.layer.borderColor = UIColor.label.cgColor
        lowerLeftChestView.layer.borderWidth = lineWidth
        lowerLeftChestView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftChestView.backgroundColor = .clear
        lowerLeftChestView.isHidden = true
        lowerLeftChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightChestView = UIView()
        lowerRightChestView.layer.borderColor = UIColor.label.cgColor
        lowerRightChestView.layer.borderWidth = lineWidth
        lowerRightChestView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightChestView.backgroundColor = .clear
        lowerRightChestView.isHidden = true
        lowerRightChestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperStomachView = UIView()
        upperStomachView.layer.borderColor = UIColor.label.cgColor
        upperStomachView.layer.borderWidth = lineWidth
        upperStomachView.translatesAutoresizingMaskIntoConstraints = false
        upperStomachView.backgroundColor = .clear
        upperStomachView.isHidden = true
        upperStomachView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerStomachView = UIView()
        lowerStomachView.layer.borderColor = UIColor.label.cgColor
        lowerStomachView.layer.borderWidth = lineWidth
        lowerStomachView.translatesAutoresizingMaskIntoConstraints = false
        lowerStomachView.backgroundColor = .clear
        lowerStomachView.isHidden = true
        lowerStomachView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperLeftKneeView = UIView()
        upperLeftKneeView.layer.borderColor = UIColor.label.cgColor
        upperLeftKneeView.layer.borderWidth = lineWidth
        upperLeftKneeView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftKneeView.backgroundColor = .clear
        upperLeftKneeView.isHidden = true
        upperLeftKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightKneeView = UIView()
        upperRightKneeView.layer.borderColor = UIColor.label.cgColor
        upperRightKneeView.layer.borderWidth = lineWidth
        upperRightKneeView.translatesAutoresizingMaskIntoConstraints = false
        upperRightKneeView.backgroundColor = .clear
        upperRightKneeView.isHidden = true
        upperRightKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftKneeView = UIView()
        lowerLeftKneeView.layer.borderColor = UIColor.label.cgColor
        lowerLeftKneeView.layer.borderWidth = lineWidth
        lowerLeftKneeView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftKneeView.backgroundColor = .clear
        lowerLeftKneeView.isHidden = true
        lowerLeftKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightKneeView = UIView()
        lowerRightKneeView.layer.borderColor = UIColor.label.cgColor
        lowerRightKneeView.layer.borderWidth = lineWidth
        lowerRightKneeView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightKneeView.backgroundColor = .clear
        lowerRightKneeView.isHidden = true
        lowerRightKneeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperLeftFeetView = UIView()
        upperLeftFeetView.layer.borderColor = UIColor.label.cgColor
        upperLeftFeetView.layer.borderWidth = lineWidth
        upperLeftFeetView.translatesAutoresizingMaskIntoConstraints = false
        upperLeftFeetView.backgroundColor = .clear
        upperLeftFeetView.isHidden = true
        upperLeftFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        upperRightFeetView = UIView()
        upperRightFeetView.layer.borderColor = UIColor.label.cgColor
        upperRightFeetView.layer.borderWidth = lineWidth
        upperRightFeetView.translatesAutoresizingMaskIntoConstraints = false
        upperRightFeetView.backgroundColor = .clear
        upperRightFeetView.isHidden = true
        upperRightFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerLeftFeetView = UIView()
        lowerLeftFeetView.layer.borderColor = UIColor.label.cgColor
        lowerLeftFeetView.layer.borderWidth = lineWidth
        lowerLeftFeetView.translatesAutoresizingMaskIntoConstraints = false
        lowerLeftFeetView.backgroundColor = .clear
        lowerLeftFeetView.isHidden = true
        lowerLeftFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        lowerRightFeetView = UIView()
        lowerRightFeetView.layer.borderColor = UIColor.label.cgColor
        lowerRightFeetView.layer.borderWidth = lineWidth
        lowerRightFeetView.translatesAutoresizingMaskIntoConstraints = false
        lowerRightFeetView.backgroundColor = .clear
        lowerRightFeetView.isHidden = true
        lowerRightFeetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        leftArmView = UIView()
        leftArmView.layer.borderColor = UIColor.label.cgColor
        leftArmView.layer.borderWidth = lineWidth
        leftArmView.translatesAutoresizingMaskIntoConstraints = false
        leftArmView.backgroundColor = .clear
        leftArmView.isHidden = true
        leftArmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        rightArmView = UIView()
        rightArmView.layer.borderColor = UIColor.label.cgColor
        rightArmView.layer.borderWidth = lineWidth
        rightArmView.translatesAutoresizingMaskIntoConstraints = false
        rightArmView.backgroundColor = .clear
        rightArmView.isHidden = true
        rightArmView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        leftHandView = UIView()
        leftHandView.layer.borderColor = UIColor.label.cgColor
        leftHandView.layer.borderWidth = lineWidth
        leftHandView.translatesAutoresizingMaskIntoConstraints = false
        leftHandView.backgroundColor = .clear
        leftHandView.isHidden = true
        leftHandView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        rightHandView = UIView()
        rightHandView.layer.borderColor = UIColor.label.cgColor
        rightHandView.layer.borderWidth = lineWidth
        rightHandView.translatesAutoresizingMaskIntoConstraints = false
        rightHandView.backgroundColor = .clear
        rightHandView.isHidden = true
        rightHandView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTap(_:))))
        
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: AppStrings.Icons.switchArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        switchButton = UIButton(configuration: configuration)
        switchButton.addTarget(self, action: #selector(switchTap), for: .touchUpInside)
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.isHidden = true
        switchButton.tintAdjustmentMode = .normal
        
        var skipConfiguration = UIButton.Configuration.plain()
        skipConfiguration.baseForegroundColor = primaryColor
       
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 14, scaleStyle: .title1, weight: .regular, scales: false)
        skipConfiguration.attributedTitle = AttributedString(AppStrings.Content.Case.Share.bodySkip, attributes: container)
        skipConfiguration.titleAlignment = .trailing
        skipButton = UIButton(configuration: skipConfiguration)
        skipButton.addTarget(self, action: #selector(skipTap), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.isHidden = true
        skipButton.tintAdjustmentMode = .normal
        
        scrollView.addSubview(bodyImage)
        scrollView.addSubview(skipButton)
        scrollView.addSubview(switchButton)
        scrollView.addSubview(headView)
        scrollView.addSubview(upperLeftChestView)
        scrollView.addSubview(upperRightChestView)
        scrollView.addSubview(lowerRightChestView)
        scrollView.addSubview(lowerLeftChestView)
        scrollView.addSubview(upperStomachView)
        scrollView.addSubview(lowerStomachView)
        scrollView.addSubview(upperLeftKneeView)
        scrollView.addSubview(upperRightKneeView)
        scrollView.addSubview(lowerLeftKneeView)
        scrollView.addSubview(lowerRightKneeView)
        scrollView.addSubview(upperLeftFeetView)
        scrollView.addSubview(upperRightFeetView)
        scrollView.addSubview(lowerLeftFeetView)
        scrollView.addSubview(lowerRightFeetView)
        scrollView.addSubview(leftArmView)
        scrollView.addSubview(rightArmView)
        scrollView.addSubview(leftHandView)
        scrollView.addSubview(rightHandView)
        
        let heightToFill = view.frame.height - topbarHeight - 180 - titleLabel.font.lineHeight - view.safeAreaInsets.bottom

        let bodyHeight = heightToFill
        let bodyWidth = heightToFill / 2.33

        NSLayoutConstraint.activate([
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -topbarHeight),
            
            bodyImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            bodyImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            bodyImage.heightAnchor.constraint(equalToConstant: bodyHeight),
            bodyImage.widthAnchor.constraint(equalToConstant: bodyWidth),
            
            switchButton.leadingAnchor.constraint(equalTo: headView.trailingAnchor, constant: 10),
            switchButton.topAnchor.constraint(equalTo: headView.topAnchor),
            
            skipButton.topAnchor.constraint(equalTo: lowerRightFeetView.bottomAnchor, constant: 10),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        bodyViews = [headView, upperLeftChestView, upperRightChestView, lowerLeftChestView, lowerRightChestView, upperStomachView, lowerStomachView, upperLeftKneeView, upperRightKneeView, lowerLeftKneeView, lowerRightKneeView, upperLeftFeetView, upperRightFeetView, lowerLeftFeetView, lowerRightFeetView, leftArmView, rightArmView, leftHandView, rightHandView]
        
        titleLabel.text = AppStrings.Content.Case.Share.bodyTitle
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        addNavigationBarLogo(withTintColor: primaryColor)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }
    
    @objc func handleDismiss() {
        displayAlert(withTitle: AppStrings.Alerts.Title.cancelContent, withMessage: AppStrings.Alerts.Subtitle.cancelContent, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Alerts.Actions.quit, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }
    
    @objc func bodyTap(_ sender: UITapGestureRecognizer) {
        
        guard let tappedView = sender.view, let index = bodyViews.firstIndex(of: tappedView), let selectedPart = Body(rawValue: index) else {
            return
        }
        
        if viewModel.bodyParts.contains(selectedPart) {
            viewModel.bodyParts.removeAll(where: { $0 == selectedPart })
            tappedView.backgroundColor = .clear
        } else {
            if viewModel.canSelectMoreBodyParts {
                viewModel.bodyParts.append(selectedPart)
                tappedView.backgroundColor = .label.withAlphaComponent(0.2)
            }
        }
        
        nextButton.isEnabled = !viewModel.bodyParts.isEmpty
    }
    
    @objc func skipTap() {
        displayAlert(withTitle: AppStrings.Alerts.Title.skipBody, withMessage: AppStrings.Alerts.Subtitle.skipBody, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Global.go, style: .default) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.bodyParts.removeAll()

            let controller = ShareCaseImageViewController(user: strongSelf.user, viewModel: strongSelf.viewModel)
            strongSelf.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func switchTap() {
        switch viewModel.bodyOrientation {
            
        case .front:
            viewModel.bodyOrientation = .back
        case .back:
            viewModel.bodyOrientation = .front
        }
        
        configureBodyImage()
    }
    
    @objc func handleNext() {
        let controller = ShareCaseImageViewController(user: user, viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ShareCaseBodyViewController: UIScrollViewDelegate {
    
}
