//
//  CaseGuidelinesViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/12/23.
//

import UIKit

private let guidelineHeaderReuseIdentifier = "GuidelineHeaderReuseIdentifier"
private let guidelineTitleHeaderReuseIdentifier = "GuidelineTitleHeaderReuseIdentifier"
private let guidelineTextCellReuseIdentifier = "GuidelineTextCellReuseIdentifier"
private let guidelineImageCellReuseIdentifier = "GuidelineImageCellReuseIdentifier"
private let guidelineActionCellReuseIdentifier = "GuidelineActionCellReuseIdentifier"
private let guidelineBottomFooterReuseIdentifier = "GuidelineBottomFooterReuseIdentifier"

class BaseGuidelinesViewController: UIViewController {
    
    private let kind: ContentKind
    
    private var collectionView: UICollectionView!
    
    init(kind: ContentKind) {
        self.kind = kind
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
        let appearance = UINavigationBarAppearance.colorAppearance(withColor: primaryColor)
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.standardAppearance = appearance
        
        addNavigationBarLogo(withTintColor: .white)
        
        let button = UIButton(type: .system)
        button.tintAdjustmentMode = .normal
        var configuration = UIButton.Configuration.filled()
        
        configuration.baseBackgroundColor = .black.withAlphaComponent(0.3)
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(systemName: AppStrings.Icons.xmark, withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.scalePreservingAspectRatio(targetSize: CGSize(width: 15, height: 15)).withRenderingMode(.alwaysOriginal).withTintColor(.white)
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .mini
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
        
        button.configuration = configuration
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissVC)))

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(BaseGuidelineHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: guidelineHeaderReuseIdentifier)
        collectionView.register(BaseGuidelineTitleHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: guidelineTitleHeaderReuseIdentifier)
        collectionView.register(BaseGuidelineTextCell.self, forCellWithReuseIdentifier: guidelineTextCellReuseIdentifier)
        collectionView.register(BaseGuidelineImageCell.self, forCellWithReuseIdentifier: guidelineImageCellReuseIdentifier)
        collectionView.register(BaseGuidelineActionCell.self, forCellWithReuseIdentifier: guidelineActionCellReuseIdentifier)
        collectionView.register(BaseGuidelineButtonFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: guidelineBottomFooterReuseIdentifier)
        
        if UIDevice.isPad {
            collectionView.contentInset.bottom = 10
        }
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = StretchyCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: sectionNumber == 0 ? .absolute(140) : .estimated(150))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: ElementKind.sectionHeader, alignment: .top)
            
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: ElementKind.sectionFooter, alignment: .bottom)
            
            var itemSize: NSCollectionLayoutSize!

            if sectionNumber == 0 {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140))
                
            } else if sectionNumber == 1 || sectionNumber == 3 || sectionNumber == 5 || sectionNumber == 8 {

                let heightSize = (sectionNumber == 5 && strongSelf.kind == .post) ? NSCollectionLayoutDimension.fractionalHeight(1) : NSCollectionLayoutDimension.estimated(250)
                
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: heightSize)
            } else if sectionNumber == 2 || sectionNumber == 4 || sectionNumber == 6 {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: UIDevice.isPad ? .absolute(400) : .absolute(250))
            } else {
                itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            }
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            if sectionNumber == 7 && strongSelf.kind == .clinicalCase || sectionNumber == 5 && strongSelf.kind == .post  {
                item.contentInsets.top = 10
            }
            
            let group = (sectionNumber == 7 && strongSelf.kind == .clinicalCase || sectionNumber == 5 && strongSelf.kind == .post) ? NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: UIDevice.isPad ? .fractionalWidth(0.3) : .fractionalWidth(0.5)), subitems: [item]) : NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            
            if sectionNumber == 0 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [header]
            } else if sectionNumber == 1 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [header]
            } else if sectionNumber == 2 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            } else if sectionNumber == 3 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
            } else if sectionNumber == 4 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            } else if sectionNumber == 5 {
                
                switch strongSelf.kind {
                case .post:
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                    section.orthogonalScrollingBehavior = .continuous
                    section.interGroupSpacing = 10
                    section.boundarySupplementaryItems = [header, footer]
                case .clinicalCase:
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                }
            } else if sectionNumber == 6 {
                
                switch strongSelf.kind {
                case .post:
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                    section.boundarySupplementaryItems = [header, footer]
                case .clinicalCase:
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                }
                
            } else if sectionNumber == 7 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [header]
            } else if sectionNumber == 8 {
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
                section.boundarySupplementaryItems = [header, footer]
            }

            return section
        }
        
        return layout
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}

