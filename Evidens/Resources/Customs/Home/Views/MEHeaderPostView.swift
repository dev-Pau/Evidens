//
//  MEHeaderPostView.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/6/22.
//

import UIKit

protocol MEHeaderPostViewDelegate: AnyObject {
    func didTapThreeDots(withAction action: String)
    func didTapCategory(for category: String)
    func didTapSubCategory(for subCategory: String)
}


class MEHeaderPostView: UIView {
    
    //MARK: - Properties
    
    private var category: String = ""
    private var subCategory: String = ""
    
    private var paddingTop: CGFloat =  10
    private var paddingLeft: CGFloat = 10
    
    weak var delegate: MEHeaderPostViewDelegate?
    
    private lazy var categoryPostButton = MECategoryPostButton(title: "", color: .black, titleColor: .white)
    
    private lazy var subCategoryPostButton = MECategoryPostButton(title: "", color: lightGrayColor, titleColor: .black)
    
    private lazy var dotsImageButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "ellipsis")
        button.configuration?.baseForegroundColor = .black
        
        button.configuration?.cornerStyle = .capsule
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(didTapThreeDots), for: .touchUpInside)
        return button
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = separatorColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(category: String, subCategory: String) {
        super.init(frame: .zero)
        self.category = category
        self.subCategory = subCategory
        
        configure()
    }
    
    
    //MARK: - Helpers
    
    
    private func configure() {
        categoryPostButton.setTitle(category, for: .normal)
        subCategoryPostButton.setTitle(subCategory, for: .normal)
        
        dotsImageButton.menu = addMenuItems()
        
        categoryPostButton.addTarget(self, action: #selector(handleCategoryTap), for: .touchUpInside)
        subCategoryPostButton.addTarget(self, action: #selector(handleSubCategoryTap), for: .touchUpInside)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(categoryPostButton, subCategoryPostButton, dotsImageButton, separatorLabel)
        
        NSLayoutConstraint.activate([
            categoryPostButton.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            categoryPostButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            categoryPostButton.heightAnchor.constraint(equalToConstant: 30),
        
            subCategoryPostButton.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            subCategoryPostButton.leadingAnchor.constraint(equalTo: categoryPostButton.trailingAnchor, constant: paddingLeft),
            subCategoryPostButton.heightAnchor.constraint(equalToConstant: 30),
            
            dotsImageButton.centerYAnchor.constraint(equalTo: categoryPostButton.centerYAnchor),
            dotsImageButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingLeft),
            dotsImageButton.heightAnchor.constraint(equalToConstant: 20),
            dotsImageButton.widthAnchor.constraint(equalToConstant: 20),
            
            separatorLabel.topAnchor.constraint(equalTo: categoryPostButton.bottomAnchor, constant: paddingTop),
            separatorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLabel.heightAnchor.constraint(equalToConstant: 0.4)
        ])
    }
    
    func addMenuItems() -> UIMenu {
        let menuItem = UIMenu(title: "", subtitle: "", image: nil, identifier: nil, options: .displayInline, children: [
            UIAction(title: "Report Post", image: UIImage(systemName: "flag"), handler: { (_) in
                self.delegate?.didTapThreeDots(withAction: "Report Post")
            })
        ])
        return menuItem
    }
    
    
    //MARK: - Actions
    
    @objc func didTapThreeDots() {
        dotsImageButton.showsMenuAsPrimaryAction = true
    }
    
    
    @objc func handleCategoryTap() {
        guard let text = categoryPostButton.titleLabel?.text else { return }
        delegate?.didTapCategory(for: text)
    }
    
    @objc func handleSubCategoryTap() {
        guard let text = subCategoryPostButton.titleLabel?.text else { return }
        delegate?.didTapSubCategory(for: text)
    }
}
