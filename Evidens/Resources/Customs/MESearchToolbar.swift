//
//  MESearchToolbar.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/2/23.
//

import UIKit

class MESearchToolbar: UIToolbar {
    private var viewLeadingAnchor: NSLayoutConstraint!
    private var viewWidthAnchor: NSLayoutConstraint!

    private var collectionView: UICollectionView!
    private let dataSource = Profession.getAllProfessions().map({ $0.profession })
    private var bottomView: UIView!
    private var scrollView: UIScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        bottomView = UIView()
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = primaryColor
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCellLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ToolbarSearchCell.self, forCellWithReuseIdentifier: "kek")
        addSubviews(scrollView)
        scrollView.addSubviews(bottomView, collectionView)
        viewLeadingAnchor = bottomView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10)
        viewLeadingAnchor.isActive = true
        viewWidthAnchor = bottomView.widthAnchor.constraint(equalToConstant: 78)
        viewWidthAnchor.isActive = true
        
        NSLayoutConstraint.activate([

            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            //bottomView.heightAnchor.constraint(equalToConstant: 40),
            //bottomView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
        ])
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 5, height: 40)
        //print(collectionView.contentOffset)
        bottomView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bottomView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
    }
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(1), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(200), heightDimension: .absolute(30)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
            return section
        }
        return layout
    }
}

extension MESearchToolbar: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            print("scrolling collection")
            self.scrollView.setContentOffset(scrollView.contentOffset, animated: true)
        } else {
            print("scrollview did scroll")
        }
        //scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
}

extension MESearchToolbar: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kek", for: indexPath) as! ToolbarSearchCell
        cell.tagsLabel.text = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            print(cell.frame.width)
            print(collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath))
            print(collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame.origin.x)
            UIView.animate(withDuration: 0.5) {
                
            }
        }
    }
}




class ToolbarSearchCell: UICollectionViewCell {
    
    var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(tagsLabel)
        
        NSLayoutConstraint.activate([
            tagsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            tagsLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}


