//
//  ResourcesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/2/24.
//

import UIKit

class ResourcesViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let kindSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let buildLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let buildNumber: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let versionNumber: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let helpTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.font = UIFont.addFont(size: 17.0, scaleStyle: .title3, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let errorTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 13.0, scaleStyle: .title1, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let uiSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private let copyright: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 16.0, scaleStyle: .title3, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.text = AppStrings.Legal.copyright
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Settings.resourcesTitle
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(kindSeparator, kindLabel, buildLabel, buildNumber, versionLabel, versionNumber, separatorView, helpTitle, contentLabel, uiSwitch, errorTitle, copyright)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Settings.verticalPadding),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            kindLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            
            kindSeparator.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: K.Paddings.Settings.verticalPadding),
            kindSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kindSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kindSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            versionLabel.topAnchor.constraint(equalTo: kindSeparator.bottomAnchor, constant: 20),
            versionLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            
            versionNumber.centerYAnchor.constraint(equalTo: versionLabel.centerYAnchor),
            versionNumber.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            buildLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 20),
            buildLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            
            buildNumber.centerYAnchor.constraint(equalTo: buildLabel.centerYAnchor),
            buildNumber.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            separatorView.topAnchor.constraint(equalTo: buildLabel.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            helpTitle.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            helpTitle.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            helpTitle.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
  
            contentLabel.topAnchor.constraint(equalTo: errorTitle.bottomAnchor, constant: 15),
            contentLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            uiSwitch.topAnchor.constraint(equalTo: helpTitle.bottomAnchor, constant: K.Paddings.Settings.verticalPadding),
            uiSwitch.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            errorTitle.centerYAnchor.constraint(equalTo: uiSwitch.centerYAnchor),
            errorTitle.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            errorTitle.trailingAnchor.constraint(equalTo: uiSwitch.leadingAnchor, constant: -10),
            
            copyright.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 40),
            copyright.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        kindLabel.text = AppStrings.Settings.resourcesContent
        versionLabel.text = AppStrings.Debug.version
        buildLabel.text = AppStrings.Debug.build
        
        helpTitle.text = AppStrings.Debug.help
        errorTitle.text = AppStrings.Debug.errorTitle
        contentLabel.text = AppStrings.Debug.errorContent
        
        uiSwitch.isOn = UserDefaults.getReports()
        uiSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        if let infoDictionary = Bundle.main.infoDictionary {
            if let version = infoDictionary["CFBundleShortVersionString"] as? String,
                let build = infoDictionary["CFBundleVersion"] as? String {
                versionNumber.text = "\(version)"
                buildNumber.text = "\(build)"
            }
        }
        
        scrollView.resizeContentSize()
    }
    
    @objc func switchChanged(sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: "reports")
    }
}
