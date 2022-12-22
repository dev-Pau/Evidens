//
//  GroupContentSelectionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/12/22.
//

import UIKit

class GroupContentSelectionHeader: UICollectionReusableView {
    
    private let contentTopics = ["All", "Posts", "Cases"]
    
    private lazy var segmentedButtonsView: CustomSegmentedButtonsView = {
        let segmentedButtonsView = CustomSegmentedButtonsView()
        segmentedButtonsView.setLabelsTitles(titles: contentTopics)
        segmentedButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedButtonsView.backgroundColor = .white
        return segmentedButtonsView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .white
        addSubview(segmentedButtonsView)
        NSLayoutConstraint.activate([
            segmentedButtonsView.topAnchor.constraint(equalTo: topAnchor),
            segmentedButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedButtonsView.heightAnchor.constraint(equalToConstant: 41),
        ])
    }
}
