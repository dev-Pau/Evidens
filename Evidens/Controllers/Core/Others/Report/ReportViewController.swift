//
//  ReportInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

class ReportViewController: UIViewController {
    
    private var contentOwnerUid: String
    private var contentId: String
    private var report = Report(dictionary: [:])
 
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let reportImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        return iv
    }()
    
    private let reportTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let reportDescription: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Start Report", attributes: container)
        button.addTarget(self, action: #selector(handleContinueReport), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        report.contentId = contentId
        report.contentOwnerUid = contentOwnerUid
        
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        report.reportOwnerUid = uid
        
        configureNavigationBar()
        configureUI()
    }
    
    init(contentOwnerUid: String, contentId: String) {
        self.contentOwnerUid = contentOwnerUid
        self.contentId = contentId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
         
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let stack = UIStackView(arrangedSubviews: [reportTitle, reportDescription, reportButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, reportImageView)
        
        NSLayoutConstraint.activate([
            reportImageView.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -20),
            reportImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            reportImageView.heightAnchor.constraint(equalToConstant: 50),
            reportImageView.widthAnchor.constraint(equalToConstant: 50),
            
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -40),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40)
        ])
        
        reportTitle.text = "Report"
        reportDescription.text = "Welcome to our report system. We value your feedback and want to ensure that our services meet your needs. To help us achieve this, we need you to answer a few questions so we can better understand what's going on in this account's profile or any of its content shared. You'll also have the option to add more information in your own words.\n\nWe take reports seriously. If we find a rule violation, we'll either ask the owner to remove the content or lock or suspend the account.\n\nYour input is crucial in helping us improve and enhance our services. Rest assured, your responses will be kept confidential and will only be used for research and development purposes. Thank you for taking the time to provide us with your valuable feedback."
    }

    @objc func handleContinueReport() {
        let controller = ReportTargetViewController(report: report)
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
