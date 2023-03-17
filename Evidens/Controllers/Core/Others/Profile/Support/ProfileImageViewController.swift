//
//  ProfileImageViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/11/21.
//

import UIKit

class ProfileImageViewController: UIViewController {
    
    //MARK: - Properties
    
    private var isBanner: Bool
    
    init (isBanner: Bool) {
        self.isBanner = isBanner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        iv.addGestureRecognizer(pan)
        return iv
    }()
    
    private lazy var dismissButon: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = .white.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        configureUI()
    }

    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        
        view.addSubviews(profileImageView, dismissButon)
        
        NSLayoutConstraint.activate([
            dismissButon.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            dismissButon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dismissButon.heightAnchor.constraint(equalToConstant: 35),
            dismissButon.widthAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
        ])
       
        if !isBanner {
            profileImageView.image = UIImage(named: "user.profile")
            let height = view.frame.width * 0.8
            NSLayoutConstraint.activate([
                profileImageView.heightAnchor.constraint(equalToConstant: height),
                profileImageView.widthAnchor.constraint(equalToConstant: height)
            ])
         
            profileImageView.layer.cornerRadius = height / 2
        } else {
            profileImageView.backgroundColor = primaryColor.withAlphaComponent(0.5)
            let height = view.frame.width / 3
            NSLayoutConstraint.activate([
                profileImageView.heightAnchor.constraint(equalToConstant: height),
                profileImageView.widthAnchor.constraint(equalToConstant: view.frame.width)
            ])
        }
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: profileImageView)

        let velocity = sender.velocity(in: profileImageView)
        
        let alpha = max(1 - (abs(translation.y) / 1000), 0.85)
        
        profileImageView.frame.origin = CGPoint(x: profileImageView.frame.origin.x , y: view.frame.height / 2 - profileImageView.frame.height / 2 + translation.y)
        view.backgroundColor = .black.withAlphaComponent(alpha)
        
        if sender.state == .ended {
            if abs(velocity.y) > 2000 {
                
                UIView.animate(withDuration: 0.2) {
                    if velocity.y < 0 {
                        self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: -self.profileImageView.frame.height)
                        self.view.backgroundColor = .clear
                    } else {
                        self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: self.view.frame.height + self.profileImageView.frame.height)
                        self.view.backgroundColor = .clear
                    }
                } completion: { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.profileImageView.frame.origin = CGPoint(x: self.profileImageView.frame.origin.x, y: self.view.frame.height / 2 - self.profileImageView.frame.height / 2)
                    self.view.backgroundColor = .black
                }
            }
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .clear
            self.profileImageView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

