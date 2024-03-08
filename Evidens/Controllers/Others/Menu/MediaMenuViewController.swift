//
//  MediaMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/3/24.
//

import UIKit

private let mediaContentFooterReuseIdentifier = "MediaContentFooterReuseIdentifier"
private let mediaCellReuseIdentifier = "MediaCellReuseIdentifier"
private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"

protocol MediaMenuViewControllerDelegate: AnyObject {
    func didTapMediaKind(_ kind: MediaKind)
}

class MediaMenuViewController: UIViewController {
    
    private let user: User
    private let imageKind: ImageKind
    
    weak var delegate: MediaMenuViewControllerDelegate?
    private var collectionView: UICollectionView!
    private var backgroundView: UIView!
    private var topCollectionViewAnchorConstrant: NSLayoutConstraint!
    
    private var kind: MediaKind?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    init(user: User, imageKind: ImageKind) {
        self.user = user
        self.imageKind = imageKind
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        view.backgroundColor = .clear
        backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaContentFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: mediaContentFooterReuseIdentifier)
        collectionView.register(MediaMenuCell.self, forCellWithReuseIdentifier: mediaCellReuseIdentifier)
        collectionView.register(ContentMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(ContentMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.layer.cornerRadius = 30
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        collectionView.addGestureRecognizer(pan)
      
        topCollectionViewAnchorConstrant = collectionView.topAnchor.constraint(equalTo: view.bottomAnchor)
        view.addSubviews(backgroundView, collectionView)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            topCollectionViewAnchorConstrant,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.height)
        ])

        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        topCollectionViewAnchorConstrant.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.collectionView.contentSize.height + 60)
            strongSelf.view.layoutIfNeeded()
        }
    }

    private func addLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: ElementKind.sectionHeader, alignment: .top)
        let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: ElementKind.sectionFooter, alignment: .bottom)
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header, footer]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: collectionView)
        let translationY = translation.y
        
        if sender.state == .ended {
            if translationY > 0 && translationY > collectionView.contentSize.height * 0.3 {
                handleDismiss()
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.collectionView.contentSize.height + 60)
                    strongSelf.view.layoutIfNeeded()
                }
            }
        } else {
            topCollectionViewAnchorConstrant.constant = -(collectionView.contentSize.height + 60 - translationY * 0.3)
        }
    }
   
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.backgroundColor = .clear
            strongSelf.topCollectionViewAnchorConstrant.constant = 0
            strongSelf.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.dismiss(animated: false)

            if let kind = strongSelf.kind {
                strongSelf.delegate?.didTapMediaKind(kind)
                strongSelf.kind = nil
            }
        }
    }
}

extension MediaMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContentMenuHeader
            header.setTitle(AppStrings.Miscellaneous.media)
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: mediaContentFooterReuseIdentifier, for: indexPath) as! MediaContentFooter
            footer.set(imageKind: imageKind)
            return footer
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch imageKind {
            
        case .profile:
            return user.hasProfileImage ? MediaKind.allCases.count : MediaKind.allCases.count - 1
        case .banner:
            return user.hasBannerImage ? MediaKind.allCases.count : MediaKind.allCases.count - 1
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mediaCellReuseIdentifier, for: indexPath) as! MediaMenuCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ContentMenuCell
            cell.set(media: MediaKind.allCases[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kind = MediaKind.allCases[indexPath.row]
        self.kind = kind
        handleDismiss()
    }
}
