//
//  ImageRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit

class ImageRegistrationViewController: UIViewController {
    
    private let user: User
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let profileImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "user")?.scalePreservingAspectRatio(targetSize: CGSize(width: 48, height: 68)).withTintColor(grayColor)
        button.configuration?.baseBackgroundColor = lightColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Account details"
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        scrollView.addSubview(profileImageButton)
        
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            profileImageButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 200),
            profileImageButton.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
}
