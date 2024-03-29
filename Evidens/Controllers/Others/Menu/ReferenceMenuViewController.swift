//
//  ReferenceMenuViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/3/24.
//

import UIKit

private let cellReuseIdentifier = "CellReuseIdentifier"
private let headerReuseIdentifier = "ReferenceHeaderReuseIdentifier"
private let footerReuseIdentifier = "ReferenceFooterReuseIdentifier"
private let referenceCellReuseIdentifier = "ReferenceCellReuseIdentifier"
private let loadingHeaderReuseIdentifier = "LoadingHeaderReuseIdentifier"

protocol ReferenceMenuViewControllerDelegate: AnyObject {
    func didTapReference(reference: Reference)
}

class ReferenceMenuViewController: UIViewController {
    
    private let postId: String
    private let kind: ReferenceKind

    weak var delegate: ReferenceMenuViewControllerDelegate?
    
    private var collectionView: UICollectionView!
    private var backgroundView: UIView!
    private var topCollectionViewAnchorConstrant: NSLayoutConstraint!

    private var reference: Reference? {
        didSet {
            addReference()
        }
    }
    
    private var selectedReference: Reference?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    init(postId: String, kind: ReferenceKind) {
        self.postId = postId
        self.kind = kind
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
        
        collectionView.register(LoadingHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: loadingHeaderReuseIdentifier)
        collectionView.register(ContentMenuHeader.self, forSupplementaryViewOfKind: ElementKind.sectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView.register(ContextMenuFooter.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: footerReuseIdentifier)
        
        collectionView.register(ReferenceCell.self, forCellWithReuseIdentifier: referenceCellReuseIdentifier)
        collectionView.register(ContextMenuCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.isScrollEnabled = false
        collectionView.layer.cornerRadius = 35
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
            collectionView.heightAnchor.constraint(equalToConstant: view.frame.height),
        ])
        
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        topCollectionViewAnchorConstrant.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.view.frame.height * 0.2)
            strongSelf.view.layoutIfNeeded()
        } completion: { [weak self] _  in
            guard let strongSelf = self else { return }
            
            PostService.fetchReference(forPostId: strongSelf.postId, forReferenceKind: strongSelf.kind) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                    
                case .success(let reference):
                    strongSelf.reference = reference
                case .failure(_):
                    break
                }
            }
        }
    }

    private func addLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: ElementKind.sectionHeader, alignment: .top)
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: ElementKind.sectionFooter, alignment: .bottom)
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            if let _ = strongSelf.reference {
                section.boundarySupplementaryItems = [header, footer]
            } else {
                section.boundarySupplementaryItems = [header]
            }

            return section
        }
        return layout
    }
    
    private func addReference() {
        collectionView.reloadData()
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.collectionView.contentSize.height)
            strongSelf.view.layoutIfNeeded()
        }
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
                    strongSelf.topCollectionViewAnchorConstrant.constant = -(strongSelf.collectionView.contentSize.height)
                    strongSelf.view.layoutIfNeeded()
                }
            }
        } else {
            topCollectionViewAnchorConstrant.constant = -(collectionView.contentSize.height - translationY * 0.3)
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
            
            if let reference = strongSelf.selectedReference {
                strongSelf.delegate?.didTapReference(reference: reference)
            }
        }
    }
}

extension ReferenceMenuViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == ElementKind.sectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as!
            ContextMenuFooter
            footer.delegate = self
            footer.set(reference: reference)
            return footer
        } else {
            if let _ = reference {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! ContentMenuHeader
                header.set(reference: reference)
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: loadingHeaderReuseIdentifier, for: indexPath) as! LoadingHeader
                return header
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _ = reference {
            return 2
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ContextMenuCell
            if let reference = reference { cell.configure(withDescription: reference.option.optionMenuMessage) }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: referenceCellReuseIdentifier, for: indexPath) as! ReferenceCell
            if let reference = reference { cell.configureWithReference(text: reference.referenceText) }
            return cell
        }
    }
}

extension ReferenceMenuViewController: ContextMenuFooterDelegate {
    func didTapCloseMenu() {
        guard let reference = reference else { return }
        selectedReference = reference
        handleDismiss()
    }
}
