//
//  EditAboutCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 27/7/22.
//

import UIKit

class EditAboutCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.text = "About"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editAboutTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = .black
        tv.tintColor = primaryColor
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        //tv.delegate = self
        tv.isScrollEnabled = true
        tv.autocorrectionType = .no
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.text = "You can talk about your hobbies, achievements, skills, job experiences or any information you want to share"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cellContentView.addSubviews(titleLabel, editAboutTextView, placeholderLabel, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            titleLabel.widthAnchor.constraint(equalToConstant: 97),
            
            editAboutTextView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            editAboutTextView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -10),
            editAboutTextView.heightAnchor.constraint(equalToConstant: 100),
            editAboutTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            editAboutTextView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -5),
            
            placeholderLabel.topAnchor.constraint(equalTo: editAboutTextView.topAnchor, constant: 5),
            placeholderLabel.leadingAnchor.constraint(equalTo: editAboutTextView.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: editAboutTextView.trailingAnchor),
            //placeholderLabel.bottomAnchor.constraint(equalTo: editAboutTextView.bottomAnchor)
        ])
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height + 1))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    @objc func handleTextDidChange() {
        placeholderLabel.isHidden = !editAboutTextView.text.isEmpty
    }
}
