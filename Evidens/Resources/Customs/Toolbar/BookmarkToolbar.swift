//
//  BookmarkToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/6/23.
//

import UIKit

private let messageSearchCellReuseIdentifier = "MessageSearchCellReuseIdentifier"

protocol BookmarkToolbarDelegate: AnyObject {
    func didTapIndex(_ index: Int)
}

class BookmarkToolbar: UIToolbar {
    weak var toolbarDelegate: BookmarkToolbarDelegate?
    private var collectionView: UICollectionView!
    private var originCell = [0.0, 0.0]
    private var widthCell = [0.0, 0.0]
    
    private var sizes: CGFloat = 0.0
    private let insets = UIDevice.isPad ? 200.0 : 70.0

    private var cellX = 70.0
    
    private var didSelectFirstByDefault: Bool = false
    private var firstTime: Bool = false
    private var currentIndex = IndexPath()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var widthConstantConstraint: NSLayoutConstraint!
    
    private var highlightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.primaryColor
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        
        let currentFont = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .bold)
        
        let objects = BookmarkKind.allCases.map { $0.title }
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
        widthConstantConstraint = highlightView.widthAnchor.constraint(equalToConstant: 0)

        addSubviews(highlightView, collectionView, separatorView)
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 35),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
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
        collectionView.register(ToolbarSearchCell.self, forCellWithReuseIdentifier: messageSearchCellReuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
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

            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: strongSelf.insets, bottom: 0, trailing: strongSelf.insets)
            let width = strongSelf.frame.width
            let availableWidth = width - strongSelf.sizes - 2 * strongSelf.insets - 1
            section.interGroupSpacing = availableWidth
            
            section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, point, env) -> Void in
                guard let strongSelf = self else { return }
                strongSelf.leadingConstraint.constant = strongSelf.cellX - point.x
            }
            
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
    
    func firstIndex() {
        leadingConstraint.constant = originCell[0]
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


extension BookmarkToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BookmarkKind.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageSearchCellReuseIdentifier, for: indexPath) as! ToolbarSearchCell
        cell.label.text = BookmarkKind.allCases[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ToolbarSearchCell {
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

extension BookmarkToolbar {
    
    /// Changes the bottom border position and the color as we scroll to the left/right. This function gets called every time the collectionView moves
    func collectionViewDidScroll(for x: CGFloat) {
        getCollectionViewLayout()
        
        let indexPaths = collectionView.indexPathsForVisibleItems.sorted { $0.row < $1.row }
        let firstCell = collectionView.cellForItem(at: indexPaths[0]) as? ToolbarSearchCell
        let secondCell = collectionView.cellForItem(at: indexPaths[1]) as? ToolbarSearchCell
        
        switch x {
        case 0 ..< frame.width + 10:
            let availableWidth = originCell[1] - originCell[0]
            let factor = availableWidth / (frame.width + 10.0)
            let offset = x * factor
            
            leadingConstraint.constant = offset + insets
            cellX = offset + insets
            let progress = offset / availableWidth
            widthConstantConstraint.constant = widthCell[0] + (widthCell[1] - widthCell[0]) * progress
            firstCell?.set(from: .label, to: K.Colors.primaryGray, progress: progress)
            secondCell?.set(from: K.Colors.primaryGray, to: .label, progress: progress)
            currentIndex = IndexPath(item: 0, section: 0)
        default:
            widthConstantConstraint.constant = widthCell[1]
            leadingConstraint.constant = originCell[1]
            cellX = originCell[1]
            currentIndex = IndexPath(item: 1, section: 0)
        }
    }
}
    
