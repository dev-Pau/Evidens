//
//  NetworkToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/8/23.
//

import Foundation


import UIKit

private let messageSearchCellReuseIdentifier = "MessageSearchCellReuseIdentifier"

protocol NetworkToolbarDelegate: AnyObject {
    func didTapIndex(_ index: Int)
}

class NetworkToolbar: UIToolbar {
    weak var toolbarDelegate: NetworkToolbarDelegate?
    private var collectionView: UICollectionView!
    private var originCell = [0.0, 0.0, 0.0]
    private var widthCell = [0.0, 0.0, 0.0]
    private var sizes: CGFloat = 0.0
    private var didSelectFirstByDefault: Bool = false
    private var firstTime: Bool = false
    private var currentIndex = IndexPath()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var widthConstantConstraint: NSLayoutConstraint!
    
    private var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = primaryColor
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        let currentFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let objects = UserNetwork.allCases.map { $0.title }
        for object in objects {
            let attributes = [NSAttributedString.Key.font: currentFont]
            let size = (object as NSString).size(withAttributes: attributes)
            sizes += size.width
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSelectFirstByDefault {
            selectFirstIndex()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        scrollEdgeAppearance = appearance
        standardAppearance = appearance
        
        translatesAutoresizingMaskIntoConstraints = false
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createFilterCellLayout())
        collectionView.backgroundColor = .clear
        
        leadingConstraint = highlightView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor)
        widthConstantConstraint = highlightView.widthAnchor.constraint(equalToConstant: 100)

        addSubviews(highlightView, collectionView, separatorView)
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 35),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            
            highlightView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            highlightView.heightAnchor.constraint(equalToConstant: 4),
            leadingConstraint,
            widthConstantConstraint,
            
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        collectionView.isScrollEnabled = false
        collectionView.register(MessageSearchCell.self, forCellWithReuseIdentifier: messageSearchCellReuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        highlightView.layer.cornerRadius = 4 / 2
    }

    private func createFilterCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous

            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let width = strongSelf.frame.width
            let availableWidth = width - 30 - 30 - strongSelf.sizes - 10
            section.interGroupSpacing = availableWidth / 2
            
            return section
        }
        return layout
    }
    
    private func selectFirstIndex() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: [])
            strongSelf.collectionView(strongSelf.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        }
    }
    
    func reset() {
        leadingConstraint.constant = originCell[1]
    }
    
    private func getCollectionViewLayout() {
        if !firstTime {
            var totalWidth = 0.0
            for index in 0 ..< collectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: index, section: 0)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    let cellWidth = cell.frame.width
                    totalWidth += cellWidth
                    originCell[indexPath.row] = cell.frame.origin.x
                    widthCell[indexPath.row] = cellWidth
                }
            }
            firstTime.toggle()
        }
    }
}


extension NetworkToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserNetwork.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageSearchCellReuseIdentifier, for: indexPath) as! MessageSearchCell
        cell.label.text = UserNetwork.allCases[indexPath.row].title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MessageSearchCell {
            if didSelectFirstByDefault {
                toolbarDelegate?.didTapIndex(indexPath.item)
            } else {
                leadingConstraint.constant = cell.frame.origin.x
                widthConstantConstraint.constant = cell.frame.width
                didSelectFirstByDefault.toggle()
                layoutIfNeeded()
            }
        }
    }
}

extension NetworkToolbar {
    
    /// Changes the bottom border position and the color as we scroll to the left/right. This function gets called every time the collectionView moves
    func collectionViewDidScroll(for x: CGFloat) {
        getCollectionViewLayout()
        
        let indexPaths = collectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row}
        let firstCell = collectionView.cellForItem(at: indexPaths[0]) as? MessageSearchCell
        let secondCell = collectionView.cellForItem(at: indexPaths[1]) as? MessageSearchCell
        let thirdCell = collectionView.cellForItem(at: indexPaths[2]) as? MessageSearchCell
        
        switch x {
        case 0 ... frame.width + 10:
            let availableWidth = originCell[1] - originCell[0]
            let factor = availableWidth / (frame.width + 10.0)
            let offset = x * factor
            leadingConstraint.constant = offset
            
            let progress = offset / availableWidth
            widthConstantConstraint.constant = widthCell[0] + (widthCell[1] - widthCell[0]) * progress
            firstCell?.set(from: .label, to: .secondaryLabel, progress: progress)
            secondCell?.set(from: .secondaryLabel, to: .label, progress: progress)
            thirdCell?.setDefault()
        case (frame.width + 10)... :
            let availableWidth = originCell[2] - originCell[1] - (widthCell[1] - widthCell[0])
            let factor = availableWidth / (frame.width + 10.0)
            
            let factor2 = (widthCell[1] - widthCell[0]) / frame.width

            let offset = x * factor + (x - frame.width) * factor2
            leadingConstraint.constant = offset
            
            let progress = abs(1 - (offset / availableWidth))
            let normalizedProgress = max(0.0, min(1.0, progress))

            widthConstantConstraint.constant = widthCell[1] + (widthCell[2] - widthCell[1]) * normalizedProgress
            thirdCell?.set(from: .secondaryLabel, to: .label, progress: normalizedProgress)
            secondCell?.set(from: .label, to: .secondaryLabel, progress: normalizedProgress)
            firstCell?.setDefault()

        default:
            break
        }
    }
}
    
