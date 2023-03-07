//
//  NewViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/3/23.
//

import UIKit

private let stretchyHeaderReuseIdentifier = "StretchyHeaderReuseIdentifier"
private let newTitleCellReuseIdentifier = "NewTitleCellReuseIdentifier"
private let newContentCellReuseIdentifier = "NewContentCellReuseIdentifier"

class NewViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.buttonSize = .mini
        button.configuration?.baseBackgroundColor = .label.withAlphaComponent(0.7)
        button.configuration?.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.systemBackground)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let barStandardAppearance = UINavigationBarAppearance()

    private var collectionView: UICollectionView!
    private var newsStretchyHeaderView: MEStretchyHeader?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.setNavigationBarHidden(true, animated: true)
        
        //animator.startAnimation()
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /*
        guard let animator = newsStretchyHeaderView?.animator else { return }
        animator.stopAnimation(true)
        if animator.state != .inactive {
            animator.finishAnimation(at: .current)
        }
         */
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        barStandardAppearance.configureWithTransparentBackground()
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = barStandardAppearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func createLayout() -> StretchyNewsHeaderLayout {
        let layout = StretchyNewsHeaderLayout { sectionNumber, env in
            if sectionNumber == 0 {
                // New header
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250)),
                                                                         elementKind: ElementKind.sectionHeader,
                                                                         alignment: .top)
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [header]
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.90), heightDimension: .absolute(180)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 20
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                return section
            }
           
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.interSectionSpacing = 0
        layout.configuration = config
        layout.topBarHeight = topbarHeight - statusBarHeight
        
        return layout
    }
    
    private func configureUI() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.verticalScrollIndicatorInsets.top = 250 - topbarHeight
        collectionView.contentInsetAdjustmentBehavior = .never
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kek")
        collectionView.register(MEStretchyHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: stretchyHeaderReuseIdentifier)
        collectionView.register(NewTitleCell.self, forCellWithReuseIdentifier: newTitleCellReuseIdentifier)
        collectionView.register(NewContentCell.self, forCellWithReuseIdentifier: newContentCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y

        if contentOffsetY >= 250 - topbarHeight + 40 {
            barStandardAppearance.backgroundEffect = UIBlurEffect(style: .dark)
            navigationItem.standardAppearance = self.barStandardAppearance
        } else {
            barStandardAppearance.configureWithTransparentBackground()
            self.navigationItem.standardAppearance = barStandardAppearance
        }
        
        if contentOffsetY < 0 {
            collectionView.verticalScrollIndicatorInsets.top = (250 - topbarHeight) - contentOffsetY
        }
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension NewViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            // Images
            return 3
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: stretchyHeaderReuseIdentifier, for: indexPath) as! MEStretchyHeader
        header.setImageWithStringUrl(imageUrl: "https://firebasestorage.googleapis.com/v0/b/evidens-ec6bd.appspot.com/o/news%2FGlobal%20healthcare_2.jpeg?alt=media&token=41d358b1-91db-4628-9d7b-2754986df2f0")
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newTitleCellReuseIdentifier, for: indexPath) as! NewTitleCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newContentCellReuseIdentifier, for: indexPath) as! NewContentCell
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath)
            cell.backgroundColor = .systemYellow
            return cell
        }
    }
}





class StretchyNewsHeaderLayout: UICollectionViewCompositionalLayout {
    
    var topBarHeight: CGFloat = 0
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        let stickyIndexPath = IndexPath(item: 0, section: 0)
        if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: ElementKind.sectionHeader, at: stickyIndexPath) {
            if !layoutAttributes!.contains(headerAttributes) {
                layoutAttributes?.append(headerAttributes)
            }
        }
        
        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == ElementKind.sectionHeader && attribute.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }
               

                let contentOffsetY = collectionView.contentOffset.y

                if contentOffsetY < 0 {
                
                    let width = UIScreen.main.bounds.width
                    let height = 250 - contentOffsetY
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                } else {
                    
                    //attribute.frame.origin.y = collectionView.contentOffset.y //CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
                    if 250 - contentOffsetY >= topBarHeight {
                        attribute.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250)
                    } else {
                        attribute.frame = CGRect(x: 0, y: contentOffsetY - 250 + topBarHeight, width: UIScreen.main.bounds.width, height: 250)
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

