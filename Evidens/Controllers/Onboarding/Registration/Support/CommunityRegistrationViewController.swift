//
//  CommunityRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 14/7/22.
//

import UIKit

class CommunityRegistrationViewController: UIViewController {
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.image = UIImage(named: "xmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18)).withTintColor(primaryColor)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let separatorView : UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Who can join MyEvidens?"
        label.numberOfLines = 0
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "MyEvidens welcomes all health care involved individuals. That includes:"
        label.numberOfLines = 0
        label.textColor = blackColor
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let professionalsView = RegistrationListView(category: "Professionals")
    private let researchersView = RegistrationListView(category: "Research Scientists")
    private let professorsView = RegistrationListView(category: "Professors")
    private let studentsView = RegistrationListView(category: "Students")
    private let retiredView = RegistrationListView(category: "Retired health care professionals")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubviews(dismissButton, separator, separatorView, titleLabel, descriptionLabel, professionalsView, researchersView, professorsView, studentsView, retiredView)
        
        NSLayoutConstraint.activate([
            
            separator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separator.topAnchor.constraint(equalTo: view.topAnchor, constant: 7),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50),
            
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            dismissButton.heightAnchor.constraint(equalToConstant: 30),
            dismissButton.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            professionalsView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            professionalsView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            professionalsView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            
            researchersView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            researchersView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            researchersView.topAnchor.constraint(equalTo: professionalsView.bottomAnchor, constant: 40),
            
            professorsView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            professorsView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            professorsView.topAnchor.constraint(equalTo: researchersView.bottomAnchor, constant: 40),
            
            studentsView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            studentsView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            studentsView.topAnchor.constraint(equalTo: professorsView.bottomAnchor, constant: 40),
            
            retiredView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            retiredView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            retiredView.topAnchor.constraint(equalTo: studentsView.bottomAnchor, constant: 40),
        ])
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
