//
//  SupportSectionViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 31/8/22.
//

private let supportSectionCellReuseIdentifier = "SupportSectionCellReuseIdentifier"

import UIKit

protocol SupportSectionViewControllerDelegate: AnyObject {
    func didTapSectionOption(optionText: String)
}

class SupportSectionViewController: UICollectionViewController {
    
    weak var delegate: SupportSectionViewControllerDelegate?
    
    var previousValue: String = ""
    
    var collectionData = [Sections]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.bounces = true
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(SupportSectionCell.self, forCellWithReuseIdentifier: supportSectionCellReuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: supportSectionCellReuseIdentifier, for: indexPath) as! SupportSectionCell
        cell.set(title: collectionData[indexPath.row])
        if let text = cell.typeTitle.text {
            if previousValue == text {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SupportSectionCell {
            delegate?.didTapSectionOption(optionText: cell.typeTitle.text!)
            navigationController?.popViewController(animated: true)
        }
    }
}
