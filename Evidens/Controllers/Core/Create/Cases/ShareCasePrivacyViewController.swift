//
//  ShareCaseOverviewViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/12/23.
//

import UIKit

class ShareCasePrivacyViewController: UIViewController {
    
    private let user: User
    private var viewModel: ShareCaseViewModel!
    
    private var scrollView: UIScrollView!
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 17, scaleStyle: .title1, weight: .bold, scales: false)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Actions.share, attributes: container)
        button.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Content.Case.Share.privacyTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Content.Case.Share.privacyContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.or
        label.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var regularView: CasePrivacyView!
    private var anonymousView: CasePrivacyView!
    
    init(user: User, viewModel: ShareCaseViewModel) {
        self.user = user
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance.secondaryAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        addNavigationBarLogo(withTintColor: primaryColor)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        regularView = CasePrivacyView(casePrivacy: .regular, user: user)
        anonymousView = CasePrivacyView(casePrivacy: .anonymous)
        
        view.addSubview(scrollView)
        scrollView.addSubviews(titleLabel, contentLabel, regularView, separatorView, orLabel, anonymousView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            regularView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            regularView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            regularView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            
            orLabel.topAnchor.constraint(equalTo: regularView.bottomAnchor, constant: 10),
            orLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 40),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: regularView.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: regularView.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            anonymousView.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            anonymousView.leadingAnchor.constraint(equalTo: regularView.leadingAnchor),
            anonymousView.trailingAnchor.constraint(equalTo: regularView.trailingAnchor),
        ])
        
        regularView.delegate = self
        anonymousView.delegate = self
        
        regularView.privacyTap()
    }
    
    @objc func didTapShare() {
        showProgressIndicator(in: view)
        CaseService.addCase(viewModel: viewModel) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = ShareCaseReviewViewController()
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

extension ShareCasePrivacyViewController: CasePrivacyViewDelegate {
    func didTapPrivacy(_ view: CasePrivacyView) {
        
        switch view {
        case regularView:
            viewModel.privacy = .regular
            anonymousView.reset()
        case anonymousView:
            viewModel.privacy = .anonymous
            regularView.reset()
        default:
            break
        }
    }
}