extension BaseGuidelinesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch kind {

        case .post:
            return 6
        case .clinicalCase:
            return 9
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch kind {
            
        case .post:
            if section == 0 {
                return 0
            } else if section == 5 {
                return PostGuideline.allCases.count
            } else {
                return 1
            }
        case .clinicalCase:
            if section == 0 {
                return 0
            } else if section == 7 {
                return CaseGuideline.allCases.count
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineTextCellReuseIdentifier, for: indexPath) as! BaseGuidelineTextCell
            switch kind {
            case .post:
                cell.set(content: AppStrings.Guidelines.Post.benefits)
            case .clinicalCase:
                cell.set(content: AppStrings.Guidelines.Case.benefits)
            }
            return cell
            
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineImageCellReuseIdentifier, for: indexPath) as! BaseGuidelineImageCell

            switch kind {
            case .post:
                cell.set(image: AppStrings.Assets.postGuideline)
            case .clinicalCase:
                cell.set(image: AppStrings.Assets.caseGuideline)
            }
            return cell
            
        } else if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineTextCellReuseIdentifier, for: indexPath) as! BaseGuidelineTextCell
            switch kind {
            case .post:
                cell.set(content: AppStrings.Guidelines.Post.categorize)
            case .clinicalCase:
                cell.set(content: AppStrings.Guidelines.Case.categorize)
            }

            return cell
        } else if indexPath.section == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineImageCellReuseIdentifier, for: indexPath) as! BaseGuidelineImageCell
            cell.set(image: AppStrings.Assets.caseDiscipline)
            return cell
        } else if indexPath.section == 5 {
            switch kind {
                
            case .post:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineActionCellReuseIdentifier, for: indexPath) as! BaseGuidelineActionCell
                cell.configure(PostGuideline.allCases[indexPath.row])
                return cell
            case .clinicalCase:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineTextCellReuseIdentifier, for: indexPath) as! BaseGuidelineTextCell
                cell.set(content: AppStrings.Guidelines.Case.body)
                return cell
            }

        } else if indexPath.section == 6 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineImageCellReuseIdentifier, for: indexPath) as! BaseGuidelineImageCell
            cell.set(image: AppStrings.Assets.caseBody)
            return cell
            
        } else if indexPath.section == 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineActionCellReuseIdentifier, for: indexPath) as! BaseGuidelineActionCell
            cell.configure(CaseGuideline.allCases[indexPath.row])
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: guidelineTextCellReuseIdentifier, for: indexPath) as! BaseGuidelineTextCell
            cell.set(content: AppStrings.Guidelines.Case.privacy)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == ElementKind.sectionHeader {
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: guidelineHeaderReuseIdentifier, for: indexPath) as! BaseGuidelineHeader
                header.set(kind: self.kind)
                return header
            } else if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: guidelineTitleHeaderReuseIdentifier, for: indexPath) as! BaseGuidelineTitleHeader
                header.set(kind: self.kind)
                return header
            } else if indexPath.section == 7 || indexPath.section == 5 && self.kind == .post {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: guidelineTitleHeaderReuseIdentifier, for: indexPath) as! BaseGuidelineTitleHeader
                header.set(title: AppStrings.Guidelines.Case.work)
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: guidelineTitleHeaderReuseIdentifier, for: indexPath) as! BaseGuidelineTitleHeader
                header.set(title: AppStrings.Guidelines.Case.go)
                return header
            }
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: guidelineBottomFooterReuseIdentifier, for: indexPath) as! BaseGuidelineButtonFooter
            footer.delegate = self
            return footer
        }
    }
}

extension BaseGuidelinesViewController: BaseGuidelineButtonFooterDelegate {
    func didTapButton() {
        dismiss(animated: true)
    }
}

class StretchyCompositionalLayout: UICollectionViewCompositionalLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == ElementKind.sectionHeader && attribute.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }
                
                if let header = collectionView.supplementaryView(forElementKind: ElementKind.sectionHeader, at: IndexPath(item: 0, section: 0)) as? BaseGuidelineHeader {
                    let contentOffsetY = collectionView.contentOffset.y

                    if contentOffsetY < 0 {

                        let width = UIWindow.visibleScreenWidth
                        let height = 140 - contentOffsetY
                        attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                        header.offsetDidMove(contentOffsetY)
                    }
                }
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
