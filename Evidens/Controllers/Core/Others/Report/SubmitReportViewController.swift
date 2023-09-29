//
//  SubmitReportViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 12/4/23.
//

import UIKit

private let reportHeaderReuseIdentifier = "ReportHeaderReuseIdentifier"
private let reportCellReuseIdentifier = "ReportCellReuseIdentifier"

class SubmitReportViewController: UIViewController {

    private var viewModel: ReportViewModel
    private var collectionView: UICollectionView!

    private lazy var reportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.submit, attributes: container)
        button.addTarget(self, action: #selector(handleContinueReport), for: .touchUpInside)
        return button
    }()
    
    private lazy var reportContextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.background.strokeWidth = 0.4
        button.configuration?.background.strokeColor = separatorColor
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        container.foregroundColor = .label
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.context, attributes: container)
        button.addTarget(self, action: #selector(handleAddContext), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
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
    
    init(viewModel: ReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        addNavigationBarLogo(withImage: AppStrings.Assets.blackLogo, withTintColor: primaryColor)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.register(ReportHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: reportHeaderReuseIdentifier)
        collectionView.register(ReportTargetCell.self, forCellWithReuseIdentifier: reportCellReuseIdentifier)
        collectionView.allowsSelection = false
        
        view.addSubviews(collectionView, reportButton, reportContextButton)
        NSLayoutConstraint.activate([
            
            reportButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportButton.heightAnchor.constraint(equalToConstant: 50),
            
            reportContextButton.bottomAnchor.constraint(equalTo: reportButton.topAnchor, constant: -10),
            reportContextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reportContextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reportContextButton.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: reportContextButton.topAnchor, constant: -10)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func handleContinueReport() {
        showProgressIndicator(in: view)
        viewModel.addReport { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let popupView = PopUpBanner(title: AppStrings.PopUp.reportSent, image: AppStrings.Icons.checkmarkCircleFill, popUpKind: .regular)
                popupView.showTopPopup(inView: strongSelf.view)
                strongSelf.dismiss(animated: true)
            }
        }
    }
    
    @objc func handleAddContext() {
        let controller = AddReportContextViewController(viewModel: viewModel)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension SubmitReportViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reportHeaderReuseIdentifier, for: indexPath) as! ReportHeader
        header.configure(withTitle: AppStrings.Report.Submit.title, withDescription: AppStrings.Report.Submit.content)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let target = viewModel.target, let topic = viewModel.topic else {
            fatalError()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reportCellReuseIdentifier, for: indexPath) as! ReportTargetCell
        cell.configure(withTitle: AppStrings.Report.Submit.summary, withDescription: "\n" + target.title + "\n\n" + topic.title)
        cell.hideSelectionHints()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reportButton.isEnabled = true
    }
}

extension SubmitReportViewController: AddReportContextViewControllerDelegate {
    func didAddReport(_ viewModel: ReportViewModel) {
        self.viewModel = viewModel
    }
}


