//
//  RecentTextCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/5/22.
//

import UIKit

class RecentTextCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: RecentTextCellViewModel? {
        didSet {
            configure()
        }
    }
    
    private let recentSearchedTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var goToTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.left"), for: .normal)
        button.tintColor = blackColor
        button.addTarget(self, action: #selector(didTapRecentText), for: .touchUpInside)
        return button
    }()
    
    private let clockImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "clock")
        iv.setDimensions(height: 15, width: 15)
        return iv
    }()
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white

        addSubview(clockImage)
        clockImage.centerY(inView: self)
        clockImage.anchor(left: leftAnchor, paddingLeft: 10)
        
        addSubview(goToTextButton)
        goToTextButton.centerY(inView: clockImage)
        goToTextButton.anchor(right: rightAnchor, paddingRight: 12)
        
        addSubview(recentSearchedTextLabel)
        recentSearchedTextLabel.centerY(inView: self)
        recentSearchedTextLabel.anchor(left: clockImage.rightAnchor, paddingLeft: 10)
        recentSearchedTextLabel.text = "Hello"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        recentSearchedTextLabel.text = viewModel.textToDisplay
        //fullNameLabel.text = viewModel.firstName + " " + viewModel.lastName
        //profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
    
    
    //MARK: - Actions
    
    @objc func didTapRecentText() {
        print("Did tap recent text")
    }
    
    
}
