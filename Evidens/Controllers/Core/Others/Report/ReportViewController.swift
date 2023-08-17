//
//  ReportInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

class ReportViewController: UIViewController {

    private var report: Report
 
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let unhappyImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: AppStrings.Assets.blackUnhappyLogo)?.withTintColor(.label)
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
        button.configuration?.attributedTitle = AttributedString(AppStrings.Report.Opening.start, attributes: container)
        button.addTarget(self, action: #selector(handleContinueReport), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        navigationBarAppearance.configureWithOpaqueBackground()
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        navigationBarAppearance.backButtonAppearance = barButtonItemAppearance
        
        navigationBarAppearance.shadowColor = separatorColor
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
    }
    
    init(source: ReportSource, contentUid: String, contentId: String) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            fatalError()
        }
        
        report = Report(contentId: contentId, contentUid: contentUid, uid: uid, source: source)
        print(report)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))

        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        //addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        view.addSubview(scrollView)
        
        scrollView.frame = view.bounds
        
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let stack = UIStackView(arrangedSubviews: [reportTitle, reportDescription, reportButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, unhappyImage)
        
        NSLayoutConstraint.activate([
            unhappyImage.bottomAnchor.constraint(equalTo: stack.topAnchor, constant: -20),
            unhappyImage.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            unhappyImage.heightAnchor.constraint(equalToConstant: 80),
            unhappyImage.widthAnchor.constraint(equalToConstant: 80),
            
            stack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -topbarHeight),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: view.frame.width - 40)
        ])
        
        reportTitle.text = AppStrings.Report.Opening.title
        reportDescription.text = AppStrings.Report.Opening.content
    }

    @objc func handleContinueReport() {
        let controller = ReportTargetViewController(report: report)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
