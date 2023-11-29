//
//  ProfileToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 7/9/23.
//

import UIKit

private let profileToolbarCellReuseIdentifier = "ProfileToolbarCellReuseIdentifier"

protocol ProfileToolbarDelegate: AnyObject {
    func didTapIndex(_ index: Int)
}

class ProfileToolbar: UIToolbar {
    weak var toolbarDelegate: ProfileToolbarDelegate?
    private var collectionView: UICollectionView!
    private var originCell = [0.0, 0.0, 0.0, 0.0]
    private var widthCell = [0.0, 0.0, 0.0, 0.0]
 
    private var leadingConstraint: NSLayoutConstraint!
    private var widthConstantConstraint: NSLayoutConstraint!
    
    private var didSelectFirstByDefault: Bool = false
    private var firstTime: Bool = false
    private var currentIndex = IndexPath()
    
    private var sizes: CGFloat = 0.0
    
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
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let heavyFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.traits: [
                UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold.rawValue
            ]
        ])
        
        let currentFont = UIFont(descriptor: heavyFontDescriptor, size: 0)
        let objects = ProfileSection.allCases.map { $0.title }
        for object in objects {
            let attributes = [NSAttributedString.Key.font: currentFont]
            let size = (object as NSString).size(withAttributes: attributes)
            sizes += size.width
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSelectFirstByDefault {
            selectFirstIndex()
        }
    }
    
    private func configure() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        scrollEdgeAppearance = appearance
        standardAppearance = appearance
        
        translatesAutoresizingMaskIntoConstraints = false
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createProfileLayout())
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        leadingConstraint = highlightView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor)
        widthConstantConstraint = highlightView.widthAnchor.constraint(equalToConstant: 100)
        
        addSubviews(highlightView, collectionView, separatorView)
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 35),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
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
        collectionView.register(MessageSearchCell.self, forCellWithReuseIdentifier: profileToolbarCellReuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        highlightView.layer.cornerRadius = 4 / 2
    }
    
    private func createProfileLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, env in
            guard let strongSelf = self else { return nil }
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .fractionalHeight(1)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous

            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let width = strongSelf.frame.width
            let availableWidth = width - 10 - 10 - strongSelf.sizes - 1
            section.interGroupSpacing = availableWidth / 3
            
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

extension ProfileToolbar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileToolbarCellReuseIdentifier, for: indexPath) as! MessageSearchCell
        cell.label.text = ProfileSection.allCases[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MessageSearchCell {
            if didSelectFirstByDefault {
                guard currentIndex != indexPath else { return }
                toolbarDelegate?.didTapIndex(indexPath.item)
                currentIndex = indexPath
            } else {
                leadingConstraint.constant = cell.frame.origin.x
                widthConstantConstraint.constant = cell.frame.width
                didSelectFirstByDefault.toggle()
                currentIndex = indexPath
                layoutIfNeeded()
            }
        }
    }
}

extension ProfileToolbar {
    func collectionViewDidScroll(for x: CGFloat) {
        getCollectionViewLayout()
        
        let indexPaths = collectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row }
        let firstCell = collectionView.cellForItem(at: indexPaths[0]) as? MessageSearchCell
        let secondCell = collectionView.cellForItem(at: indexPaths[1]) as? MessageSearchCell
        let thirdCell = collectionView.cellForItem(at: indexPaths[2]) as? MessageSearchCell
        let fourthCell = collectionView.cellForItem(at: indexPaths[3]) as? MessageSearchCell
        
        switch x {
        case 0 ..< frame.width + 10:
            
            let availableWidth = originCell[1] - originCell[0]
            let factor = availableWidth / (frame.width + 10.0)
            
            let offset = x * factor
            let progress = offset / availableWidth
            
            leadingConstraint.constant = offset
            
            widthConstantConstraint.constant = widthCell[0] + (widthCell[1] - widthCell[0]) * progress
            firstCell?.set(from: .label, to: .secondaryLabel, progress: progress)
            secondCell?.set(from: .secondaryLabel, to: .label, progress: progress)
            thirdCell?.setDefault()
            fourthCell?.setDefault()
            currentIndex = IndexPath(item: 0, section: 0)
        case frame.width + 10 ..< 2 * frame.width + 20:
            
            let availableWidth = originCell[2] - originCell[1] - (widthCell[1] - widthCell[0])
            let factor = availableWidth / (frame.width + 10.0)
            
            let factor2 = (widthCell[1] - widthCell[0]) / (frame.width + 10.0)
            
            let offset = x * factor + (x - (frame.width + 10.0)) * factor2
            
            let startOffset = frame.width + 10.0
            let endOffset = 2 * frame.width + 20.0
            
            let progress = (x - startOffset) / (endOffset - startOffset)
            
            let normalizedProgress = max(0.0, min(1.0, progress))
            
            leadingConstraint.constant = offset
            
            widthConstantConstraint.constant = widthCell[1] + (widthCell[2] - widthCell[1]) * normalizedProgress
            thirdCell?.set(from: .secondaryLabel, to: .label, progress: normalizedProgress)
            secondCell?.set(from: .label, to: .secondaryLabel, progress: normalizedProgress)
            firstCell?.setDefault()
            fourthCell?.setDefault()
            currentIndex = IndexPath(item: 1, section: 0)
        case 2 * frame.width + 20 ..< 3 * frame.width + 30:
            
            let availableWidth = originCell[3] - originCell[2] - (widthCell[2] - widthCell[1])
            let factor = availableWidth / (frame.width + 10.0)
            
            let factor3 = (widthCell[2] - widthCell[1]) / (frame.width + 10.0)
            
            let startOffset = 2 * frame.width + 20.0
            let endOffset = 3 * frame.width
            let xOffset = x - startOffset
            let offset = xOffset * factor + xOffset * factor3
            
            leadingConstraint.constant = min(originCell[3], offset + originCell[2])
            
            let progress = (x - startOffset) / (endOffset - startOffset)
            let normalizedProgress = max(0.0, min(1.0, progress))
            
            widthConstantConstraint.constant = widthCell[2] + (widthCell[3] - widthCell[2]) * normalizedProgress
            fourthCell?.set(from: .secondaryLabel, to: .label, progress: normalizedProgress)
            thirdCell?.set(from: .label, to: .secondaryLabel, progress: normalizedProgress)
            secondCell?.setDefault()
            firstCell?.setDefault()
            currentIndex = IndexPath(item: 2, section: 0)
        default:
            currentIndex = IndexPath(item: 3, section: 0)
            widthConstantConstraint.constant = widthCell[3]
            leadingConstraint.constant = originCell[3]
        }
    }
}
