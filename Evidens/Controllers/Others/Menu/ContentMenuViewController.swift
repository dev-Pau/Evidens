//
//  ContentMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 6/3/24.
//

import UIKit

private let cellReuseIdentifier = "PostMenuCellReuseIdentifier"
private let headerReuseIdentifier = "PostMenuHeaderReuseIdentifier"

protocol ContentMenuViewControllerDelegate: AnyObject {
    func didTapContentKind(_ kind: ContentKind)
    func didDismiss()
}

class ContentMenuViewController: UIViewController {
    
    weak var delegate: ContentMenuViewControllerDelegate?
    private var collectionView: UICollectionView!
    private var backgroundView: UIView!
    private var topCollectionViewAnchorConstrant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(collectionView.frame.height)
    }
    
    private func configure() {
        view.backgroundColor = UIDevice.isPad ? .systemBackground : .clear
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: addLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ContentMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(ContentMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.layer.cornerRadius = 30
        collectionView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if UIDevice.isPad {
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            print(collectionView.frame.height)
        } else {
            backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !UIDevice.isPad {
            topCollectionViewAnchorConstrant.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.collectionView.contentSize.height + 60)
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    private func addLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: ElementKind.sectionHeader, alignment: .top)
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.boundarySupplementaryItems = [header]
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
            strongSelf.delegate?.didDismiss()
            strongSelf.dismiss(animated: false)
            
        }
        
    }
}

extension ContentMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContentMenuHeader
        header.setTitle(AppStrings.SideMenu.create)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ContentKind.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ContentMenuCell
        cell.set(kind: ContentKind.allCases[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let kind = ContentKind.allCases[indexPath.row]
        if UIDevice.isPad {
            dismiss(animated: true) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.didTapContentKind(kind)
            }
        } else {
            delegate?.didTapContentKind(kind)
            handleDismiss()
        }
    }
}
