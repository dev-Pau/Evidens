//
//  GroupDescriptionCell.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/11/22.
//

import UIKit

protocol GroupDescriptionCellDelegate: AnyObject {
    func descriptionDidChange(text: String)
}

class GroupDescriptionCell: UICollectionViewCell {
    
    weak var delegate: GroupDescriptionCellDelegate?
    
    private let cellContentView = UIView()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var aboutTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "Add group description here"
        tv.placeholderLabel.font = .systemFont(ofSize: 15, weight: .regular)
        tv.placeholderLabel.textColor = .secondaryLabel
        tv.font = .systemFont(ofSize: 15, weight: .regular)
        tv.textColor = .label
        tv.delegate = self
        tv.isScrollEnabled = true
        tv.tintColor = primaryColor
        tv.backgroundColor = .systemBackground
        tv.layer.cornerRadius = 5
        tv.autocorrectionType = .no
        tv.placeHolderShouldCenter = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(cellContentView)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: topAnchor),
            cellContentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellContentView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        cellContentView.addSubviews(titleLabel, aboutTextView, separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            separatorView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10),
            separatorView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            titleLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10),
            titleLabel.widthAnchor.constraint(equalToConstant: 94),
            
            aboutTextView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 10),
            aboutTextView.heightAnchor.constraint(equalToConstant: 100),
            aboutTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            aboutTextView.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor)
        ])
    }
    
    func set(title: String) {
        titleLabel.text = title
    }
    
    func set(description: String) {
        aboutTextView.text = description
        aboutTextView.placeholderLabel.isHidden = true
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        let autoLayoutSize = cellContentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: CGSize(width: autoLayoutSize.width, height: autoLayoutSize.height))
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
}

extension GroupDescriptionCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.descriptionDidChange(text: textView.text)
    }
}

